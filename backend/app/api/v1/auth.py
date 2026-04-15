"""Auth endpoints — email/password + Google.

Wraps Supabase Auth. Handles the "user created but awaiting email
confirmation" case explicitly so the mobile client can show a proper
"check your inbox" screen instead of a generic error.
"""
from fastapi import APIRouter, HTTPException, status
from supabase import create_client

from ...core.config import get_settings
from ...core.supabase_client import service_client
from ...models.user import (
    AuthResponse,
    ForgotPasswordRequest,
    GoogleLoginRequest,
    LoginRequest,
    SignupRequest,
)

router = APIRouter(prefix="/auth", tags=["auth"])


def _require_supabase():
    sb = service_client()
    if sb is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Supabase not configured. Fill SUPABASE_* in backend/.env.",
        )
    return sb


@router.post("/signup")
async def signup(body: SignupRequest):
    """Create a new auth user + public.users row.

    Behaviour depends on Supabase "Confirm email" setting:

    * **Confirm email OFF** — we get back a session immediately, return
      `AuthResponse` with tokens (client can log in directly).
    * **Confirm email ON** — Supabase sends a confirmation email and
      returns no session. We return `{awaits_confirmation: true}` so the
      client renders a "check your inbox" state instead of erroring.
    """
    sb = _require_supabase()
    try:
        result = sb.auth.sign_up(
            {
                "email": body.email,
                "password": body.password,
                "options": {
                    "data": {
                        "full_name": body.full_name,
                        "phone": body.phone,
                    }
                },
            }
        )
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    if result.user is None:
        raise HTTPException(status_code=400, detail="Signup failed")

    # Awaiting email confirmation — the user row exists but there's
    # no session until the user clicks the link.
    if result.session is None:
        return {
            "awaits_confirmation": True,
            "user_id": result.user.id,
            "email": result.user.email,
            "message": "Check your inbox to confirm your email.",
        }

    return AuthResponse(
        access_token=result.session.access_token,
        refresh_token=result.session.refresh_token,
        user_id=result.user.id,
        email=result.user.email,
        is_new_user=True,
    )


@router.post("/signup/dev")
async def signup_dev(body: SignupRequest):
    """Admin-only signup that bypasses email confirmation.

    Uses the service-role key to create a pre-confirmed user. Intended
    for internal testing (like your 10-person beta) where you don't want
    to juggle email inboxes for every test account.

    ⚠️ Do NOT expose this endpoint to untrusted clients in production.
    """
    sb = _require_supabase()
    try:
        created = sb.auth.admin.create_user(
            {
                "email": body.email,
                "password": body.password,
                "email_confirm": True,
                "user_metadata": {
                    "full_name": body.full_name,
                    "phone": body.phone,
                },
            }
        )
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    if created.user is None:
        raise HTTPException(400, "Admin signup failed")

    # Immediately log them in via a FRESH anon client so we don't
    # overwrite the service client's admin auth state.
    settings = get_settings()
    anon = create_client(settings.supabase_url, settings.supabase_anon_key)
    login_result = anon.auth.sign_in_with_password(
        {"email": body.email, "password": body.password}
    )
    if login_result.session is None:
        raise HTTPException(500, "Created user but couldn't sign in")

    return AuthResponse(
        access_token=login_result.session.access_token,
        refresh_token=login_result.session.refresh_token,
        user_id=created.user.id,
        email=created.user.email,
        is_new_user=True,
    )


@router.post("/login", response_model=AuthResponse)
async def login(body: LoginRequest):
    sb = _require_supabase()
    try:
        result = sb.auth.sign_in_with_password(
            {"email": body.email, "password": body.password}
        )
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=401, detail="Invalid credentials") from exc

    if result.user is None or result.session is None:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return AuthResponse(
        access_token=result.session.access_token,
        refresh_token=result.session.refresh_token,
        user_id=result.user.id,
        email=result.user.email,
    )


@router.post("/google", response_model=AuthResponse)
async def google_login(body: GoogleLoginRequest):
    """Verify a Google ID token via Supabase Auth and return a session."""
    sb = _require_supabase()
    try:
        result = sb.auth.sign_in_with_id_token(
            {"provider": "google", "token": body.id_token}
        )
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=401, detail=f"Google auth failed: {exc}") from exc

    if result.user is None or result.session is None:
        raise HTTPException(status_code=401, detail="Google auth failed")

    return AuthResponse(
        access_token=result.session.access_token,
        refresh_token=result.session.refresh_token,
        user_id=result.user.id,
        email=result.user.email,
    )


@router.post("/forgot-password", status_code=status.HTTP_202_ACCEPTED)
async def forgot_password(body: ForgotPasswordRequest):
    sb = _require_supabase()
    try:
        sb.auth.reset_password_for_email(body.email)
    except Exception:  # noqa: BLE001
        # Never leak whether the email exists.
        pass
    return {"message": "If that email exists, a reset link has been sent."}
