"""User + auth schemas."""
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field

from .enums import UserMode, VerificationStatus


class SignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    full_name: str = Field(min_length=1, max_length=120)
    phone: str | None = Field(default=None, max_length=20)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class GoogleLoginRequest(BaseModel):
    id_token: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class AuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    user_id: UUID
    email: EmailStr
    is_new_user: bool = False


class UserProfile(BaseModel):
    id: UUID
    email: EmailStr
    full_name: str
    phone: str | None = None
    avatar_url: str | None = None
    active_mode: UserMode = UserMode.CONSUMER
    kyc_status: VerificationStatus = VerificationStatus.PENDING
    created_at: datetime
    updated_at: datetime
