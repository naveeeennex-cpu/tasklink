# Deploying the LOKAL backend to Railway

Five steps. Should take ~5 minutes end to end.

## 1. Create a new Railway project

1. Go to https://railway.app and log in
2. Click **New Project** → **Deploy from GitHub repo**
3. Select `naveeeennex-cpu/tasklink`
4. When it asks for the root directory, set **`/backend`**
   (LOKAL is a monorepo — the Flutter app is in `/app`, the backend is in `/backend`)

Railway will detect Python automatically via Nixpacks and read `backend/railway.json`, `backend/Procfile`, and `backend/runtime.txt`.

## 2. Set environment variables

In your Railway project → **Variables** tab → add these:

| Variable | Value |
|---|---|
| `APP_ENV` | `production` |
| `SUPABASE_URL` | `https://krlmtkjiselgssgvfihw.supabase.co` |
| `SUPABASE_ANON_KEY` | *(the anon/public key from Supabase Dashboard → API)* |
| `SUPABASE_SERVICE_ROLE_KEY` | *(the service_role key — **secret**, bypasses RLS)* |
| `SUPABASE_JWT_SECRET` | *(the JWT signing secret from Supabase Dashboard → API → JWT Settings)* |
| `GOOGLE_MAPS_API_KEY` | *(your restricted Google Maps key)* |
| `APP_CORS_ORIGINS` | *(comma-separated list of allowed origins — leave empty if only the mobile app hits this)* |

You do **NOT** need to set `APP_PORT` — Railway injects `$PORT` dynamically and `Procfile` / `railway.json` already use it.

You do **NOT** need `DATABASE_URL` at runtime — it's only used by migration scripts, which you run locally.

## 3. Deploy

Railway auto-deploys on push. First deploy takes ~2 minutes.

Watch the **Deployments** tab for:
```
[LOKAL] backend v0.1.0 starting in production mode
        Supabase configured: True
        Maps configured:     True
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:PORT
```

## 4. Get the public URL

Project Settings → **Networking** → **Generate Domain**. You'll get something like:
```
https://tasklink-production.up.railway.app
```

## 5. Smoke test

```bash
curl https://YOUR-URL.up.railway.app/health
# → {"status":"healthy","env":"production","supabase_configured":true,"maps_configured":true}

curl https://YOUR-URL.up.railway.app/
# → {"name":"LOKAL API","version":"0.1.0","status":"ok","docs":"/docs"}

curl "https://YOUR-URL.up.railway.app/api/v1/maps/route/shortest?o_lat=13.0827&o_lng=80.2707&d_lat=13.0569&d_lng=80.2425"
# → full shortest-route JSON
```

Open `https://YOUR-URL.up.railway.app/docs` for interactive Swagger.

## 6. Point the Flutter app at it

Update `app/.env`:

```bash
BACKEND_URL=https://YOUR-URL.up.railway.app
```

Then rebuild the Flutter app: `flutter pub get && flutter run`.

## Troubleshooting

- **`ModuleNotFoundError: No module named 'app'`** — Railway is running from the repo root, not `/backend`. Go to Project Settings → Root Directory → set to `backend`.
- **`Application startup failed`** with UnicodeEncodeError — already fixed in `main.py` (no emojis in logs).
- **`supabase_configured: false` in /health** — one of the `SUPABASE_*` env vars is missing or mistyped.
- **Maps endpoints return 503** — `GOOGLE_MAPS_API_KEY` is missing in Railway Variables.
- **Cold starts** — Railway free tier sleeps on inactivity. Upgrade to a paid plan or add a UptimeRobot ping to keep it warm for testers.
