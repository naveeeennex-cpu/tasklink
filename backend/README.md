# LOKAL Backend — FastAPI + Supabase

Modular, async, scalable backend for LOKAL.

## Stack

- **FastAPI** — async Python web framework
- **Supabase** — Postgres + Auth + Storage (managed)
- **Google Maps Platform** — geocoding, places, directions, distance (proxied through this backend, key never leaves the server)
- **Pydantic v2** — typed request/response models

## Layout

```
backend/
├── app/
│   ├── main.py                    # FastAPI app factory + router wiring
│   ├── core/
│   │   ├── config.py              # Settings from .env (typed)
│   │   └── supabase_client.py     # anon + service clients (cached)
│   ├── models/                    # Pydantic schemas
│   │   ├── enums.py
│   │   ├── user.py
│   │   ├── service_profile.py     # polymorphic (discriminated union)
│   │   └── service_request.py
│   └── api/
│       ├── deps.py                # shared deps (auth, settings)
│       └── v1/
│           ├── auth.py            # /auth/signup, /login, /google, /forgot-password
│           ├── users.py           # /users/me, mode toggle
│           ├── profiles.py        # /profiles   (list/create/update/delete)
│           ├── requests_router.py # /requests   (post / feed / mine)
│           └── maps.py            # /maps       (geocode/places/directions/distance)
├── supabase/
│   └── migrations/
│       └── 0001_init.sql          # tables + RLS + triggers
├── requirements.txt
├── .env.example                   # template (safe to commit)
└── .env                           # local secrets (gitignored)
```

## Setup (one-time)

```bash
cd backend
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

pip install -r requirements.txt
cp .env.example .env     # then fill in Supabase + Maps keys
```

## Supabase setup

1. Create a project at https://supabase.com
2. Project Settings → API → copy **URL**, **anon key**, **service_role key**, **JWT secret** into `backend/.env`
3. SQL Editor → New query → paste contents of `supabase/migrations/0001_init.sql` → Run
4. Authentication → Providers → enable **Email** and **Google** (add OAuth client ID from Google Cloud Console)

## Google Maps setup

1. https://console.cloud.google.com/apis/credentials → Create API Key
2. Enable these APIs for the project:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API
   - Directions API
   - Distance Matrix API
3. Restrict the key: **API restrictions** → only the above, **Application restrictions** → Android (package + SHA-1) / iOS (bundle ID)
4. Paste it into `backend/.env` as `GOOGLE_MAPS_API_KEY`

## Run

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Open:

- http://localhost:8000            → health JSON
- http://localhost:8000/health     → verbose health check
- http://localhost:8000/docs       → Swagger UI (interactive)
- http://localhost:8000/redoc      → ReDoc

## API surface (v1)

| Method | Path                              | Purpose |
|--------|-----------------------------------|---------|
| POST   | `/api/v1/auth/signup`             | Email+password signup |
| POST   | `/api/v1/auth/login`              | Email+password login |
| POST   | `/api/v1/auth/google`             | Google ID token exchange |
| POST   | `/api/v1/auth/forgot-password`    | Send reset email |
| GET    | `/api/v1/users/me`                | Current user profile |
| PATCH  | `/api/v1/users/me/mode`           | Toggle consumer ↔ provider |
| GET    | `/api/v1/profiles`                | My service profiles |
| POST   | `/api/v1/profiles`                | Create a service profile (any category) |
| PATCH  | `/api/v1/profiles/{category}`     | Update a service profile |
| DELETE | `/api/v1/profiles/{category}`     | Remove a service profile |
| POST   | `/api/v1/requests`                | Post a service request (consumer) |
| GET    | `/api/v1/requests/mine`           | My posted requests |
| GET    | `/api/v1/requests/feed`           | Open requests in a category (provider) |
| GET    | `/api/v1/maps/geocode`            | Address → coords |
| GET    | `/api/v1/maps/reverse-geocode`    | Coords → address |
| GET    | `/api/v1/maps/places/autocomplete`| Place predictions |
| GET    | `/api/v1/maps/directions`         | Route polyline |
| GET    | `/api/v1/maps/distance`           | Distance + ETA matrix |

All non-auth endpoints require `Authorization: Bearer <access_token>`.

## Security notes

- **Never commit `.env`.** Both `backend/.gitignore` and the root `.gitignore` exclude it.
- **Service-role key bypasses RLS.** It lives only on the server, never in the Flutter app.
- **Maps key is proxied.** The mobile client calls `/api/v1/maps/*` — it never sees the key.
- **Rotate any key that has been pasted in chat, Slack, email, or a screenshot.**
