"""Deeper FCM audit: recent bids/patches + dry send result shape."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)


def run(ssh: paramiko.SSHClient, cmd: str) -> str:
    _, out, err = ssh.exec_command(cmd)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    db = "$(cat /root/cab_drive_database_url.txt)"

    print("=== recent responses ===")
    print(
        run(
            ssh,
            f"psql {db} -c \"SELECT order_id, firestore_id, raw_json->>'driver_id' AS driver, "
            f"left(raw_json->>'date_created',19) AS created "
            f"FROM app_order_responses ORDER BY id DESC LIMIT 15;\"",
        )
    )
    print("=== orders with respondents ===")
    print(
        run(
            ssh,
            f"psql {db} -c \"SELECT id, status, user_customer_id, "
            f"array_length(user_who_responced,1) AS n_resp, "
            f"user_who_responced[1:3] AS sample_resp, current_price, updated_at "
            f"FROM app_orders WHERE coalesce(array_length(user_who_responced,1),0) > 0 "
            f"ORDER BY updated_at DESC NULLS LAST LIMIT 10;\"",
        )
    )
    print("=== access: bids / patch last 2d ===")
    print(
        run(
            ssh,
            "journalctl -u cab.service --since '2 days ago' --no-pager 2>/dev/null | "
            "grep -iE 'POST /api/app/orders/.*/bids|PATCH /api/app/orders|create_bid|patch_order|price_changed|\\[app_fcm\\]|No FCM' | tail -100",
        )
    )
    print("=== gunicorn access if any ===")
    print(
        run(
            ssh,
            "grep -E 'orders/.*/bids|orders/.*/patch|/api/app/push' "
            "/var/log/nginx/access.log 2>/dev/null | tail -40",
        )
    )
    print("=== logger level / test notify one user with tokens ===")
    print(
        run(
            ssh,
            "cd /root/projects/cab_drive && ./venv/bin/python <<'PY'\n"
            "import os, json\n"
            "# bootstrap like gunicorn: import app first may hang; call fcm via subprocess flask?\n"
            "os.environ.setdefault('FLASK_ENV','production')\n"
            "import importlib\n"
            "# Load app_pg without full notify cycle\n"
            "import sys\n"
            "sys.path.insert(0,'.')\n"
            "\n"
            "# Direct DB\n"
            "import psycopg2\n"
            "url=open('/root/cab_drive_database_url.txt').read().strip()\n"
            "conn=psycopg2.connect(url)\n"
            "cur=conn.cursor()\n"
            "cur.execute('SELECT user_id, token FROM app_user_fcm_tokens LIMIT 3')\n"
            "rows=cur.fetchall()\n"
            "print('sample_tokens', [(u, t[:20]+'...') for u,t in rows])\n"
            "cur.execute(\"SELECT id, user_customer_id, user_who_responced FROM app_orders WHERE status='newOrder' AND coalesce(array_length(user_who_responced,1),0)>0 ORDER BY updated_at DESC LIMIT 3\")\n"
            "for r in cur.fetchall():\n"
            "  print('order', r[0], 'cust', r[1], 'resp', r[2])\n"
            "conn.close()\n"
            "PY",
        )
    )
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
