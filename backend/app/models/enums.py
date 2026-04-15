"""Shared enums for the LOKAL domain."""
from enum import Enum


class UserMode(str, Enum):
    """Runtime mode toggle — a user can flip between these any time."""
    CONSUMER = "consumer"
    PROVIDER = "provider"


class ServiceCategory(str, Enum):
    """Top-level provider categories. A user can hold N of these
    simultaneously — the whole point of LOKAL."""
    RIDE_DELIVERY = "ride_delivery"
    TECHIE = "techie"
    SUPPORT_PARTNER = "support_partner"
    NON_TECH = "non_tech"


class VerificationStatus(str, Enum):
    PENDING = "pending"
    SUBMITTED = "submitted"
    VERIFIED = "verified"
    REJECTED = "rejected"


class RequestStatus(str, Enum):
    DRAFT = "draft"
    OPEN = "open"
    MATCHED = "matched"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"
