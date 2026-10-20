"""
AutoPulse Telemetry Source Interface
Abstracts OBD-II data retrieval so AutoPulse can switch between:
1. SimulatedSource (MVP prototype / automated demo testing)
2. BleObdSource (Production hardware using ELM327 Bluetooth Low Energy dongle)
"""

from abc import ABC, abstractmethod
from collections.abc import AsyncGenerator
from dataclasses import dataclass
from datetime import datetime
from typing import Any


@dataclass
class TelemetryPacket:
    car_id: str
    timestamp: datetime
    rpm: float                    # PID 0x0C (Engine RPM)
    speed: float                  # PID 0x0D (Vehicle Speed, km/h)
    coolant_temp: float           # PID 0x05 (Engine Coolant Temperature, °C)
    engine_load: float            # PID 0x04 (Calculated Engine Load, %)
    battery_voltage: float        # OBD battery voltage (Pin 16 / ELM327 'AT RV', Volts)
    intake_air_temp: float        # PID 0x0F (Intake Air Temperature, °C)
    short_fuel_trim: float        # PID 0x06 (Short Term Fuel Trim Bank 1, %)
    long_fuel_trim: float         # PID 0x07 (Long Term Fuel Trim Bank 1, %)
    maf: float                    # PID 0x10 (Mass Air Flow rate, g/s)
    throttle_pos: float           # PID 0x11 (Throttle Position, %)
    o2_voltage: float             # PID 0x14 (O2 Sensor Bank 1 Sensor 1, Volts)
    engine_on: bool               # Engine running flag
    simulated_day: float = 0.0    # Virtual time index for degradation scenarios

    def to_dict(self) -> dict[str, Any]:
        return {
            "car_id": self.car_id,
            "timestamp": self.timestamp.isoformat(),
            "rpm": round(self.rpm, 1),
            "speed": round(self.speed, 1),
            "coolant_temp": round(self.coolant_temp, 1),
            "engine_load": round(self.engine_load, 1),
            "battery_voltage": round(self.battery_voltage, 2),
            "intake_air_temp": round(self.intake_air_temp, 1),
            "short_fuel_trim": round(self.short_fuel_trim, 2),
            "long_fuel_trim": round(self.long_fuel_trim, 2),
            "maf": round(self.maf, 2),
            "throttle_pos": round(self.throttle_pos, 1),
            "o2_voltage": round(self.o2_voltage, 3),
            "engine_on": self.engine_on,
            "simulated_day": round(self.simulated_day, 2)
        }


class TelemetrySource(ABC):
    """Abstract telemetry source interface."""

    @abstractmethod
    async def connect(self, device_id: str) -> bool:
        """Connect to device (BLE MAC address or virtual Car ID)."""

    @abstractmethod
    async def disconnect(self) -> None:
        """Disconnect telemetry source."""

    @abstractmethod
    async def stream_telemetry(self) -> AsyncGenerator[TelemetryPacket, None]:
        """Yield 1 Hz live telemetry packets."""

    @abstractmethod
    def is_connected(self) -> bool:
        """Return connectivity status."""
