"""Откат status_do_hidden='completed' у заказов, у которых нет completion_date_by_the_driver.

Использует psql.
"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

DEFAULT_URL_FILE = "/root/cab_drive_database_url.txt"


def _database_url() -> str | None:
    url = (os.environ.get("DATABASE_URL") or "").strip()
    if url:
        return url
    try:
        if Path(DEFAULT_URL_FILE).is_file():
            return Path(DEFAULT_URL_FILE).read_text(encoding="utf-8").strip() or None
    except Exception:
        pass
    return None


def _psql(sql: str) -> tuple[int, str, str]:
    url = _database_url()
    if not url:
        print("[ERROR] DATABASE_URL not set", file=sys.stderr)
        sys.exit(1)
    env = os.environ.copy()
    env["PGPASSWORD"] = url.rsplit("@", 1)[0].rsplit(":", 1)[-1]
    result = subprocess.run(
        ["psql", url, "-c", sql, "--tuples-only"],
        capture_output=True,
        text=True,
        env=env,
    )
    return result.returncode, result.stdout, result.stderr


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()

    sql = """
        SELECT count(*)
        FROM app_orders
        WHERE status = 'hidden'
          AND status_do_hidden = 'completed'
          AND completion_date_by_the_driver IS NULL;
    """
    code, out, err = _psql(sql)
    if code != 0:
        print(f"[psql error] {err}", file=sys.stderr)
        return 1
    print(f"Заказов для отката: {out.strip()}")

    if args.apply:
        sql = """
            UPDATE app_orders
            SET status_do_hidden = NULL,
                updated_at = NOW()
            WHERE status = 'hidden'
              AND status_do_hidden = 'completed'
              AND completion_date_by_the_driver IS NULL;
        """
        code, out, err = _psql(sql)
        if code != 0:
            print(f"[psql error] {err}", file=sys.stderr)
            return 1
        print(out)
    else:
        print("DRY-RUN: для применения запусти с --apply")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
