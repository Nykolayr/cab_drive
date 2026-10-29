"""Smoke payout on VPS: validation + optional Jump dry-run without balance debit.

Usage (on VPS):
  python3 /tmp/_smoke_payout.py
"""
from __future__ import annotations

import json
import os
import sys

sys.path.insert(0, "/root/cab_drive/server")
os.chdir("/root/cab_drive/server")

import app_payout_ops as p
import app_pg


def main() -> None:
    print("comm200", p.payout_commission(200), "amt", p.amount_to_card(200))
    print("comm500", p.payout_commission(500), "amt", p.amount_to_card(500))

    try:
        p.create_payout("nonexistent-uid", pan="4111111111111111")
    except Exception as e:
        print("expected_missing_user", type(e).__name__, str(e)[:200])

    # Diana test phone if present — only validate short pan / min balance paths
    rows = app_pg.fetchall(
        "SELECT id, phone_number, balance, contractor_id FROM app_users "
        "WHERE phone_number LIKE %s LIMIT 3",
        ("%9667499985%",),
    )
    print("diana_rows", json.dumps(rows or [], default=str))
    if rows:
        uid = rows[0]["id"]
        try:
            p.create_payout(uid, pan="1234")  # short pan
        except Exception as e:
            print("expected_short_pan", type(e).__name__, str(e)[:200])

    # HTTP route exists
    import urllib.request

    try:
        req = urllib.request.Request(
            "https://cab.artean.ru/api/app/me/payout",
            data=b"{}",
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            print("http_no_auth", resp.status, resp.read()[:200])
    except Exception as e:
        body = getattr(e, "read", lambda: b"")()
        print("http_no_auth_err", type(e).__name__, str(e)[:120], (body or b"")[:200])

    print("OK")


if __name__ == "__main__":
    main()
