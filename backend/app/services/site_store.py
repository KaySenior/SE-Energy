"""In-memory site store.

This keeps the starter project self-contained. Replace `SiteStore` with a
database-backed repository (SQLModel/SQLAlchemy) when persistence is needed;
the API layer only depends on the small interface below.
"""

from datetime import UTC, datetime
from uuid import UUID, uuid4

from app.schemas import Site, SiteCreate, SiteStatus

_SEEDED_SITES = [
    {
        "id": UUID("0d7f1a3e-3f0a-4c9a-9d1e-4a2b6c8d0e01"),
        "name": "Rooftop Solar A",
        "location": "Accra, GH",
        "capacity_kw": 250.0,
        "status": SiteStatus.ONLINE,
        "today_kwh": 812.4,
        "created_at": datetime(2026, 1, 15, 9, 30, tzinfo=UTC),
    },
    {
        "id": UUID("9b2c4d6e-8f0a-4b1c-8d2e-6f8a0c2e4b02"),
        "name": "Harbour Storage",
        "location": "Tema, GH",
        "capacity_kw": 1200.0,
        "status": SiteStatus.DEGRADED,
        "today_kwh": 2310.9,
        "created_at": datetime(2026, 2, 2, 14, 10, tzinfo=UTC),
    },
    {
        "id": UUID("5e6f7a8b-9c0d-4e1f-8a2b-3c4d5e6f7a03"),
        "name": "Kumasi Microgrid",
        "location": "Kumasi, GH",
        "capacity_kw": 480.0,
        "status": SiteStatus.OFFLINE,
        "today_kwh": 0.0,
        "created_at": datetime(2026, 3, 21, 7, 45, tzinfo=UTC),
    },
]


class SiteStore:
    """Thread-safe-enough in-memory collection for local development."""

    def __init__(self) -> None:
        self._sites: dict[UUID, Site] = {}

    @classmethod
    def seeded(cls) -> "SiteStore":
        store = cls()
        for row in _SEEDED_SITES:
            site = Site(**row)
            store._sites[site.id] = site
        return store

    def list(self) -> list[Site]:
        return sorted(self._sites.values(), key=lambda site: site.created_at)

    def get(self, site_id: UUID) -> Site | None:
        return self._sites.get(site_id)

    def create(self, payload: SiteCreate) -> Site:
        site = Site(
            id=uuid4(),
            created_at=datetime.now(UTC),
            **payload.model_dump(),
        )
        self._sites[site.id] = site
        return site

    def delete(self, site_id: UUID) -> bool:
        return self._sites.pop(site_id, None) is not None
