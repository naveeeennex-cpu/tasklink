"""Quick sanity check of what's in the database after migrations."""
import os
import sys

import psycopg
from dotenv import load_dotenv


def main() -> int:
    load_dotenv()
    conn_str = os.environ["DATABASE_URL"].replace(
        "postgresql+asyncpg://", "postgresql://", 1
    )
    with psycopg.connect(conn_str) as conn, conn.cursor() as cur:
        print("\n== public tables ==")
        cur.execute(
            "select table_name from information_schema.tables "
            "where table_schema='public' order by table_name"
        )
        for (t,) in cur.fetchall():
            print(f"  - {t}")

        print("\n== custom enums ==")
        cur.execute(
            "select typname from pg_type "
            "where typnamespace = 'public'::regnamespace "
            "and typtype = 'e' order by typname"
        )
        for (t,) in cur.fetchall():
            print(f"  - {t}")

        print("\n== RLS status ==")
        cur.execute(
            "select tablename, rowsecurity from pg_tables "
            "where schemaname='public' order by tablename"
        )
        for name, rls in cur.fetchall():
            flag = "ON" if rls else "OFF"
            print(f"  - {name:25s} {flag}")

        print("\n== policies ==")
        cur.execute(
            "select tablename, policyname from pg_policies "
            "where schemaname='public' order by tablename, policyname"
        )
        for table, pol in cur.fetchall():
            print(f"  - {table:22s} {pol}")

        print("\n== triggers on public tables ==")
        cur.execute(
            "select event_object_table, trigger_name "
            "from information_schema.triggers "
            "where trigger_schema='public' "
            "order by event_object_table, trigger_name"
        )
        for table, trig in cur.fetchall():
            print(f"  - {table:22s} {trig}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
