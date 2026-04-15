"""Service-profile schemas.

Design note: a user owns N service profiles, one per category they offer.
Each profile carries category-specific `details` (polymorphic JSONB in
Postgres) plus shared fields like pricing, rating, availability.

Keeping the vertical-specific payload as a discriminated union keeps the
API strictly typed without needing four parallel tables.
"""
from datetime import datetime
from typing import Annotated, Literal, Union
from uuid import UUID

from pydantic import BaseModel, Field

from .enums import ServiceCategory, VerificationStatus


# ── Ride & Delivery ─────────────────────────────────────────────────
class RideDeliveryDetails(BaseModel):
    category: Literal[ServiceCategory.RIDE_DELIVERY] = ServiceCategory.RIDE_DELIVERY
    vehicle_type: str  # bike / auto / car / van
    vehicle_number: str
    license_number: str
    rc_document_url: str | None = None
    insurance_document_url: str | None = None
    insurance_expires_on: datetime | None = None


# ── Techie ──────────────────────────────────────────────────────────
class TechieDetails(BaseModel):
    category: Literal[ServiceCategory.TECHIE] = ServiceCategory.TECHIE
    skills: list[str]  # ["flutter", "react", "figma"]
    sub_skills: list[str] = Field(default_factory=list)
    portfolio_url: str | None = None
    years_experience: int = 0
    hourly_rate_inr: int | None = None
    project_min_inr: int | None = None


# ── Support Partner ─────────────────────────────────────────────────
class SupportPartnerDetails(BaseModel):
    category: Literal[ServiceCategory.SUPPORT_PARTNER] = ServiceCategory.SUPPORT_PARTNER
    languages: list[str]
    personality_tags: list[str] = Field(default_factory=list)  # calm, chatty, patient
    preferences: list[str] = Field(default_factory=list)  # walk, shopping, talk
    hourly_rate_inr: int | None = None


# ── Non-Tech ────────────────────────────────────────────────────────
class NonTechDetails(BaseModel):
    category: Literal[ServiceCategory.NON_TECH] = ServiceCategory.NON_TECH
    trade: str  # plumber / electrician / ac_repair / cleaning / etc.
    years_experience: int = 0
    visit_fee_inr: int | None = None
    hourly_rate_inr: int | None = None


ServiceProfileDetails = Annotated[
    Union[
        RideDeliveryDetails,
        TechieDetails,
        SupportPartnerDetails,
        NonTechDetails,
    ],
    Field(discriminator="category"),
]


# ── Profile envelope ────────────────────────────────────────────────
class ServiceProfile(BaseModel):
    id: UUID
    user_id: UUID
    category: ServiceCategory
    details: ServiceProfileDetails
    is_active: bool = False  # provider currently accepting jobs for this category
    verification_status: VerificationStatus = VerificationStatus.PENDING
    rating_avg: float = 0.0
    jobs_completed: int = 0
    created_at: datetime
    updated_at: datetime


class ServiceProfileCreate(BaseModel):
    details: ServiceProfileDetails


class ServiceProfileUpdate(BaseModel):
    details: ServiceProfileDetails | None = None
    is_active: bool | None = None
