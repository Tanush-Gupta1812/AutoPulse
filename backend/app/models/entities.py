from datetime import UTC, datetime

from backend.app.core.database import Base
from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Index,
    Integer,
    String,
    Text,
)
from sqlalchemy.orm import relationship


class Car(Base):
    __tablename__ = "cars"

    id = Column(String(50), primary_key=True, index=True) # e.g. 'swift_2016'
    vin = Column(String(50), unique=True, nullable=False)
    make = Column(String(50), nullable=False)
    model = Column(String(50), nullable=False)
    year = Column(Integer, nullable=False)
    license_plate = Column(String(20), nullable=False)
    engine_desc = Column(String(100), nullable=False)
    odometer_km = Column(Integer, default=64280)
    
    # Bluetooth Pairing State
    is_paired = Column(Boolean, default=False)
    paired_at = Column(DateTime, nullable=True)
    dongle_mac = Column(String(50), nullable=True)

    # Current Health Snapshot
    current_health_score = Column(Integer, default=100)
    current_status = Column(String(20), default="OK")
    urgent_prediction = Column(String(255), nullable=True)
    active_scenario = Column(String(50), default="healthy")
    simulated_day = Column(Float, default=0.0)

    # Relationships
    telemetry_records = relationship("TelemetryRecord", back_populates="car", cascade="all, delete-orphan")
    alerts = relationship("Alert", back_populates="car", cascade="all, delete-orphan")
    service_bookings = relationship("ServiceBooking", back_populates="car", cascade="all, delete-orphan")


class TelemetryRecord(Base):
    """
    Time-series table holding 1 Hz OBD-II PID streams.
    Compound indexed on (car_id, timestamp) for rapid range and sparkline queries.
    """
    __tablename__ = "telemetry_records"

    id = Column(Integer, primary_key=True, autoincrement=True)
    car_id = Column(String(50), ForeignKey("cars.id", ondelete="CASCADE"), nullable=False, index=True)
    timestamp = Column(DateTime, default=lambda: datetime.now(UTC), nullable=False, index=True)
    
    rpm = Column(Float, nullable=False)
    speed = Column(Float, nullable=False)
    coolant_temp = Column(Float, nullable=False)
    engine_load = Column(Float, nullable=False)
    battery_voltage = Column(Float, nullable=False)
    intake_air_temp = Column(Float, nullable=False)
    short_fuel_trim = Column(Float, nullable=False)
    long_fuel_trim = Column(Float, nullable=False)
    maf = Column(Float, nullable=False)
    throttle_pos = Column(Float, nullable=False)
    o2_voltage = Column(Float, nullable=False)
    engine_on = Column(Boolean, default=True)
    simulated_day = Column(Float, default=0.0)

    car = relationship("Car", back_populates="telemetry_records")

    __table_args__ = (
        Index("ix_telemetry_car_timestamp", "car_id", "timestamp"),
    )


class ComponentHealth(Base):
    __tablename__ = "component_health"

    id = Column(Integer, primary_key=True, autoincrement=True)
    car_id = Column(String(50), ForeignKey("cars.id", ondelete="CASCADE"), nullable=False, index=True)
    component_name = Column(String(100), nullable=False)
    health_score = Column(Integer, nullable=False)
    status = Column(String(20), nullable=False)
    days_to_failure = Column(Integer, nullable=True)
    confidence_pct = Column(Integer, default=90)
    primary_reason = Column(Text, nullable=False)
    prevented_cost_inr = Column(Integer, default=0)
    last_updated = Column(DateTime, default=lambda: datetime.now(UTC))


class Alert(Base):
    __tablename__ = "alerts"

    id = Column(Integer, primary_key=True, autoincrement=True)
    car_id = Column(String(50), ForeignKey("cars.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String(150), nullable=False)
    message = Column(Text, nullable=False)
    severity = Column(String(20), nullable=False) # info, watch, warning, critical
    component_name = Column(String(100), nullable=False)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=lambda: datetime.now(UTC), index=True)

    car = relationship("Car", back_populates="alerts")


class Garage(Base):
    __tablename__ = "garages"

    id = Column(String(50), primary_key=True)
    name = Column(String(150), nullable=False)
    address = Column(String(255), nullable=False)
    distance_km = Column(Float, nullable=False)
    rating = Column(Float, default=4.8)
    is_partner = Column(Boolean, default=True)
    specializations = Column(String(255), default="Multi-brand, Electrical, Diagnostics")
    phone = Column(String(20), default="+91 98765 43210")

    bookings = relationship("ServiceBooking", back_populates="garage")


class ServiceBooking(Base):
    __tablename__ = "service_bookings"

    id = Column(Integer, primary_key=True, autoincrement=True)
    car_id = Column(String(50), ForeignKey("cars.id", ondelete="CASCADE"), nullable=False, index=True)
    garage_id = Column(String(50), ForeignKey("garages.id"), nullable=False)
    service_type = Column(String(100), nullable=False)
    scheduled_slot = Column(String(100), nullable=False)
    status = Column(String(50), default="Confirmed")
    estimated_cost_inr = Column(Integer, default=3200)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=lambda: datetime.now(UTC))

    car = relationship("Car", back_populates="service_bookings")
    garage = relationship("Garage", back_populates="bookings")
