"""Run every .sql file in supabase/migrations against DATABASE_URL.

Strips the SQLAlchemy '+asyncpg' driver hint if present so psycopg can
connect. Idempotent — the migrations use `create type if not exists` /
`create table if not exists` so running twice is safe.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

import psycopg
from dotenv import load_dotenv


def main() -> int:
    load_dotenv()
    raw = os.environ.get("DATABASE_URL", "").strip()
    if not raw:
        print("ERROR: DATABASE_URL not set in .env", file=sys.stderr)
        return 2

    # psycopg wants plain postgresql://, strip SQLAlchemy driver suffix.
    conn_str = raw.replace("postgresql+asyncpg://", "postgresql://", 1)

    migrations_dir = Path(__file__).resolve().parents[1] / "supabase" / "migrations"
    files = sorted(migrations_dir.glob("*.sql"))
    if not files:
        print("No migrations found.")
        return 0

    print(f"Connecting to {conn_str.split('@', 1)[-1]} ...")
    try:
        with psycopg.connect(conn_str, autocommit=True) as conn:
            for path in files:
                print(f"  -> applying {path.name}")
                sql = path.read_text(encoding="utf-8")
                with conn.cursor() as cur:
                    cur.execute(sql)
        print("[OK] All migrations applied.")
        return 0
    except Exception as exc:  # noqa: BLE001
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
