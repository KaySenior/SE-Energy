"""Health and service metadata endpoints."""

from datetime import UTC, datetime

from fastapi import APIRouter

from app.api.deps import SettingsDep
from app.schemas import HealthStatus

router = APIRouter(tags=["meta"])


@router.get("/", summary="Service index")
async def index(settings: SettingsDep) -> dict[str, str]:
    return {
        "service": settings.app_name,
        "version": settings.version,
        "docs": "/docs",
        "health": "/health",
    }


@router.get("/health", response_model=HealthStatus, summary="Liveness probe")
async def health(settings: SettingsDep) -> HealthStatus:
    return HealthStatus(
        status="ok",
        service=settings.app_name,
        version=settings.version,
        environment=settings.environment,
        timestamp=datetime.now(UTC),
    )
