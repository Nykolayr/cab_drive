"""Diag Diana: completed orders + stuck on_confirmation."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)

REMOTE = r'''
import json
import sys
sys.path.insert(0, "/root/projects/cab_drive")
import app_pg

with app_pg.connection() as conn:
    with conn.cursor() as cur:
        cur.execute(
            "select id, phone_number, display_name, balance, is_driver "
            "from app_users where phone_number like %s or phone_number like %s limit 5",
            ("%79667499985%", "%9667499985%"),
        )
        cols = [d[0] for d in cur.description]
        users = [dict(zip(cols, r)) for r in cur.fetchall()]
print("USERS", json.dumps(users, default=str, ensure_ascii=False))
if not users:
    raise SystemExit(0)
uid = users[0]["id"]

with app_pg.connection() as conn:
    with conn.cursor() as cur:
        cur.execute(
            "select status, count(*)::int as c from app_orders "
            "where selected_driver_id = %s group by status order by c desc",
            (uid,),
        )
        print("DRIVER_BY_STATUS", cur.fetchall())

        cur.execute(
            "select status, count(*)::int as c from app_orders "
            "where user_customer_id = %s group by status order by c desc",
            (uid,),
        )
        print("CUSTOMER_BY_STATUS", cur.fetchall())

        cur.execute(
            """
            select id, status, current_price, budget, date_time_created, date_upd,
                   selected_driver_id, user_customer_id
            from app_orders
            where selected_driver_id = %s and status = 'completed'
            order by coalesce(date_upd, date_time_created) desc nulls last
            limit 25
            """,
            (uid,),
        )
        cols = [d[0] for d in cur.description]
        print("COMPLETED_AS_DRIVER", json.dumps([dict(zip(cols, r)) for r in cur.fetchall()], default=str, ensure_ascii=False))

        cur.execute(
            """
            select id, status, current_price, date_time_created, date_upd,
                   selected_driver_id, user_customer_id,
                   extract(epoch from ((now() at time zone 'utc') - coalesce(date_upd, date_time_created)))/3600.0 as hours_stuck
            from app_orders
            where status = 'on_confirmation'
              and (selected_driver_id = %s or user_customer_id = %s)
            order by coalesce(date_upd, date_time_created) asc nulls last
            limit 20
            """,
            (uid, uid),
        )
        cols = [d[0] for d in cur.description]
        print("ON_CONFIRM_DIANA", json.dumps([dict(zip(cols, r)) for r in cur.fetchall()], default=str, ensure_ascii=False))

        cur.execute(
            """
            select id, status, date_upd, selected_driver_id, user_customer_id,
                   extract(epoch from ((now() at time zone 'utc') - date_upd))/3600.0 as hours_stuck
            from app_orders
            where status = 'on_confirmation' and date_upd is not null
            order by date_upd asc
            limit 40
            """
        )
        cols = [d[0] for d in cur.description]
        print("ON_CONFIRM_ALL", json.dumps([dict(zip(cols, r)) for r in cur.fetchall()], default=str, ensure_ascii=False)[:7000])

        # September 2026 completed for Diana as driver — what history should show
        cur.execute(
            """
            select id, status, current_price, date_time_created, date_upd
            from app_orders
            where selected_driver_id = %s
              and status = 'completed'
              and date_time_created >= '2026-09-01'
              and date_time_created < '2026-10-01'
            order by date_time_created desc
            """,
            (uid,),
        )
        cols = [d[0] for d in cur.description]
        print("SEP_COMPLETED_BY_CREATED", json.dumps([dict(zip(cols, r)) for r in cur.fetchall()], default=str, ensure_ascii=False))

        cur.execute(
            """
            select id, status, current_price, date_time_created, date_upd
            from app_orders
            where selected_driver_id = %s
              and status = 'completed'
              and date_upd >= '2026-09-01'
              and date_upd < '2026-10-01'
            order by date_upd desc
            """,
            (uid,),
        )
        cols = [d[0] for d in cur.description]
        print("SEP_COMPLETED_BY_UPD", json.dumps([dict(zip(cols, r)) for r in cur.fetchall()], default=str, ensure_ascii=False))

        cur.execute(
            """
            select id, status, current_price, date_time_created, date_upd
            from app_orders
            where selected_driver_id = %s
              and status in ('completed','hidden')
            order by coalesce(date_upd, date_time_created) desc nulls last
            limit 15
            """,
            (uid,),
        )
        cols = [d[0] for d in cur.description]
        print("RECENT_DONE", json.dumps([dict(zip(cols, r)) for r in cur.fetchall()], default=str, ensure_ascii=False))
'''


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=60)
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_diag_diana_tx.py", "w") as f:
        f.write(REMOTE)
    sftp.close()
    _, out, err = ssh.exec_command(
        "cd /root/projects/cab_drive && ./venv/bin/python /tmp/_diag_diana_tx.py",
        timeout=90,
    )
    print(out.read().decode("utf-8", "replace")[:14000])
    e = err.read().decode("utf-8", "replace")
    if e.strip():
        print("ERR", e[:2500])
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
