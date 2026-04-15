"""Service-profile endpoints — the polymorphic heart of LOKAL.

A user can hold multiple profiles simultaneously (one per category).
"""
from fastapi import APIRouter, Depends, HTTPException

from ...core.supabase_client import service_client
from ...models.enums import ServiceCategory
from ...models.service_profile import (
    ServiceProfileCreate,
    ServiceProfileUpdate,
)
from ..deps import current_user_id

router = APIRouter(prefix="/profiles", tags=["service_profiles"])


def _sb():
    sb = service_client()
    if sb is None:
        raise HTTPException(503, "Supabase not configured")
    return sb


@router.get("")
async def list_my_profiles(user_id: str = Depends(current_user_id)):
    """All service profiles the current user offers."""
    sb = _sb()
    rows = sb.table("service_profiles").select("*").eq("user_id", user_id).execute()
    return rows.data or []


@router.post("", status_code=201)
async def create_profile(
    body: ServiceProfileCreate,
    user_id: str = Depends(current_user_id),
):
    sb = _sb()
    category = body.details.category
    existing = (
        sb.table("service_profiles")
        .select("id")
        .eq("user_id", user_id)
        .eq("category", category.value)
        .execute()
    )
    if existing.data:
        raise HTTPException(
            409,
            f"You already have a {category.value} profile. Use PATCH to update it.",
        )
    inserted = (
        sb.table("service_profiles")
        .insert(
            {
                "user_id": user_id,
                "category": category.value,
                "details": body.details.model_dump(mode="json"),
                "is_active": False,
            }
        )
        .execute()
    )
    return inserted.data[0] if inserted.data else {}


@router.patch("/{category}")
async def update_profile(
    category: ServiceCategory,
    body: ServiceProfileUpdate,
    user_id: str = Depends(current_user_id),
):
    sb = _sb()
    patch: dict = {}
    if body.details is not None:
        patch["details"] = body.details.model_dump(mode="json")
    if body.is_active is not None:
        patch["is_active"] = body.is_active
    if not patch:
        raise HTTPException(400, "Nothing to update")
    result = (
        sb.table("service_profiles")
        .update(patch)
        .eq("user_id", user_id)
        .eq("category", category.value)
        .execute()
    )
    if not result.data:
        raise HTTPException(404, "Profile not found")
    return result.data[0]


@router.delete("/{category}", status_code=204)
async def delete_profile(
    category: ServiceCategory,
    user_id: str = Depends(current_user_id),
):
    sb = _sb()
    sb.table("service_profiles").delete().eq("user_id", user_id).eq(
        "category", category.value
    ).execute()
    return None
