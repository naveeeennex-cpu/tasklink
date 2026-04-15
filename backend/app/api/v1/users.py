"""User profile endpoints."""
from fastapi import APIRouter, Depends, HTTPException

from ...core.supabase_client import service_client
from ...models.enums import UserMode
from ..deps import current_user_id

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me")
async def get_me(user_id: str = Depends(current_user_id)):
    sb = service_client()
    if sb is None:
        raise HTTPException(503, "Supabase not configured")
    row = sb.table("users").select("*").eq("id", user_id).single().execute()
    if row.data is None:
        raise HTTPException(404, "User profile not found")
    return row.data


@router.patch("/me/mode")
async def set_active_mode(
    mode: UserMode,
    user_id: str = Depends(current_user_id),
):
    """Flip between consumer and provider mode.

    Note: the toggle itself is free. If the user has no service profiles
    yet and flips to PROVIDER, the *client* is responsible for routing
    into the onboarding flow. The server just stores the intent.
    """
    sb = service_client()
    if sb is None:
        raise HTTPException(503, "Supabase not configured")
    sb.table("users").update({"active_mode": mode.value}).eq("id", user_id).execute()
    return {"active_mode": mode.value}
