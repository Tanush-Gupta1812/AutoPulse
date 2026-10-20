"""
Integration & Functional API Tests for AutoPulse
Tests FastAPI endpoints, health forecasts, mock pairing, garage bookings, and demo controls.
"""

import pytest
from backend.app.main import app
from httpx import ASGITransport, AsyncClient


@pytest.fixture
def anyio_backend():
    return "asyncio"


class MockSession:
    async def execute(self, *args, **kwargs):
        class MockResult:
            def scalars(self):
                return self

            def all(self):
                return []

            def scalar_one_or_none(self):
                return None

        return MockResult()

    async def commit(self):
        pass

    async def close(self):
        pass


@pytest.fixture(autouse=True)
def override_db():
    from backend.app.core.database import get_db

    async def _mock_get_db():
        yield MockSession()

    app.dependency_overrides[get_db] = _mock_get_db
    yield
    app.dependency_overrides.clear()


@pytest.mark.anyio
async def test_health_check():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "AutoPulse" in data["service"]


@pytest.mark.anyio
async def test_plans_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/api/plans")
        assert response.status_code == 200
        data = response.json()
        assert data["hardware"]["price_inr"] == 999
        assert data["subscription"]["price_inr"] == 999


@pytest.mark.anyio
async def test_latest_telemetry():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/api/cars/swift_2016/telemetry/latest")
        assert response.status_code == 200
        pkt = response.json()
        assert pkt["car_id"] == "swift_2016"
        assert "rpm" in pkt
        assert "battery_voltage" in pkt
        assert "coolant_temp" in pkt


@pytest.mark.anyio
async def test_component_detail_battery():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/api/cars/swift_2016/components/Battery")
        assert response.status_code == 200
        comp = response.json()
        assert "Battery" in comp["component_name"]
        assert comp["health_score"] <= 75
        assert comp["confidence_pct"] >= 80
        assert comp["prevented_cost_inr"] == 4500
        assert len(comp["diagnostic_evidence"]) >= 1


@pytest.mark.anyio
async def test_demo_controls():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        # Test fault injection
        inject_res = await ac.post(
            "/api/demo/inject-fault",
            json={"car_id": "swift_2016", "scenario": "cooling_fault"}
        )
        assert inject_res.status_code == 200
        assert inject_res.json()["active_scenario"] == "cooling_fault"

        # Test fast-forward
        ff_res = await ac.post(
            "/api/demo/fast-forward",
            json={"car_id": "swift_2016", "days": 5.0}
        )
        assert ff_res.status_code == 200
        assert ff_res.json()["simulated_day"] >= 15.0
