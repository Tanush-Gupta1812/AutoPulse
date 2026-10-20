"""
AutoPulse Realistic OBD-II Telemetry Simulator
Simulates multi-vehicle CAN-bus streams at ~1 Hz with physics-based sensor interactions,
configurable degradation fault scenarios, and fast-forward time-lapse acceleration.
"""

import asyncio
import math
import random
from collections.abc import AsyncGenerator
from datetime import UTC, datetime

from simulator.source_interface import TelemetryPacket, TelemetrySource


class VehicleProfile:
    def __init__(
        self,
        car_id: str,
        name: str,
        year: int,
        engine: str,
        license_plate: str,
        baseline_idle_rpm: float = 750.0,
        baseline_coolant_temp: float = 90.0,
        baseline_resting_voltage: float = 12.6,
        baseline_charging_voltage: float = 14.2,
        active_scenario: str = "healthy",
        simulated_day: float = 0.0
    ):
        self.car_id = car_id
        self.name = name
        self.year = year
        self.engine = engine
        self.license_plate = license_plate
        self.baseline_idle_rpm = baseline_idle_rpm
        self.baseline_coolant_temp = baseline_coolant_temp
        self.baseline_resting_voltage = baseline_resting_voltage
        self.baseline_charging_voltage = baseline_charging_voltage
        self.active_scenario = active_scenario
        self.simulated_day = simulated_day


DEMO_VEHICLES: dict[str, VehicleProfile] = {
    "swift_2016": VehicleProfile(
        car_id="swift_2016",
        name="Maruti Swift VXi",
        year=2016,
        engine="1.2L K12M VVT Petrol",
        license_plate="DL 3C AP 4821",
        baseline_idle_rpm=750.0,
        baseline_coolant_temp=90.0,
        baseline_resting_voltage=12.6,
        baseline_charging_voltage=14.2,
        active_scenario="weak_battery",
        simulated_day=12.0  # Already 12 days into battery degradation curve!
    ),
    "i20_2018": VehicleProfile(
        car_id="i20_2018",
        name="Hyundai i20 Asta",
        year=2018,
        engine="1.2L Kappa Dual VTVT",
        license_plate="DL 8C BK 1904",
        baseline_idle_rpm=720.0,
        baseline_coolant_temp=89.0,
        baseline_resting_voltage=12.5,
        baseline_charging_voltage=14.1,
        active_scenario="cooling_fault",
        simulated_day=8.0
    ),
    "city_2014": VehicleProfile(
        car_id="city_2014",
        name="Honda City VX",
        year=2014,
        engine="1.5L i-VTEC Petrol",
        license_plate="HR 26 CQ 9912",
        baseline_idle_rpm=700.0,
        baseline_coolant_temp=91.0,
        baseline_resting_voltage=12.7,
        baseline_charging_voltage=14.3,
        active_scenario="o2_sensor_aging",
        simulated_day=15.0
    ),
    "nexon_2020": VehicleProfile(
        car_id="nexon_2020",
        name="Tata Nexon XZ+",
        year=2020,
        engine="1.2L Revotron Turbo",
        license_plate="UP 16 BX 4410",
        baseline_idle_rpm=800.0,
        baseline_coolant_temp=90.0,
        baseline_resting_voltage=12.6,
        baseline_charging_voltage=14.2,
        active_scenario="spark_plug_wear",
        simulated_day=6.0
    ),
    "xuv500_2015": VehicleProfile(
        car_id="xuv500_2015",
        name="Mahindra XUV500 W8",
        year=2015,
        engine="2.2L mHawk Diesel",
        license_plate="DL 1V CD 3320",
        baseline_idle_rpm=780.0,
        baseline_coolant_temp=88.0,
        baseline_resting_voltage=12.5,
        baseline_charging_voltage=14.0,
        active_scenario="alternator_weakness",
        simulated_day=10.0
    ),
    "baleno_2019": VehicleProfile(
        car_id="baleno_2019",
        name="Maruti Baleno Alpha",
        year=2019,
        engine="1.2L DualJet Petrol",
        license_plate="DL 7C AR 5521",
        baseline_idle_rpm=740.0,
        baseline_coolant_temp=89.0,
        baseline_resting_voltage=12.65,
        baseline_charging_voltage=14.25,
        active_scenario="healthy",
        simulated_day=0.0
    )
}


