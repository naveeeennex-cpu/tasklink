"""Service-request schemas — what a consumer posts, what a provider accepts."""
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from .enums import RequestStatus, ServiceCategory


class GeoPoint(BaseModel):
    lat: float = Field(ge=-90, le=90)
    lng: float = Field(ge=-180, le=180)
    address: str | None = None


class ServiceRequestCreate(BaseModel):
    category: ServiceCategory
    title: str = Field(min_length=3, max_length=140)
    description: str | None = None
    pickup: GeoPoint | None = None
    drop: GeoPoint | None = None
    scheduled_for: datetime | None = None  # null = ASAP
    budget_inr: int | None = None


class ServiceRequest(BaseModel):
    id: UUID
    consumer_id: UUID
    provider_id: UUID | None = None
    category: ServiceCategory
    title: str
    description: str | None = None
    pickup: GeoPoint | None = None
    drop: GeoPoint | None = None
    scheduled_for: datetime | None = None
    budget_inr: int | None = None
    status: RequestStatus = RequestStatus.OPEN
    created_at: datetime
    updated_at: datetime
