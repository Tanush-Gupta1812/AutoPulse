from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict


class CarBase(BaseModel):
    id: str
    vin: str
    make: str
    model: str
    year: int
    license_plate: str
    engine_desc: str
    odometer_km: int = 64280
    is_paired: bool = False
    dongle_mac: str | None = None
    current_health_score: int = 100
    current_status: str = "OK"
    urgent_prediction: str | None = None
    active_scenario: str = "healthy"
    simulated_day: float = 0.0


class CarResponse(CarBase):
    paired_at: datetime | None = None
    model_config = ConfigDict(from_attributes=True)


class PairingRequest(BaseModel):
    dongle_mac: str = "00:1D:A5:68:98:8B"


class PairingResponse(BaseModel):
    success: bool
    car_id: str
    dongle_mac: str
    paired_at: str
    status: str
    message: str


class TelemetryPacketSchema(BaseModel):
    car_id: str
    timestamp: str
    rpm: float
    speed: float
    coolant_temp: float
    engine_load: float
    battery_voltage: float
    intake_air_temp: float
    short_fuel_trim: float
    long_fuel_trim: float
    maf: float
    throttle_pos: float
    o2_voltage: float
    engine_on: bool
    simulated_day: float


class ComponentDetailSchema(BaseModel):
    component_name: str
    health_score: int
    status: str
    days_to_failure: int | None
    confidence_pct: int
    primary_reason: str
    diagnostic_evidence: list[str]
    prevented_cost_inr: int
    planned_service_cost_inr: int
    emergency_breakdown_cost_inr: int
    trend_history_30d: list[dict[str, Any]]


class VehicleHealthResponse(BaseModel):
    car_id: str
    overall_health_score: int
    overall_status: str
    urgent_forecast: ComponentDetailSchema | None
    components: list[ComponentDetailSchema]
    active_alerts_count: int
    total_savings_inr: int
    timestamp: str


class AlertResponse(BaseModel):
    id: int
    car_id: str
    title: str
    message: str
    severity: str
    component_name: str
    is_read: bool
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class GarageResponse(BaseModel):
    id: str
    name: str
    address: str
    distance_km: float
    rating: float
    is_partner: bool
    specializations: str
    phone: str
    model_config = ConfigDict(from_attributes=True)


class ServiceBookingCreate(BaseModel):
    car_id: str
    garage_id: str
    service_type: str
    scheduled_slot: str
    estimated_cost_inr: int = 3200
    notes: str | None = None


class ServiceBookingResponse(BaseModel):
    id: int
    car_id: str
    garage_id: str
    service_type: str
    scheduled_slot: str
    status: str
    estimated_cost_inr: int
    notes: str | None
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class DemoFaultInjectionRequest(BaseModel):
    car_id: str
    scenario: str # weak_battery, cooling_fault, o2_sensor_aging, spark_plug_wear, alternator_weakness, healthy


class DemoFastForwardRequest(BaseModel):
    car_id: str
    days: float = 7.0


class FleetSummaryResponse(BaseModel):
    total_vehicles: int
    critical_risk_count: int
    watchlist_count: int
    healthy_count: int
    prevented_breakdowns_count: int
    total_fleet_savings_inr: int
    average_fleet_health: int
    vehicles: list[dict[str, Any]]
