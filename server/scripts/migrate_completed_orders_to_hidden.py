"""Миграция: завершённые/legacy-hidden заказы → hidden + status_do_hidden=completed.

Использует psql (command-line), чтобы не зависеть от psycopg2 в окружении.

Запуск:
    python server/scripts/migrate_completed_orders_to_hidden.py --dry-run
    python server/scripts/migrate_completed_orders_to_hidden.py --apply
"""
from __future__ import annotations

import argparse
import json
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
        ["psql", url, "-c", sql, "--tuples-only", "--expanded"],
        capture_output=True,
        text=True,
        env=env,
    )
    return result.returncode, result.stdout, result.stderr


def _rows(sql: str) -> list[dict]:
    code, out, err = _psql(sql)
    if code != 0:
        print(f"[psql error] {err}", file=sys.stderr)
        sys.exit(code)
    rows = []
    current: dict = {}
    for line in out.splitlines():
        line = line.strip()
        if not line:
            if current:
                rows.append(current)
                current = {}
            continue
        if "|" in line:
            key, _, val = line.partition("|")
            current[key.strip()] = val.strip()
    if current:
        rows.append(current)
    return rows


def _exec(sql: str) -> int:
    code, out, err = _psql(sql)
    if code != 0:
        print(f"[psql error] {err}", file=sys.stderr)
        sys.exit(code)
    print(out)
    return code


def find_diana_order() -> list[dict]:
    return _rows(
        """
        SELECT id, status, status_do_hidden, user_customer_id, budget, current_price,
               date_time_created, date_upd
        FROM app_orders
        WHERE (
            point_a_json::text ILIKE '%Дубровская%'
            OR point_b_json::text ILIKE '%Мира%188%'
        )
          AND budget = 1038
        ORDER BY date_time_created DESC
        LIMIT 10;
        """
    )


def list_completed_candidates() -> list[dict]:
    return _rows(
        """
        SELECT id, status, status_do_hidden, user_customer_id, budget, current_price,
               date_time_created, date_upd
        FROM app_orders
        WHERE status = 'completed'
          AND (status_do_hidden IS NULL OR status_do_hidden != 'completed')
        ORDER BY date_time_created DESC;
        """
    )


def list_legacy_hidden_candidates() -> list[dict]:
    return _rows(
        """
        SELECT id, status, status_do_hidden, user_customer_id, budget, current_price,
               date_time_created, date_upd, completion_date_by_the_driver
        FROM app_orders
        WHERE status = 'hidden'
          AND status_do_hidden IS NULL
          AND completion_date_by_the_driver IS NOT NULL
        ORDER BY date_time_created DESC;
        """
    )


def update_completed() -> None:
    _exec(
        """
        UPDATE app_orders
        SET status = 'hidden',
            status_do_hidden = 'completed',
            date_upd = NOW(),
            updated_at = NOW()
        WHERE status = 'completed'
          AND (status_do_hidden IS NULL OR status_do_hidden != 'completed');
        """
    )


def update_legacy_hidden() -> None:
    _exec(
        """
        UPDATE app_orders
        SET status_do_hidden = 'completed',
            updated_at = NOW()
        WHERE status = 'hidden'
          AND status_do_hidden IS NULL
          AND completion_date_by_the_driver IS NOT NULL;
        """
    )


def fix_over_migrated() -> None:
    """Откатить status_do_hidden='completed' у заказов без completion_date."""
    _exec(
        """
        UPDATE app_orders
        SET status_do_hidden = NULL,
            updated_at = NOW()
        WHERE status = 'hidden'
          AND status_do_hidden = 'completed'
          AND completion_date_by_the_driver IS NULL;
        """
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="Применить изменения")
    args = parser.parse_args()

    diana_orders = find_diana_order()
    print("=== Заказ(ы) Дианы (Дубровская/Мира 188, 1038 ₽) ===")
    print(json.dumps(diana_orders, default=str, ensure_ascii=False, indent=2))

    completed_candidates = list_completed_candidates()
    print(f"\n=== completed без hidden: {len(completed_candidates)} ===")
    for o in completed_candidates[:20]:
        print(
            f"  {o['id']} | status={o['status']} | do_hidden={o['status_do_hidden']} | "
            f"created={o['date_time_created']} | customer={o['user_customer_id']}"
        )
    if len(completed_candidates) > 20:
        print(f"  ... и ещё {len(completed_candidates) - 20}")

    legacy_candidates = list_legacy_hidden_candidates()
    print(f"\n=== legacy hidden без status_do_hidden: {len(legacy_candidates)} ===")
    for o in legacy_candidates[:20]:
        print(
            f"  {o['id']} | status={o['status']} | do_hidden={o['status_do_hidden']} | "
            f"completed_at={o.get('completion_date_by_the_driver')} | customer={o['user_customer_id']}"
        )
    if len(legacy_candidates) > 20:
        print(f"  ... и ещё {len(legacy_candidates) - 20}")

    over_migrated = _rows(
        """
        SELECT id, status, status_do_hidden, completion_date_by_the_driver
        FROM app_orders
        WHERE status = 'hidden'
          AND status_do_hidden = 'completed'
          AND completion_date_by_the_driver IS NULL;
        """
    )
    print(f"\n=== лишне мигрированных hidden|completed без completion_date: {len(over_migrated)} ===")
    for o in over_migrated[:20]:
        print(f"  {o['id']} | do_hidden={o['status_do_hidden']} | completed_at={o.get('completion_date_by_the_driver')}")

    if args.apply:
        print("\n=== APPLY ===")
        update_completed()
        update_legacy_hidden()
        fix_over_migrated()

        remaining_completed = list_completed_candidates()
        remaining_legacy = list_legacy_hidden_candidates()
        print(f"Осталось completed без hidden: {len(remaining_completed)}")
        print(f"Осталось legacy hidden без do_hidden: {len(remaining_legacy)}")
        remaining_over = _rows(
            """
            SELECT count(*) AS cnt
            FROM app_orders
            WHERE status = 'hidden'
              AND status_do_hidden = 'completed'
              AND completion_date_by_the_driver IS NULL;
            """
        )
        print(f"Лишне мигрированных осталось: {remaining_over[0].get('cnt', 0) if remaining_over else '?'}")
    else:
        print("\n=== DRY-RUN: изменений не внесено ===")
        print("Для применения запусти с --apply")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
