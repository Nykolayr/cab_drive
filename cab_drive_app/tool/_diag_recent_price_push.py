"""Recent orders with bids + price_changed logs; drivers FCM."""
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
    py = r'''
import json
import app as _a
import app_pg

with app_pg.connection() as conn:
    with conn.cursor() as cur:
        # recent orders any status with responses
        cur.execute("""
            SELECT o.id, o.status, o.budget, o.current_price, o.user_customer_id,
                   o.selected_driver_id, o.updated_at,
                   (SELECT count(*) FROM app_order_responses r WHERE r.order_id=o.id) AS bids
            FROM app_orders o
            WHERE o.updated_at > NOW() - INTERVAL '5 days'
               OR o.date_time_created > NOW() - INTERVAL '5 days'
            ORDER BY COALESCE(o.updated_at, o.date_time_created) DESC NULLS LAST
            LIMIT 20
        """)
        cols=[d[0] for d in cur.description]
        rows=[dict(zip(cols,r)) for r in cur.fetchall()]
        for r in rows:
            for k,v in list(r.items()):
                if hasattr(v,'isoformat'): r[k]=v.isoformat()
                elif v is not None and not isinstance(v,(str,int,float,bool)): r[k]=str(v)
        print('RECENT', json.dumps(rows, ensure_ascii=False))

        # orders where Diana is customer OR driver responded
        diana='132ipwKCpbXrRTyC2p4RNIkkf6D2'
        cur.execute("""
            SELECT o.id, o.status, o.budget, o.current_price, o.user_customer_id,
                   o.selected_driver_id, o.updated_at,
                   o.raw_json->'user_who_responced' as who
            FROM app_orders o
            WHERE o.user_customer_id=%s
               OR o.selected_driver_id=%s
               OR o.raw_json::text LIKE %s
            ORDER BY COALESCE(o.updated_at, o.date_time_created) DESC NULLS LAST
            LIMIT 15
        """, (diana, diana, '%'+diana+'%'))
        cols=[d[0] for d in cur.description]
        rows=[dict(zip(cols,r)) for r in cur.fetchall()]
        for r in rows:
            for k,v in list(r.items()):
                if hasattr(v,'isoformat'): r[k]=v.isoformat()
                elif v is not None and not isinstance(v,(str,int,float,bool)): r[k]=str(v)
        print('DIANA_RELATED', json.dumps(rows, ensure_ascii=False))

        # responses last 5 days
        cur.execute("""
            SELECT order_id, firestore_id, raw_json->>'driver_id' as driver,
                   raw_json->>'price' as price, inserted_at
            FROM app_order_responses
            ORDER BY inserted_at DESC NULLS LAST
            LIMIT 15
        """)
        print('RESP', cur.fetchall())
'''
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_recent_price.py", "w") as f:
        f.write(py)
    sftp.close()
    _, out, err = ssh.exec_command(
        "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
        "./venv/bin/python /tmp/_recent_price.py",
        timeout=60,
    )
    print(out.read().decode("utf-8", "replace"))
    print(err.read().decode("utf-8", "replace")[-2000:])

    for cmd in [
        "journalctl -u cab.service --since '7 days ago' --no-pager | grep -iE 'price_changed|patch_order|fcm' | tail -n 60",
        "ls -la /var/log/cab* 2>/dev/null; ls /root/projects/cab_drive/*.log 2>/dev/null | head",
    ]:
        _, o, e = ssh.exec_command(cmd, timeout=60)
        print("CMD", cmd[:50])
        print(o.read().decode("utf-8", "replace")[-3500:])
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
