import asyncio
from datetime import UTC, datetime

from backend.app.core.database import get_db
from backend.app.engine.prediction_engine import PredictionEngine
from backend.app.models.entities import (
    Alert,
    Car,
    Garage,
    ServiceBooking,
    TelemetryRecord,
)
from backend.app.schemas.schemas import (
    AlertResponse,
    CarResponse,
    ComponentDetailSchema,
    DemoFastForwardRequest,
    DemoFaultInjectionRequest,
    FleetSummaryResponse,
    GarageResponse,
    PairingRequest,
    PairingResponse,
    ServiceBookingCreate,
    ServiceBookingResponse,
    VehicleHealthResponse,
)
from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect
from simulator.obd_simulator import SimulatedSource
from sqlalchemy import desc, select, update
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter()
engine = PredictionEngine()

# Active in-memory simulated sources per vehicle for stateful live streaming and demo controls
SIMULATOR_INSTANCES: dict[str, SimulatedSource] = {}


def get_simulator(car_id: str) -> SimulatedSource:
    if car_id not in SIMULATOR_INSTANCES:
        SIMULATOR_INSTANCES[car_id] = SimulatedSource(car_id=car_id)
    return SIMULATOR_INSTANCES[car_id]


# ==========================================
# VEHICLES & PAIRING ENDPOINTS
# ==========================================

@router.get("/cars", response_model=list[CarResponse])
async def list_cars(db: AsyncSession = Depends(get_db)):
    """List all available vehicles with pairing and health state."""
    result = await db.execute(select(Car).order_by(Car.year.desc()))
    return result.scalars().all()


@router.get("/cars/{car_id}", response_model=CarResponse)
async def get_car(car_id: str, db: AsyncSession = Depends(get_db)):
    """Get single vehicle details."""
    result = await db.execute(select(Car).where(Car.id == car_id))
    car = result.scalar_one_or_none()
    if not car:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return car


@router.post("/cars/{car_id}/pair", response_model=PairingResponse)
async def pair_dongle(car_id: str, payload: PairingRequest, db: AsyncSession = Depends(get_db)):
    """Simulates Bluetooth pairing with OBD-II dongle."""
    result = await db.execute(select(Car).where(Car.id == car_id))
    car = result.scalar_one_or_none()
    if not car:
        raise HTTPException(status_code=404, detail="Vehicle not found")

    car.is_paired = True
    car.paired_at = datetime.now(UTC)
    car.dongle_mac = payload.dongle_mac
    await db.commit()

    sim = get_simulator(car_id)
    await sim.connect(car_id)

    return PairingResponse(
        success=True,
        car_id=car_id,
        dongle_mac=payload.dongle_mac,
        paired_at=car.paired_at.isoformat(),
        status="CONNECTED",
        message=f"AutoPulse OBD-II dongle successfully linked with {car.make} {car.model}"
    )


# ==========================================
# HEALTH & PREDICTION FORECASTING
# ==========================================

@router.get("/cars/{car_id}/health", response_model=VehicleHealthResponse)
async def get_vehicle_health(car_id: str, db: AsyncSession = Depends(get_db)):
    """Returns overall car health score, urgent hero forecast, and all subsystem chips."""
    result = await db.execute(select(Car).where(Car.id == car_id))
    car = result.scalar_one_or_none()
    if not car:
        raise HTTPException(status_code=404, detail="Vehicle not found")

    sim = get_simulator(car_id)
    current_packet = sim.generate_single_packet()
    telemetry_dict = current_packet.to_dict()

    summary = engine.evaluate_vehicle_health(
        car_id=car_id,
        current_telemetry=telemetry_dict,
        simulated_day=sim.profile.simulated_day
    )

    # Sync snapshot back to car record
    car.current_health_score = summary.overall_health_score
    car.current_status = summary.overall_status
    if summary.urgent_forecast:
        car.urgent_prediction = f"{summary.urgent_forecast.component_name} fails in ~{summary.urgent_forecast.days_to_failure} days"
    else:
        car.urgent_prediction = "All Systems Normal"
    await db.commit()

    return VehicleHealthResponse(
        car_id=car_id,
        overall_health_score=summary.overall_health_score,
        overall_status=summary.overall_status,
        urgent_forecast=summary.urgent_forecast,
        components=summary.components,
        active_alerts_count=summary.active_alerts_count,
        total_savings_inr=summary.total_savings_inr,
        timestamp=summary.timestamp
    )


@router.get("/cars/{car_id}/components/{component_name}", response_model=ComponentDetailSchema)
async def get_component_detail(car_id: str, component_name: str, db: AsyncSession = Depends(get_db)):
    """Returns detailed diagnostic trajectory, days-to-failure forecast, and causal proof for a subsystem."""
    sim = get_simulator(car_id)
    current_packet = sim.generate_single_packet()
    telemetry_dict = current_packet.to_dict()

    summary = engine.evaluate_vehicle_health(
        car_id=car_id,
        current_telemetry=telemetry_dict,
        simulated_day=sim.profile.simulated_day
    )

    # Match normalized component name
    matched = None
    for c in summary.components:
        if component_name.lower() in c.component_name.lower():
            matched = c
            break

    if not matched:
        matched = summary.components[0]

    return matched


