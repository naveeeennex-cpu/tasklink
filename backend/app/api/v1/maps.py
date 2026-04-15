"""Google Maps Platform proxy.

The Flutter client NEVER sees the Maps API key. Every geocoding, places,
directions, and distance-matrix call goes through this backend, which
holds the key server-side.

Endpoints:

* GET  /maps/geocode?address=...
* GET  /maps/reverse-geocode?lat=...&lng=...
* GET  /maps/places/autocomplete?q=...&lat=...&lng=...
* GET  /maps/place/details?place_id=...
* GET  /maps/directions?origin=lat,lng&destination=lat,lng&mode=driving
* GET  /maps/route/shortest?o_lat=..&o_lng=..&d_lat=..&d_lng=..&mode=..
* GET  /maps/distance?origin=..&destination=..
"""
from typing import Any

import httpx
from fastapi import APIRouter, Depends, HTTPException, Query

from ...core.config import Settings
from ..deps import settings_dep

router = APIRouter(prefix="/maps", tags=["maps"])

_BASE = "https://maps.googleapis.com/maps/api"


async def _get(url: str, params: dict[str, Any]) -> dict[str, Any]:
    async with httpx.AsyncClient(timeout=15.0) as client:
        r = await client.get(url, params=params)
    if r.status_code != 200:
        raise HTTPException(r.status_code, f"Maps upstream error: {r.text[:200]}")
    data = r.json()
    status = data.get("status")
    if status not in {"OK", "ZERO_RESULTS"}:
        raise HTTPException(
            502,
            f"Maps API status={status}: {data.get('error_message', '')}",
        )
    return data


def _require_key(settings: Settings) -> str:
    if not settings.maps_configured:
        raise HTTPException(
            503,
            "GOOGLE_MAPS_API_KEY is not configured in backend/.env",
        )
    return settings.google_maps_api_key


# ───────────────────────── Geocoding ──────────────────────────────────

@router.get("/geocode")
async def geocode(
    address: str = Query(min_length=2),
    settings: Settings = Depends(settings_dep),
):
    key = _require_key(settings)
    data = await _get(f"{_BASE}/geocode/json", {"address": address, "key": key})
    return data.get("results", [])


@router.get("/reverse-geocode")
async def reverse_geocode(
    lat: float,
    lng: float,
    settings: Settings = Depends(settings_dep),
):
    key = _require_key(settings)
    data = await _get(
        f"{_BASE}/geocode/json",
        {"latlng": f"{lat},{lng}", "key": key},
    )
    return data.get("results", [])


# ───────────────────────── Places ─────────────────────────────────────

@router.get("/places/autocomplete")
async def places_autocomplete(
    q: str = Query(min_length=1, alias="q"),
    lat: float | None = None,
    lng: float | None = None,
    radius_m: int = 20000,
    settings: Settings = Depends(settings_dep),
):
    key = _require_key(settings)
    params: dict[str, Any] = {"input": q, "key": key}
    if lat is not None and lng is not None:
        params["location"] = f"{lat},{lng}"
        params["radius"] = radius_m
    data = await _get(f"{_BASE}/place/autocomplete/json", params)
    return data.get("predictions", [])


@router.get("/place/details")
async def place_details(
    place_id: str,
    settings: Settings = Depends(settings_dep),
):
    key = _require_key(settings)
    data = await _get(
        f"{_BASE}/place/details/json",
        {
            "place_id": place_id,
            "fields": "place_id,formatted_address,name,geometry",
            "key": key,
        },
    )
    return data.get("result", {})


# ───────────────────────── Directions ─────────────────────────────────

@router.get("/directions")
async def directions(
    origin: str = Query(description="'lat,lng' or address"),
    destination: str = Query(description="'lat,lng' or address"),
    mode: str = "driving",
    settings: Settings = Depends(settings_dep),
):
    """Raw Google Directions response (all routes)."""
    key = _require_key(settings)
    data = await _get(
        f"{_BASE}/directions/json",
        {"origin": origin, "destination": destination, "mode": mode, "key": key},
    )
    return data.get("routes", [])


