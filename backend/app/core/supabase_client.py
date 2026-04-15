"""Supabase client singletons.

Two clients are exposed because they have different privilege levels:

* `anon_client()` — uses the anon key, respects Row-Level Security.
  Use for requests that should run as the end user.
* `service_client()` — uses the service-role key, BYPASSES RLS.
  Use ONLY for trusted server-side operations (e.g. admin tasks,
  cross-user matching). Never expose this to the client.
"""
from functools import lru_cache

from supabase import Client, create_client

from .config import get_settings


@lru_cache
def anon_client() -> Client | None:
    s = get_settings()
    if not s.supabase_url or not s.supabase_anon_key:
        return None
    return create_client(s.supabase_url, s.supabase_anon_key)


@lru_cache
def service_client() -> Client | None:
    s = get_settings()
    if not s.supabase_configured:
        return None
    return create_client(s.supabase_url, s.supabase_service_role_key)
