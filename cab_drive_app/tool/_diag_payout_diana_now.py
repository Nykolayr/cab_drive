"""Diag Diana latest payout vs PG balance."""
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
import json, sys
sys.path.insert(0, "/root/projects/cab_drive")
import app_pg

uid = "132ipwKCpbXrRTyC2p4RNIkkf6D2"
me = app_pg.get_me(uid) or {}
print("ME", json.dumps({
  "balance": me.get("balance"),
  "bonus_balance": me.get("bonus_balance"),
  "current_commision": me.get("current_commision"),
  "display_name": me.get("display_name"),
  "phone_number": me.get("phone_number"),
}, default=str, ensure_ascii=False))

# payouts table if any
with app_pg.connection() as conn:
    with conn.cursor() as cur:
        cur.execute("""
          SELECT column_name FROM information_schema.columns
          WHERE table_name LIKE 'app_%pay%' OR table_name LIKE '%payout%'
          ORDER BY table_name, ordinal_position
        """)
        print("COLS", cur.fetchall()[:80])
        cur.execute("""
          SELECT table_name FROM information_schema.tables
          WHERE table_schema='public' AND (
            table_name ILIKE '%pay%' OR table_name ILIKE '%payout%' OR table_name ILIKE '%jump%'
          )
        """)
        print("TABLES", cur.fetchall())
'''


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=60)
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_diag_payout_diana.py", "w") as f:
        f.write(REMOTE)
    sftp.close()
    cmds = [
        "cd /root/projects/cab_drive && ./venv/bin/python /tmp/_diag_payout_diana.py",
        "journalctl -u cab.service --since '3 days ago' --no-pager | grep -iE 'payout|jump|/me/payout|132ipwKCpbXrRTyC2p4RNIkkf6D2' | tail -80",
    ]
    for c in cmds:
        print("===", c[:70])
        _, out, err = ssh.exec_command(c, timeout=90)
        print(out.read().decode("utf-8", "replace")[:6000])
        e = err.read().decode("utf-8", "replace")
        if e.strip():
            print("ERR", e[:800])
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
