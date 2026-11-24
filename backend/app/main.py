"""FastAPI application factory and default ASGI app."""

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import health, metrics, sites
from app.core.config import Settings, get_settings
from app.services.site_store import SiteStore


def create_app(settings: Settings | None = None) -> FastAPI:
    """Build the application.

    Kept as a factory so tests (and future workers) can create isolated
    instances with their own settings and store.
    """
    resolved = settings or get_settings()

    @asynccontextmanager
    async def lifespan(application: FastAPI) -> AsyncIterator[None]:
        application.state.settings = resolved
        application.state.store = SiteStore.seeded()
        yield

    application = FastAPI(
        title=resolved.app_name,
        version=resolved.version,
        debug=resolved.debug,
        lifespan=lifespan,
    )

    application.add_middleware(
        CORSMiddleware,
        allow_origins=resolved.cors_origins,
        allow_origin_regex=resolved.cors_origin_regex,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    application.include_router(health.router)
    application.include_router(sites.router, prefix=resolved.api_v1_prefix)
    application.include_router(metrics.router, prefix=resolved.api_v1_prefix)
    return application


app = create_app()