# ==========================================
# TELEMETRY & SPARKLINE ENDPOINTS
# ==========================================

@router.get("/cars/{car_id}/telemetry/latest")
async def get_latest_telemetry(car_id: str):
    """Returns the most recent single telemetry packet from the vehicle simulator."""
    sim = get_simulator(car_id)
    packet = sim.generate_single_packet()
    return packet.to_dict()


@router.get("/cars/{car_id}/telemetry/history")
async def get_telemetry_history(car_id: str, limit: int = 30, db: AsyncSession = Depends(get_db)):
    """Returns recent time-series telemetry records for sparklines and historical charts."""
    result = await db.execute(
        select(TelemetryRecord)
        .where(TelemetryRecord.car_id == car_id)
        .order_by(desc(TelemetryRecord.timestamp))
        .limit(limit)
    )
    records = result.scalars().all()
    if not records:
        # Fallback to generating a synthetic 30-point sequence from current profile
        sim = get_simulator(car_id)
        synthetic = []
        for _ in range(limit):
            synthetic.append(sim.generate_single_packet().to_dict())
        return synthetic
    return [
        {
            "timestamp": r.timestamp.isoformat(),
            "rpm": r.rpm,
            "speed": r.speed,
            "coolant_temp": r.coolant_temp,
            "battery_voltage": r.battery_voltage,
            "engine_load": r.engine_load
        }
        for r in reversed(records)
    ]


# ==========================================
# ALERTS & NOTIFICATIONS
# ==========================================

@router.get("/cars/{car_id}/alerts", response_model=list[AlertResponse])
async def list_alerts(car_id: str, db: AsyncSession = Depends(get_db)):
    """Get all notifications & diagnostic alerts for vehicle."""
    result = await db.execute(
        select(Alert)
        .where(Alert.car_id == car_id)
        .order_by(desc(Alert.created_at))
    )
    return result.scalars().all()


@router.post("/cars/{car_id}/alerts/{alert_id}/read")
async def mark_alert_read(car_id: str, alert_id: int, db: AsyncSession = Depends(get_db)):
    """Mark an alert as read."""
    await db.execute(
        update(Alert)
        .where(Alert.id == alert_id, Alert.car_id == car_id)
        .values(is_read=True)
    )
    await db.commit()
    return {"success": True, "alert_id": alert_id}


# ==========================================
# GARAGE & SERVICE BOOKING
# ==========================================

@router.get("/garages", response_model=list[GarageResponse])
async def list_garages(db: AsyncSession = Depends(get_db)):
    """List nearby partner service centers."""
    result = await db.execute(select(Garage).order_by(Garage.distance_km.asc()))
    return result.scalars().all()


@router.post("/service-bookings", response_model=ServiceBookingResponse)
async def create_service_booking(payload: ServiceBookingCreate, db: AsyncSession = Depends(get_db)):
    """Book a pre-emptive service slot at a partner garage."""
    booking = ServiceBooking(
        car_id=payload.car_id,
        garage_id=payload.garage_id,
        service_type=payload.service_type,
        scheduled_slot=payload.scheduled_slot,
        estimated_cost_inr=payload.estimated_cost_inr,
        notes=payload.notes,
        status="Confirmed",
        created_at=datetime.now(UTC)
    )
    db.add(booking)
    await db.commit()
    await db.refresh(booking)
    return booking


# ==========================================
# PLANS & COMPARISON
# ==========================================

@router.get("/plans")
async def get_plans():
    """Returns AutoPulse product pricing & subscription tiers."""
    return {
        "hardware": {
            "name": "AutoPulse OBD-II Smart Dongle",
            "price_inr": 999,
            "billing": "One-time purchase",
            "warranty": "2-Year Replacement Warranty",
            "compatibility": "All petrol/diesel cars 2013 onwards"
        },
        "subscription": {
            "name": "AutoPulse AI Cloud Intelligence",
            "price_inr": 999,
            "period": "Annual subscription (₹83/month)",
            "features": [
                "Days-to-Failure AI Forecasting for 6 Subsystems",
                "Per-car individualized baseline calibration",
                "Instant roadside breakdown risk alerts",
                "Partner garage priority booking & discount tokens",
                "Detailed diagnostic evidence & savings report"
            ]
        },
        "free_tier": {
            "name": "Basic OBD Scanner",
            "price_inr": 0,
            "features": [
                "Raw OBD-II PIDs live stream",
                "Standard OBD DTC code reading",
                "No predictive analytics or failure forecasting"
            ]
        }
    }


# ==========================================
# FLEET INTELLIGENCE (GARAGE / DEALER VIEW)
# ==========================================

