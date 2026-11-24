"""Aggregated fleet metrics for the dashboard."""

from datetime import UTC, datetime

from fastapi import APIRouter

from app.api.deps import StoreDep
from app.schemas import MetricsSummary, SiteStatus

router = APIRouter(prefix="/metrics", tags=["metrics"])


@router.get("/summary", response_model=MetricsSummary, summary="Fleet summary")
async def summary(store: StoreDep) -> MetricsSummary:
    sites = store.list()
    return MetricsSummary(
        site_count=len(sites),
        online_count=sum(site.status is SiteStatus.ONLINE for site in sites),
        total_capacity_kw=round(sum(site.capacity_kw for site in sites), 1),
        today_kwh=round(sum(site.today_kwh for site in sites), 1),
        updated_at=datetime.now(UTC),
    )
