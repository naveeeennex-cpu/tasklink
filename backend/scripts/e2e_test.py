"""End-to-end smoke test: signup (admin) -> login -> /users/me ->
create profile -> post request -> provider feed -> maps shortest route.

Runs against a LOCAL backend at http://127.0.0.1:8765.
"""
from __future__ import annotations

import sys
import time
import httpx

BASE = "http://127.0.0.1:8765/api/v1"


def main() -> int:
    ts = int(time.time())
    consumer_email = f"consumer{ts}@lokaltest.dev"
    provider_email = f"provider{ts}@lokaltest.dev"
    password = "TestPass1234"

    c = httpx.Client(timeout=20.0)

    print(f"\n[1] consumer signup -> {consumer_email}")
    r = c.post(
        f"{BASE}/auth/signup/dev",
        json={
            "email": consumer_email,
            "password": password,
            "full_name": "Test Consumer",
            "phone": "+919999111111",
        },
    )
    if r.status_code != 200:
        print("   FAIL:", r.status_code, r.text[:300])
        return 1
    consumer_token = r.json()["access_token"]
    print(f"   OK — token: {consumer_token[:30]}...")

    print(f"\n[2] provider signup -> {provider_email}")
    r = c.post(
        f"{BASE}/auth/signup/dev",
        json={
            "email": provider_email,
            "password": password,
            "full_name": "Test Provider",
            "phone": "+919999222222",
        },
    )
    if r.status_code != 200:
        print("   FAIL:", r.status_code, r.text[:300])
        return 1
    provider_token = r.json()["access_token"]
    print(f"   OK — token: {provider_token[:30]}...")

    print("\n[3] GET /users/me (consumer)")
    r = c.get(
        f"{BASE}/users/me",
        headers={"Authorization": f"Bearer {consumer_token}"},
    )
    print(f"   {r.status_code} {r.json().get('email')} mode={r.json().get('active_mode')}")
    if r.status_code != 200:
        return 1

    print("\n[4] provider creates a Techie profile")
    r = c.post(
        f"{BASE}/profiles",
        headers={"Authorization": f"Bearer {provider_token}"},
        json={
            "details": {
                "category": "techie",
                "skills": ["Flutter", "Python"],
                "sub_skills": [],
                "portfolio_url": "https://github.com/example",
                "years_experience": 3,
                "hourly_rate_inr": 500,
            }
        },
    )
    if r.status_code not in (200, 201):
        print("   FAIL:", r.status_code, r.text[:300])
        return 1
    print("   OK — profile id:", r.json().get("id"))

    print("\n[5] consumer posts a service request")
    r = c.post(
        f"{BASE}/requests",
        headers={"Authorization": f"Bearer {consumer_token}"},
        json={
            "category": "techie",
            "title": "Need a Flutter dev for 2 hours",
            "description": "Fix a bug in my onboarding flow",
            "budget_inr": 1500,
            "pickup": {
                "lat": 13.0827,
                "lng": 80.2707,
                "address": "Chennai Central",
            },
        },
    )
    if r.status_code not in (200, 201):
        print("   FAIL:", r.status_code, r.text[:300])
        return 1
    req_id = r.json().get("id")
    print(f"   OK — request {req_id}")

    print("\n[6] provider reads their category feed")
    r = c.get(
        f"{BASE}/requests/feed",
        headers={"Authorization": f"Bearer {provider_token}"},
        params={"category": "techie"},
    )
    feed = r.json()
    print(f"   {r.status_code} — {len(feed)} open request(s)")
    titles = [row.get("title") for row in feed]
    if "Need a Flutter dev for 2 hours" not in titles:
        print("   FAIL — newly posted request not visible to provider")
        return 1
    print("   OK — matching works")

    print("\n[7] maps /route/shortest (Chennai Central -> Nungambakkam)")
    r = c.get(
        f"{BASE}/maps/route/shortest",
        params={
            "o_lat": 13.0827,
            "o_lng": 80.2707,
            "d_lat": 13.0569,
            "d_lng": 80.2425,
            "mode": "driving",
        },
    )
    if r.status_code != 200:
        print("   FAIL:", r.status_code, r.text[:300])
        return 1
    route = r.json()
    print(f"   OK — {route['distance_text']} / {route['duration_text']}"
          f" ({route['alternatives_count']} alt(s))")

    print("\n[8] GET /health")
    r = c.get("http://127.0.0.1:8765/health")
    print(f"   {r.status_code} {r.json()}")

    print("\nALL CHECKS PASSED")
    return 0


if __name__ == "__main__":
    sys.exit(main())