class SimulatedSource(TelemetrySource):
    """Generates continuous realistic OBD-II PID telemetry."""

    def __init__(self, car_id: str = "swift_2016"):
        self.car_id = car_id
        self.profile = DEMO_VEHICLES.get(car_id, DEMO_VEHICLES["swift_2016"])
        self.connected = False
        self._step_counter = 0
        self._is_running = True
        self.time_lapse_rate = 1.0  # 1.0 = real-time, 100.0 = fast forward

    async def connect(self, device_id: str) -> bool:
        if device_id in DEMO_VEHICLES:
            self.car_id = device_id
            self.profile = DEMO_VEHICLES[device_id]
        self.connected = True
        return True

    async def disconnect(self) -> None:
        self.connected = False

    def is_connected(self) -> bool:
        return self.connected

    def set_scenario(self, scenario_name: str) -> None:
        """Dynamically inject a degradation scenario during demo."""
        self.profile.active_scenario = scenario_name

    def fast_forward(self, days: float) -> None:
        """Fast-forward degradation days in seconds."""
        self.profile.simulated_day += days

    def generate_single_packet(self) -> TelemetryPacket:
        """Compute physically consistent OBD PIDs reflecting degradation state."""
        self._step_counter += 1
        t = self._step_counter
        p = self.profile

        # Simulated driving cycle (cycling through idle, city stop-and-go, cruise)
        cycle_phase = (t % 120) / 120.0
        if cycle_phase < 0.35:
            # Idling at traffic light / driveway
            target_rpm = p.baseline_idle_rpm + random.gauss(0, 8)
            speed = 0.0
            load = 18.0 + random.gauss(0, 1.5)
            throttle = 12.0
            maf = 2.2 + (target_rpm / 1000.0) * 0.4
        elif cycle_phase < 0.70:
            # Acceleration / City speed
            speed = 25.0 + 20.0 * math.sin((cycle_phase - 0.35) * math.pi / 0.35)
            target_rpm = p.baseline_idle_rpm + (speed * 35.0) + random.gauss(0, 30)
            load = 38.0 + random.gauss(0, 4.0)
            throttle = 26.0 + (speed / 50.0) * 15.0
            maf = 5.5 + (speed / 50.0) * 8.0
        else:
            # Cruising at 50-60 km/h
            speed = 52.0 + random.gauss(0, 2.0)
            target_rpm = 1850.0 + random.gauss(0, 20)
            load = 28.0 + random.gauss(0, 2.0)
            throttle = 22.0
            maf = 7.0 + random.gauss(0, 0.4)

        coolant = p.baseline_coolant_temp + 2.0 * math.sin(t * 0.05)
        battery = p.baseline_charging_voltage if speed > 5 else (p.baseline_charging_voltage - 0.2)
        intake_temp = 32.0 + 3.0 * math.sin(t * 0.02)
        stft = random.gauss(0.5, 1.2)
        ltft = 1.0 + random.gauss(0, 0.5)
        o2_volts = 0.45 + 0.38 * math.sin(t * 0.8)  # Oscillates 0.1V - 0.8V in closed-loop

        # ==========================================
        # INJECT DEGRADATION SCENARIO EFFECTS
        # ==========================================
        days = p.simulated_day

        if p.active_scenario == "weak_battery":
            # Idle resting voltage drops 0.05V per simulated day.
            # Morning crank sag dips sharply below 10.2V down to ~9.2V.
            voltage_loss = min(0.9, days * 0.05)
            battery = p.baseline_charging_voltage - 0.3 - voltage_loss
            if speed == 0.0:
                # When idling, voltage sags even more towards 11.8V
                battery = 12.4 - voltage_loss + random.gauss(0, 0.05)

        elif p.active_scenario == "cooling_fault":
            # Thermostat failure / radiator blockage: coolant temp creeps upward with days
            creep = min(22.0, days * 1.5)
            coolant = p.baseline_coolant_temp + creep + (load * 0.1)

        elif p.active_scenario == "o2_sensor_aging":
            # O2 sensor response slows and fuel trims drift lean (+10% to +18%)
            drift = min(15.0, days * 1.2)
            stft += drift * 0.6
            ltft += drift * 0.4
            o2_volts = 0.25 + 0.15 * math.sin(t * 0.15)  # sluggish switching

        elif p.active_scenario == "spark_plug_wear":
            # Cylinder misfire causes intermittent RPM jitter and fuel trim fluctuation
            jitter = random.choice([0, 0, 0, random.uniform(80, 180)])
            target_rpm += jitter
            stft += (jitter / 40.0)

        elif p.active_scenario == "alternator_weakness":
            # Alternator diode ripple: charging output drops below 13.5V, down to 12.9V under electrical load
            alt_drop = min(1.3, days * 0.12)
            battery = p.baseline_charging_voltage - alt_drop - (load * 0.015)

        return TelemetryPacket(
            car_id=self.car_id,
            timestamp=datetime.now(UTC),
            rpm=max(0.0, target_rpm),
            speed=max(0.0, speed),
            coolant_temp=coolant,
            engine_load=max(0.0, min(100.0, load)),
            battery_voltage=max(8.0, min(15.5, battery)),
            intake_air_temp=intake_temp,
            short_fuel_trim=stft,
            long_fuel_trim=ltft,
            maf=max(0.5, maf),
            throttle_pos=max(0.0, min(100.0, throttle)),
            o2_voltage=max(0.0, min(1.0, o2_volts)),
            engine_on=True,
            simulated_day=days
        )

    async def stream_telemetry(self) -> AsyncGenerator[TelemetryPacket, None]:
        """Stream packets at 1 Hz (or faster if time-lapse is engaged)."""
        while self._is_running:
            packet = self.generate_single_packet()
            yield packet
            sleep_sec = max(0.05, 1.0 / self.time_lapse_rate)
            await asyncio.sleep(sleep_sec)
