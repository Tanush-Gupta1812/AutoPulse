"""
AutoPulse Database Seed Script
Populates demo vehicles, partner garages, baseline telemetry, and initial diagnostic alerts.
"""

import asyncio
from datetime import UTC, datetime, timedelta

from backend.app.core.database import AsyncSessionLocal, Base, engine
from backend.app.models.entities import Alert, Car, Garage, TelemetryRecord
from simulator.obd_simulator import DEMO_VEHICLES, SimulatedSource
from sqlalchemy import select

DEMO_GARAGES = [
    Garage(
        id="bosch_sector18",
        name="Bosch Car Service - Sector 18",
        address="B-42, Sector 18 Automotive Hub, Noida",
        distance_km=2.4,
        rating=4.9,
        is_partner=True,
        specializations="Electrical Subsystems, Exide/Amaron Batteries, ECU Flashing",
        phone="+91 98112 34567"
    ),
    Garage(
        id="castrol_kailash",
        name="Castrol Auto Service & Diagnostics",
        address="Plot 12, Greater Kailash-I, New Delhi",
        distance_km=4.8,
        rating=4.8,
        is_partner=True,
        specializations="Thermostat & Cooling Systems, Multi-brand Service",
        phone="+91 98119 87654"
    ),
    Garage(
        id="firstchoice_cyberhub",
        name="Mahindra FirstChoice Prime Garage",
        address="DLF Cyber City Phase II, Gurugram",
        distance_km=7.2,
        rating=4.7,
        is_partner=True,
        specializations="Engine Tuning, Spark Plugs & Ignition Coils, Suspension",
        phone="+91 99100 12345"
    ),
    Garage(
        id="gomechanic_southcity",
        name="GoMechanic Certified Hub",
        address="South City 1, Gurugram",
        distance_km=9.1,
        rating=4.6,
        is_partner=True,
        specializations="General Periodic Maintenance, AC & Radiator Flush",
        phone="+91 98711 55443"
    )
]


async def seed_database():
    """Initializes schema and seeds demonstration database."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as session:
        # Check if already seeded
        result = await session.execute(select(Car))
        existing_cars = result.scalars().all()
        if existing_cars:
            print("Database already seeded. Skipping initial seed.")
            return

        print("Seeding AutoPulse demo vehicles...")
        for key, p in DEMO_VEHICLES.items():
            urgent = None
            if key == "swift_2016":
                urgent = "Battery fails in ~9 days"
                score = 54
                status = "Critical"
                paired = True
            elif key == "i20_2018":
                urgent = "Cooling temp creep, thermostat stuck"
                score = 61
                status = "Warning"
                paired = True
            elif key == "city_2014":
                urgent = "O2 sensor slow response"
                score = 65
                status = "Watch"
                paired = False
            elif key == "nexon_2020":
                urgent = "Spark plug jitter"
                score = 72
                status = "Watch"
                paired = False
            elif key == "xuv500_2015":
                urgent = "Alternator diode ripple"
                score = 78
                status = "Watch"
                paired = False
            else:
                urgent = "All Systems Normal"
                score = 94
                status = "OK"
                paired = True

            car = Car(
                id=p.car_id,
                vin=f"MA3E{p.car_id.upper()}2024XYZ",
                make=p.name.split()[0],
                model=" ".join(p.name.split()[1:]),
                year=p.year,
                license_plate=p.license_plate,
                engine_desc=p.engine,
                odometer_km=64280 if key == "swift_2016" else 42100,
                is_paired=paired,
                paired_at=datetime.now(UTC) - timedelta(days=14) if paired else None,
                dongle_mac="00:1D:A5:68:98:8B" if paired else None,
                current_health_score=score,
                current_status=status,
                urgent_prediction=urgent,
                active_scenario=p.active_scenario,
                simulated_day=p.simulated_day
            )
            session.add(car)

        print("Seeding partner garages...")
        for g in DEMO_GARAGES:
            session.add(g)

        print("Seeding initial alerts for Swift and i20...")
        swift_alert = Alert(
            car_id="swift_2016",
            title="Battery Failure Imminent in ~9 Days",
            message="Idle resting voltage dropped 0.6V across 12 days to 11.8V. Morning crank sag reached 9.2V. Pre-emptive battery replacement recommended.",
            severity="critical",
            component_name="Battery & Electrical",
            is_read=False,
            created_at=datetime.now(UTC) - timedelta(hours=2)
        )
        swift_alert2 = Alert(
            car_id="swift_2016",
            title="Sub-12V Cranking Warning",
            message="Ignition cold crank transient dipped to 9.2V (Threshold > 10.2V).",
            severity="warning",
            component_name="Battery & Electrical",
            is_read=True,
            created_at=datetime.now(UTC) - timedelta(days=2)
        )
        i20_alert = Alert(
            car_id="i20_2018",
            title="Coolant Operating Temp Creep",
            message="Engine coolant reached 104°C during idle. Thermostat opening delayed.",
            severity="warning",
            component_name="Cooling System",
            is_read=False,
            created_at=datetime.now(UTC) - timedelta(hours=5)
        )
        session.add(swift_alert)
        session.add(swift_alert2)
        session.add(i20_alert)

        # Seed initial historical telemetry points for Swift
        sim = SimulatedSource("swift_2016")
        now = datetime.now(UTC)
        for i in range(30):
            pkt = sim.generate_single_packet()
            rec = TelemetryRecord(
                car_id="swift_2016",
                timestamp=now - timedelta(seconds=(30 - i) * 2),
                rpm=pkt.rpm,
                speed=pkt.speed,
                coolant_temp=pkt.coolant_temp,
                engine_load=pkt.engine_load,
                battery_voltage=pkt.battery_voltage,
                intake_air_temp=pkt.intake_air_temp,
                short_fuel_trim=pkt.short_fuel_trim,
                long_fuel_trim=pkt.long_fuel_trim,
                maf=pkt.maf,
                throttle_pos=pkt.throttle_pos,
                o2_voltage=pkt.o2_voltage,
                engine_on=True,
                simulated_day=12.0
            )
            session.add(rec)

        await session.commit()
        print("Database seed completed successfully!")


if __name__ == "__main__":
    asyncio.run(seed_database())