@router.get("/fleet", response_model=FleetSummaryResponse)
async def get_fleet_summary(db: AsyncSession = Depends(get_db)):
    """Returns fleet risk distribution, rankings, and financial savings for dealerships."""
    result = await db.execute(select(Car))
    cars = result.scalars().all()

    fleet_vehicles = []
    crit_count = 0
    watch_count = 0
    healthy_count = 0

    for c in cars:
        sim = get_simulator(c.id)
        current_packet = sim.generate_single_packet()
        summary = engine.evaluate_vehicle_health(
            car_id=c.id,
            current_telemetry=current_packet.to_dict(),
            simulated_day=sim.profile.simulated_day
        )
        
        if summary.overall_status in ["Critical", "Warning"]:
            crit_count += 1
            risk_tier = "High Risk"
        elif summary.overall_status == "Watch":
            watch_count += 1
            risk_tier = "Watchlist"
        else:
            healthy_count += 1
            risk_tier = "Healthy"

        fleet_vehicles.append({
            "car_id": c.id,
            "name": f"{c.make} {c.model} ({c.year})",
            "license_plate": c.license_plate,
            "health_score": summary.overall_health_score,
            "status": summary.overall_status,
            "risk_tier": risk_tier,
            "urgent_forecast": c.urgent_prediction or "All Systems Normal",
            "days_to_failure": summary.urgent_forecast.days_to_failure if summary.urgent_forecast else None,
            "prevented_savings_inr": summary.total_savings_inr,
            "live_pids": {
                "battery": round(current_packet.battery_voltage, 2),
                "coolant": round(current_packet.coolant_temp, 1),
                "rpm": round(current_packet.rpm, 0)
            }
        })

    # Sort strictly by health score ascending (highest risk first)
    fleet_vehicles.sort(key=lambda v: v["health_score"])

    return FleetSummaryResponse(
        total_vehicles=len(fleet_vehicles),
        critical_risk_count=crit_count,
        watchlist_count=watch_count,
        healthy_count=healthy_count,
        prevented_breakdowns_count=14,
        total_fleet_savings_inr=68500,
        average_fleet_health=int(sum(v["health_score"] for v in fleet_vehicles) / max(1, len(fleet_vehicles))),
        vehicles=fleet_vehicles
    )


# ==========================================
# DEMO CONTROLS (TIME LAPSE & FAULT INJECTION)
# ==========================================

@router.post("/demo/inject-fault")
async def demo_inject_fault(payload: DemoFaultInjectionRequest, db: AsyncSession = Depends(get_db)):
    """Secret demo trigger: injects a specific degradation scenario (weak_battery, cooling_fault, etc.)."""
    sim = get_simulator(payload.car_id)
    sim.set_scenario(payload.scenario)

    result = await db.execute(select(Car).where(Car.id == payload.car_id))
    car = result.scalar_one_or_none()
    if car:
        car.active_scenario = payload.scenario
        await db.commit()

    return {
        "success": True,
        "car_id": payload.car_id,
        "active_scenario": payload.scenario,
        "message": f"Injected fault '{payload.scenario}' into {payload.car_id}"
    }


@router.post("/demo/fast-forward")
async def demo_fast_forward(payload: DemoFastForwardRequest, db: AsyncSession = Depends(get_db)):
    """Secret demo trigger: fast-forwards virtual time by N days in seconds."""
    sim = get_simulator(payload.car_id)
    sim.fast_forward(payload.days)

    result = await db.execute(select(Car).where(Car.id == payload.car_id))
    car = result.scalar_one_or_none()
    if car:
        car.simulated_day = sim.profile.simulated_day
        await db.commit()

    # Re-evaluate health after time-forward
    summary = engine.evaluate_vehicle_health(
        car_id=payload.car_id,
        current_telemetry=sim.generate_single_packet().to_dict(),
        simulated_day=sim.profile.simulated_day
    )

    return {
        "success": True,
        "car_id": payload.car_id,
        "simulated_day": sim.profile.simulated_day,
        "new_health_score": summary.overall_health_score,
        "urgent_prediction": summary.urgent_forecast.primary_reason if summary.urgent_forecast else "Normal"
    }


# ==========================================
# WEBSOCKET 1 HZ LIVE TELEMETRY STREAM
# ==========================================

@router.websocket("/ws/telemetry/{car_id}")
async def websocket_telemetry_stream(websocket: WebSocket, car_id: str):
    """
    Continuous 1 Hz WebSocket stream yielding live OBD-II PID packets
    and pushing immediate alert triggers when critical anomaly thresholds are breached.
    """
    await websocket.accept()
    sim = get_simulator(car_id)

    try:
        while True:
            packet = sim.generate_single_packet()
            packet_dict = packet.to_dict()

            # Dynamic check for live alert push
            if packet.battery_voltage < 11.9:
                packet_dict["live_alert"] = {
                    "severity": "critical",
                    "title": "Sub-12V Battery Sag Alert",
                    "message": f"Resting voltage {round(packet.battery_voltage, 2)}V - Morning crank failure risk"
                }
            elif packet.coolant_temp > 98.0:
                packet_dict["live_alert"] = {
                    "severity": "warning",
                    "title": "Coolant Temperature Warning",
                    "message": f"ECT reached {round(packet.coolant_temp, 1)}°C - Thermostat restriction"
                }

            await websocket.send_json(packet_dict)
            await asyncio.sleep(1.0)
    except (WebSocketDisconnect, asyncio.CancelledError):
        pass
