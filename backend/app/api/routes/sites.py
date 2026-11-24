"""Site registration and lookup endpoints."""

from uuid import UUID

from fastapi import APIRouter, HTTPException, status

from app.api.deps import StoreDep
from app.schemas import Site, SiteCreate

router = APIRouter(prefix="/sites", tags=["sites"])


@router.get("", response_model=list[Site], summary="List sites")
async def list_sites(store: StoreDep) -> list[Site]:
    return store.list()


@router.post(
    "",
    response_model=Site,
    status_code=status.HTTP_201_CREATED,
    summary="Register a site",
)
async def create_site(payload: SiteCreate, store: StoreDep) -> Site:
    return store.create(payload)


@router.get("/{site_id}", response_model=Site, summary="Get a site")
async def get_site(site_id: UUID, store: StoreDep) -> Site:
    site = store.get(site_id)
    if site is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Site not found")
    return site


@router.delete(
    "/{site_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete a site",
)
async def delete_site(site_id: UUID, store: StoreDep) -> None:
    if not store.delete(site_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Site not found")
