# LOKAL

**Hyperlocal human services marketplace.** One account can both request and provide multiple kinds of help — rides, deliveries, tech gigs, a friendly walk, or a plumber visit — all from people nearby.

This repo (named `tasklink` on GitHub) is a monorepo containing the Flutter mobile app and a FastAPI backend that talks to a Supabase project.

---

## What makes LOKAL different

Most service apps assume **one person = one role**. LOKAL assumes **one person = many roles, chosen dynamically.** A student can take ride bookings in the morning, ship a Flutter gig in the afternoon, and accompany a grandparent on a shopping trip in the evening — all from the same account.

- **Consumer and Provider modes** on a single account, flipped via a top toggle
- **Four provider verticals**, pick as many as you want:
  - Ride & Delivery · Techie · Support Partner · Non-Tech Services
- **Polymorphic service profiles** — one DB row per `(user, category)`
- **Dynamic onboarding forms** that render based on selected categories
- **Google Maps**-powered shortest-route fetching (proxied server-side so the key never leaves the backend)

---

## Repo layout

```
locktail/
├── app/                         # Flutter mobile app (Android + iOS)
│   ├── lib/
│   │   ├── config/              # .env loader
│   │   ├── core/                # router, api client, supabase init, models
│   │   ├── design/              # design system (theme, tokens, widgets)
│   │   └── features/
│   │       ├── auth/            # splash, welcome, login, signup, forgot
│   │       ├── mode/            # mode selection + top toggle
│   │       ├── onboarding/      # multi-select + dynamic forms + verification
│   │       ├── profiles/        # service-profile state
│   │       ├── home_customer/   # consumer home (light editorial)
│   │       └── home_provider/   # provider home (dark + live Google Map)
│   ├── android/                 # Android platform config
│   └── ios/                     # iOS platform config
│
├── backend/                     # FastAPI + Supabase backend
│   ├── app/
│   │   ├── api/v1/              # auth, users, profiles, requests, maps
│   │   ├── core/                # config, supabase client
│   │   └── models/              # Pydantic schemas
│   ├── scripts/                 # migration runner, e2e test, schema verifier
│   ├── supabase/migrations/     # DDL + RLS + triggers
│   └── requirements.txt
│
└── Ui_refernece/                # Design reference screens + DESIGN.md
```

---

## Stack

| Layer | Tech |
|---|---|
| Mobile | Flutter 3.38, Riverpod 3, go_router, Dio, Supabase Flutter, google_sign_in, google_maps_flutter |
| Backend | FastAPI, Pydantic v2, httpx, Supabase Python SDK |
| Database + Auth | Supabase (Postgres + Auth + Storage) |
| Maps | Google Maps Platform (Geocoding, Places, Directions, Distance Matrix) |

---

## Local setup

### 1. Prereqs

- Flutter 3.38+, Dart 3.10+
- Python 3.11+
- A Supabase project (free tier fine)
- A Google Cloud project with Maps Platform APIs enabled

### 2. Environment files

Both `backend/` and `app/` ship an `.env.example`. Copy each to `.env` and fill in:

```bash
cp backend/.env.example backend/.env
cp app/.env.example app/.env
```

`backend/.env` needs:
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_JWT_SECRET`
- `DATABASE_URL` (direct Postgres, for running migrations)
- `GOOGLE_MAPS_API_KEY`

`app/.env` needs:
- `BACKEND_URL` (e.g. `http://10.0.2.2:8000` for Android emulator)
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`

### 3. Backend

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows
# source .venv/bin/activate     # macOS/Linux
pip install -r requirements.txt
python scripts/run_migrations.py       # applies schema to your Supabase DB
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Visit:
- http://localhost:8000/health
- http://localhost:8000/docs (interactive Swagger)

### 4. Flutter app

```bash
cd app
flutter pub get
flutter run
```

---

## Backend API surface

| Method | Path | Purpose |
|---|---|---|
| POST | `/api/v1/auth/signup` | Email + password signup |
| POST | `/api/v1/auth/signup/dev` | Admin-only preconfirmed signup (testing) |
| POST | `/api/v1/auth/login` | Email + password login |
| POST | `/api/v1/auth/google` | Google ID token exchange |
| POST | `/api/v1/auth/forgot-password` | Send reset email |
| GET | `/api/v1/users/me` | Current user profile |
| PATCH | `/api/v1/users/me/mode` | Toggle consumer ↔ provider |
| GET | `/api/v1/profiles` | List my service profiles |
| POST | `/api/v1/profiles` | Create a service profile |
| PATCH | `/api/v1/profiles/{category}` | Update a profile |
| DELETE | `/api/v1/profiles/{category}` | Remove a profile |
| POST | `/api/v1/requests` | Post a service request |
| GET | `/api/v1/requests/mine` | My posted requests |
| GET | `/api/v1/requests/feed` | Open requests in a category |
| GET | `/api/v1/maps/geocode` | Address → coords |
| GET | `/api/v1/maps/reverse-geocode` | Coords → address |
| GET | `/api/v1/maps/places/autocomplete` | Place predictions |
| GET | `/api/v1/maps/place/details` | Full place record |
| GET | `/api/v1/maps/directions` | Raw Directions response |
| GET | `/api/v1/maps/route/shortest` | **Simplified shortest-route** with polyline + steps |
| GET | `/api/v1/maps/distance` | Distance matrix |

All non-auth endpoints require `Authorization: Bearer <access_token>`.

---

## Database schema

Eight tables with Row-Level Security enabled on every one:

| Table | Purpose |
|---|---|
| `users` | Mirror of `auth.users` with business fields + `last_lat`/`last_lng` |
| `saved_addresses` | Home/work/custom addresses |
| `service_profiles` | Polymorphic `(user, category)` — one row per category offered |
| `provider_locations` | Live GPS pings for ETA and dispatch |
| `service_requests` | Consumer posts with cached route polyline |
| `bookings` | Accepted request → in-progress job |
| `reviews` | Bidirectional 1-5 stars per booking |
| `chat_messages` | Thread per booking |

Run `python backend/scripts/verify_schema.py` to print the live state of your database.

---

## Security notes

- `service_role` keys and signing secrets live **only** on the backend and must never be committed
- The Google Maps key is **proxied** through `/api/v1/maps/*` — the Flutter client never sees it for backend-dispatched calls
- The Maps key is **also** embedded in `AndroidManifest.xml` + `AppDelegate.swift` for native map rendering; it MUST be restricted by Android package name + SHA-1 / iOS bundle ID in Google Cloud Console before shipping
- Row-Level Security is the last line of defense — policies are defined in `backend/supabase/migrations/0001_init.sql`

---

## License

TBD.
