"""API tests exercising the app through its public HTTP surface."""

from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient

from app.core.config import Settings
from app.main import create_app


@pytest.fixture
def client() -> Iterator[TestClient]:
    app = create_app(Settings(environment="local", debug=False))
    with TestClient(app) as test_client:
        yield test_client


def test_index(client: TestClient) -> None:
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["health"] == "/health"


def test_health(client: TestClient) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["environment"] == "local"


def test_list_sites_is_seeded(client: TestClient) -> None:
    response = client.get("/api/v1/sites")
    assert response.status_code == 200
    assert len(response.json()) == 3


def test_metrics_reflect_seed_data(client: TestClient) -> None:
    response = client.get("/api/v1/metrics/summary")
    assert response.status_code == 200
    body = response.json()
    assert body["site_count"] == 3
    assert body["online_count"] == 1
    assert body["total_capacity_kw"] == 1930.0


def test_create_then_fetch_site(client: TestClient) -> None:
    payload = {
        "name": "Test Array",
        "location": "Takoradi, GH",
        "capacity_kw": 42.5,
        "status": "online",
        "today_kwh": 12.0,
    }
    created = client.post("/api/v1/sites", json=payload)
    assert created.status_code == 201
    site = created.json()
    assert site["name"] == payload["name"]

    fetched = client.get(f"/api/v1/sites/{site['id']}")
    assert fetched.status_code == 200
    assert fetched.json()["id"] == site["id"]


def test_create_site_validates_capacity(client: TestClient) -> None:
    response = client.post(
        "/api/v1/sites",
        json={"name": "Bad", "location": "Nowhere", "capacity_kw": -1},
    )
    assert response.status_code == 422


def test_unknown_site_returns_404(client: TestClient) -> None:
    response = client.get("/api/v1/sites/00000000-0000-4000-8000-000000000000")
    assert response.status_code == 404


def test_delete_site(client: TestClient) -> None:
    sites = client.get("/api/v1/sites").json()
    site_id = sites[0]["id"]

    assert client.delete(f"/api/v1/sites/{site_id}").status_code == 204
    assert client.get(f"/api/v1/sites/{site_id}").status_code == 404
