"""Service-request endpoints — a consumer posts, matching finds a provider."""
from fastapi import APIRouter, Depends, HTTPException

from ...core.supabase_client import service_client
from ...models.enums import RequestStatus, ServiceCategory
from ...models.service_request import ServiceRequestCreate
from ..deps import current_user_id

router = APIRouter(prefix="/requests", tags=["service_requests"])


def _sb():
    sb = service_client()
    if sb is None:
        raise HTTPException(503, "Supabase not configured")
    return sb


@router.post("", status_code=201)
async def create_request(
    body: ServiceRequestCreate,
    user_id: str = Depends(current_user_id),
):
    sb = _sb()
    payload = {
        "consumer_id": user_id,
        "category": body.category.value,
        "title": body.title,
        "description": body.description,
        "pickup": body.pickup.model_dump(mode="json") if body.pickup else None,
        # NB: `drop` is a SQL reserved word, table column is `drop_off`.
        "drop_off": body.drop.model_dump(mode="json") if body.drop else None,
        "scheduled_for": body.scheduled_for.isoformat() if body.scheduled_for else None,
        "budget_inr": body.budget_inr,
        "status": RequestStatus.OPEN.value,
    }
    inserted = sb.table("service_requests").insert(payload).execute()
    return inserted.data[0] if inserted.data else {}


@router.get("/mine")
async def list_my_requests(user_id: str = Depends(current_user_id)):
    """Requests I posted as a consumer."""
    sb = _sb()
    rows = (
        sb.table("service_requests")
        .select("*")
        .eq("consumer_id", user_id)
        .order("created_at", desc=True)
        .execute()
    )
    return rows.data or []


@router.get("/feed")
async def provider_feed(
    category: ServiceCategory,
    user_id: str = Depends(current_user_id),
):
    """Open requests matching a category — what a provider sees on their Home."""
    sb = _sb()
    rows = (
        sb.table("service_requests")
        .select("*")
        .eq("category", category.value)
        .eq("status", RequestStatus.OPEN.value)
        .order("created_at", desc=True)
        .limit(50)
        .execute()
    )
    return rows.data or []
