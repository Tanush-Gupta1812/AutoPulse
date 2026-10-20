"""
Unit Tests for AutoPulse Prediction Engine
Verifies component anomaly detection, days-to-failure calculations, and health scoring.
"""

import pytest
from backend.app.engine.prediction_engine import PredictionEngine


@pytest.fixture
def engine():
    return PredictionEngine()


def test_battery_evaluation_weak_battery(engine):
    """Maruti Swift case: 11.8V resting voltage on day 12 should predict ~9 days to failure."""
    forecast = engine.evaluate_battery(
        car_id="swift_2016",
        current_voltage=11.8,
        simulated_day=12.0,
        baseline_voltage=12.6
    )

    assert forecast.component_name == "Battery & Electrical"
    assert forecast.status in ["Warning", "Critical"]
    assert forecast.health_score <= 65
    assert forecast.days_to_failure is not None
    assert 7 <= forecast.days_to_failure <= 11  # Around ~9 days!
    assert forecast.confidence_pct >= 90
    assert "0.6" in forecast.primary_reason or "voltage" in forecast.primary_reason
    assert forecast.prevented_cost_inr == 4500
    assert len(forecast.diagnostic_evidence) >= 2


def test_battery_evaluation_healthy(engine):
    """Healthy battery at 12.6V should be OK with no failure forecast."""
    forecast = engine.evaluate_battery(
        car_id="baleno_2019",
        current_voltage=12.6,
        simulated_day=0.0,
        baseline_voltage=12.6
    )

    assert forecast.status == "OK"
    assert forecast.health_score >= 90
    assert forecast.days_to_failure is None


def test_cooling_system_evaluation(engine):
    """Cooling fault at 104°C should flag Warning / Critical with boilover risk."""
    forecast = engine.evaluate_cooling(
        car_id="i20_2018",
        current_temp=104.0,
        simulated_day=8.0,
        baseline_temp=89.0
    )

    assert forecast.component_name == "Cooling System"
    assert forecast.status in ["Warning", "Critical"]
    assert forecast.health_score <= 65
    assert forecast.days_to_failure is not None
    assert forecast.prevented_cost_inr >= 10000


def test_vehicle_health_summary_aggregation(engine):
    """Overall vehicle health aggregates weakest component and selects urgent forecast."""
    telemetry = {
        "battery_voltage": 11.8,
        "coolant_temp": 92.0,
        "short_fuel_trim": 1.0,
        "long_fuel_trim": 1.2,
        "rpm": 780.0,
        "engine_load": 22.0
    }
    summary = engine.evaluate_vehicle_health("swift_2016", telemetry, simulated_day=12.0)

    assert summary.car_id == "swift_2016"
    assert summary.overall_health_score < 75
    assert summary.urgent_forecast is not None
    assert summary.urgent_forecast.component_name == "Battery & Electrical"
    assert summary.urgent_forecast.days_to_failure is not None
