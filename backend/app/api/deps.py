"""Shared FastAPI dependencies."""
from fastapi import Depends, Header, HTTPException, status

from ..core.config import Settings, get_settings
from ..core.supabase_client import service_client


def settings_dep() -> Settings:
    return get_settings()


async def current_user_id(
    authorization: str | None = Header(default=None),
    settings: Settings = Depends(settings_dep),
) -> str:
    """Resolve the Supabase user from an `Authorization: Bearer <jwt>` header.

    Uses the service client to verify the token with Supabase Auth.
    """
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token",
        )
    token = authorization.split(" ", 1)[1].strip()

    sb = service_client()
    if sb is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Supabase is not configured on the server",
        )
    try:
        resp = sb.auth.get_user(token)
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {exc}",
        ) from exc

    if resp is None or resp.user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )
    return resp.user.id
