"""Shared FastAPI dependencies and annotated aliases."""

from typing import Annotated

from fastapi import Depends, Request

from app.core.config import Settings
from app.services.site_store import SiteStore


def get_store(request: Request) -> SiteStore:
    """Return the site store attached to the running application."""
    return request.app.state.store


def get_app_settings(request: Request) -> Settings:
    """Return the settings the current application was created with."""
    return request.app.state.settings


SettingsDep = Annotated[Settings, Depends(get_app_settings)]
StoreDep = Annotated[SiteStore, Depends(get_store)]
