"""Smoke: prod extra_orders deploy + FCM price/extra logs + Diana."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)

REMOTE_PY = r'''
import json
import psycopg2
import psycopg2.extras

url = open("/root/cab_drive_database_url.txt").read().strip()
conn = psycopg2.connect(url)
cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
cur.execute(
    """
    select id, phone, display_name, role
    from app_users
    where phone like %s or phone like %s
    limit 5
    """,
    ("%79667499985%", "%9667499985%"),
)
users = cur.fetchall()
print("USERS", json.dumps(users, default=str, ensure_ascii=False))
uids = [u["id"] for u in users]
if uids:
    cur.execute(
        """
        select user_id, left(token, 24) as tok, updated_at
        from app_user_fcm_tokens
        where user_id = any(%s)
        order by updated_at desc nulls last
        limit 10
        """,
        (uids,),
    )
    print("TOKENS", json.dumps(cur.fetchall(), default=str, ensure_ascii=False))
    cur.execute(
        """
        select id, status, price, updated_at
        from app_orders
        where customer_id = any(%s) or driver_id = any(%s)
        order by updated_at desc nulls last
        limit 8
        """,
        (uids, uids),
    )
    print("ORDERS", json.dumps(cur.fetchall(), default=str, ensure_ascii=False))
conn.close()
'''


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    cmds = [
        "grep -n ACTIVE_ORDER_STATUSES /root/cab_drive/server/orders/extra_orders.py | sed -n '1,8p'",
        "systemctl is-active cab.service; curl -sS https://cab.artean.ru/api/app/health",
        "journalctl -u cab.service --since '3 days ago' --no-pager | grep -E 'price_changed|extra_notify|additional_order' | tail -50",
    ]
    for c in cmds:
        print("===", c[:90])
        _, out, err = ssh.exec_command(c, timeout=90)
        print(out.read().decode("utf-8", "replace")[:4000])
        e = err.read().decode("utf-8", "replace")[:500]
        if e.strip():
            print("ERR", e)

    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_smoke_diana_pg.py", "w") as f:
        f.write(REMOTE_PY)
    sftp.close()

    print("=== diana pg")
    _, out, err = ssh.exec_command("python3 /tmp/_smoke_diana_pg.py", timeout=60)
    print(out.read().decode("utf-8", "replace")[:5000])
    e = err.read().decode("utf-8", "replace")[:800]
    if e.strip():
        print("ERR", e)

    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
