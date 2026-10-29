"""Look up Diana recent orders + price_changed FCM logs."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    script = r'''
import json
import app as _a
import app_pg

phone = "%9667499985%"
with app_pg.connection() as conn:
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id, phone_number, display_name FROM app_users WHERE phone_number LIKE %s",
            (phone,),
        )
        users = cur.fetchall()
        print("USERS", users)
        uids = [u[0] for u in users]
        if not uids:
            raise SystemExit(0)
        cur.execute(
            """
            SELECT id, status, budget, current_price, selected_driver_id,
                   user_customer_id, updated_at, date_time_created
            FROM app_orders
            WHERE user_customer_id = ANY(%s)
            ORDER BY COALESCE(updated_at, date_time_created) DESC NULLS LAST
            LIMIT 8
            """,
            (uids,),
        )
        cols = [d[0] for d in cur.description]
        rows = [dict(zip(cols, r)) for r in cur.fetchall()]
        for r in rows:
            for k,v in list(r.items()):
                if hasattr(v, "isoformat"):
                    r[k] = v.isoformat()
                elif v is not None and not isinstance(v, (str,int,float,bool)):
                    r[k] = str(v)
        print("ORDERS", json.dumps(rows, ensure_ascii=False))
        for oid in [r["id"] for r in rows[:3]]:
            cur.execute(
                "SELECT firestore_id, raw_json->>'driver_id' AS driver, raw_json->>'price' AS price, created_at FROM app_order_responses WHERE order_id=%s ORDER BY created_at DESC LIMIT 10",
                (oid,),
            )
            bids = cur.fetchall()
            print("BIDS", oid, bids)
        cur.execute(
            "SELECT user_id, left(token,24) as tok, updated_at FROM app_user_fcm_tokens WHERE user_id = ANY(%s) ORDER BY updated_at DESC NULLS LAST",
            (uids,),
        )
        print("FCM_DIANA", cur.fetchall())
'''
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_diana_price_push.py", "w") as f:
        f.write(script)
    sftp.close()
    _, out, err = ssh.exec_command(
        "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
        "./venv/bin/python /tmp/_diana_price_push.py",
        timeout=60,
    )
    print(out.read().decode("utf-8", "replace"))
    e = err.read().decode("utf-8", "replace").strip()
    if e:
        print("STDERR", e[-1500:])

    # journalctl last price_changed
    _, o2, _ = ssh.exec_command(
        "journalctl -u cab.service --since '3 days ago' --no-pager "
        "| grep -E 'price_changed|patch_order' | tail -n 40",
        timeout=45,
    )
    print("LOGS", o2.read().decode("utf-8", "replace")[-4000:])
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
