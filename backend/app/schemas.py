"""Pydantic schemas for the public API."""

from datetime import datetime
from enum import StrEnum
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class SiteStatus(StrEnum):
    ONLINE = "online"
    DEGRADED = "degraded"
    OFFLINE = "offline"
    MAINTENANCE = "maintenance"


class SiteBase(BaseModel):
    name: str = Field(min_length=1, max_length=120, examples=["Rooftop Solar A"])
    location: str = Field(min_length=1, max_length=160, examples=["Accra, GH"])
    capacity_kw: float = Field(gt=0, le=1_000_000, examples=[250.0])
    status: SiteStatus = SiteStatus.ONLINE
    today_kwh: float = Field(default=0.0, ge=0, examples=[812.4])


class SiteCreate(SiteBase):
    """Payload accepted when registering a new site."""


class Site(SiteBase):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    created_at: datetime


class MetricsSummary(BaseModel):
    site_count: int = Field(ge=0)
    online_count: int = Field(ge=0)
    total_capacity_kw: float = Field(ge=0)
    today_kwh: float = Field(ge=0)
    updated_at: datetime


class HealthStatus(BaseModel):
    status: str
    service: str
    version: str
    environment: str
    timestamp: datetime
