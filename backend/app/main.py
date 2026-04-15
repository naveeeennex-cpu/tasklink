"""LOKAL backend entrypoint."""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import __version__
from .api.v1 import auth, maps, profiles, requests_router, users
from .core.config import get_settings


@asynccontextmanager
async def lifespan(app: FastAPI):
    s = get_settings()
    print(f"[LOKAL] backend v{__version__} starting in {s.app_env} mode")
    print(f"        Supabase configured: {s.supabase_configured}")
    print(f"        Maps configured:     {s.maps_configured}")
    yield
    print("[LOKAL] backend shutting down")


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(
        title="LOKAL API",
        description=(
            "Hyperlocal human services marketplace. "
            "One user, many service profiles."
        ),
        version=__version__,
        lifespan=lifespan,
    )

    # CORS — permissive by default so the Flutter app + any browser
    # test can hit the deployed backend without friction. Lock this
    # down to specific origins before shipping to production.
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list
        if settings.app_env == "production"
        else ["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Health
    @app.get("/", tags=["health"])
    async def root():
        return {
            "name": "LOKAL API",
            "version": __version__,
            "status": "ok",
            "docs": "/docs",
        }

    @app.get("/health", tags=["health"])
    async def health():
        s = get_settings()
        return {
            "status": "healthy",
            "env": s.app_env,
            "supabase_configured": s.supabase_configured,
            "maps_configured": s.maps_configured,
        }

    # v1 routers
    v1_prefix = "/api/v1"
    app.include_router(auth.router, prefix=v1_prefix)
    app.include_router(users.router, prefix=v1_prefix)
    app.include_router(profiles.router, prefix=v1_prefix)
    app.include_router(requests_router.router, prefix=v1_prefix)
    app.include_router(maps.router, prefix=v1_prefix)

    return app


app = create_app()