@router.get("/route/shortest")
async def shortest_route(
    o_lat: float = Query(..., description="origin latitude"),
    o_lng: float = Query(..., description="origin longitude"),
    d_lat: float = Query(..., description="destination latitude"),
    d_lng: float = Query(..., description="destination longitude"),
    mode: str = Query("driving", pattern="^(driving|walking|bicycling|transit)$"),
    settings: Settings = Depends(settings_dep),
):
    """Simplified shortest-route response for the Flutter client.

    Google Directions returns multiple possible routes. We request
    `alternatives=true` and then pick the one with the smallest total
    distance — that's the "shortest route" the client wants.

    Returns a trimmed, client-friendly payload:

        {
          "distance_m": 8132,
          "distance_text": "8.1 km",
          "duration_sec": 1320,
          "duration_text": "22 mins",
          "polyline": "<encoded>",
          "start": {"lat": ..., "lng": ..., "address": "..."},
          "end":   {"lat": ..., "lng": ..., "address": "..."},
          "steps": [ { "instruction": "...", "distance_m": 120, ... }, ... ]
        }
    """
    key = _require_key(settings)
    data = await _get(
        f"{_BASE}/directions/json",
        {
            "origin": f"{o_lat},{o_lng}",
            "destination": f"{d_lat},{d_lng}",
            "mode": mode,
            "alternatives": "true",
            "key": key,
        },
    )
    routes = data.get("routes") or []
    if not routes:
        raise HTTPException(404, "No route found between those points")

    def _total(route: dict[str, Any]) -> int:
        return sum(
            (leg.get("distance", {}) or {}).get("value", 0)
            for leg in route.get("legs", [])
        )

    shortest = min(routes, key=_total)
    leg = (shortest.get("legs") or [{}])[0]
    distance = leg.get("distance", {}) or {}
    duration = leg.get("duration", {}) or {}
    start_loc = leg.get("start_location", {}) or {}
    end_loc = leg.get("end_location", {}) or {}

    # Clean, light-weight step list for turn-by-turn UI.
    steps = []
    for s in leg.get("steps", []) or []:
        steps.append(
            {
                "instruction": _strip_html(s.get("html_instructions", "")),
                "distance_m": (s.get("distance", {}) or {}).get("value", 0),
                "duration_sec": (s.get("duration", {}) or {}).get("value", 0),
                "polyline": (s.get("polyline", {}) or {}).get("points", ""),
                "travel_mode": s.get("travel_mode", ""),
            }
        )

    return {
        "distance_m": distance.get("value", 0),
        "distance_text": distance.get("text", ""),
        "duration_sec": duration.get("value", 0),
        "duration_text": duration.get("text", ""),
        "polyline": (shortest.get("overview_polyline") or {}).get("points", ""),
        "bounds": shortest.get("bounds", {}),
        "start": {
            "lat": start_loc.get("lat"),
            "lng": start_loc.get("lng"),
            "address": leg.get("start_address", ""),
        },
        "end": {
            "lat": end_loc.get("lat"),
            "lng": end_loc.get("lng"),
            "address": leg.get("end_address", ""),
        },
        "steps": steps,
        "alternatives_count": len(routes),
    }


@router.get("/distance")
async def distance_matrix(
    origin: str = Query(description="'lat,lng' or address"),
    destination: str = Query(description="'lat,lng' or address"),
    mode: str = "driving",
    settings: Settings = Depends(settings_dep),
):
    key = _require_key(settings)
    data = await _get(
        f"{_BASE}/distancematrix/json",
        {
            "origins": origin,
            "destinations": destination,
            "mode": mode,
            "key": key,
        },
    )
    return data


# ───────────────────────── helpers ────────────────────────────────────

def _strip_html(text: str) -> str:
    """Very small HTML → plain text for Google turn instructions
    (they embed <b>, <div class="..."> etc)."""
    import re

    text = re.sub(r"<[^>]+>", " ", text)
    return re.sub(r"\s+", " ", text).strip()
