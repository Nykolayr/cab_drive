"""Deploy finance logging + payout ops; smoke Diana balance + journal."""
from __future__ import annotations

import os
import time
from pathlib import Path

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)
ROOT = Path(r"D:\Projects\cab_drive")
FILES = [
    ("server/app_finance_log.py", "/root/projects/cab_drive/app_finance_log.py"),
    ("server/app_payout_ops.py", "/root/projects/cab_drive/app_payout_ops.py"),
    ("server/app_order_ops.py", "/root/projects/cab_drive/app_order_ops.py"),
]

REMOTE_PG = r'''
import json, sys
sys.path.insert(0, "/root/projects/cab_drive")
import app_pg
m = app_pg.get_me("132ipwKCpbXrRTyC2p4RNIkkf6D2") or {}
print(json.dumps({
  "balance": m.get("balance"),
  "bonus_balance": m.get("bonus_balance"),
  "current_commision": m.get("current_commision"),
  "contractor_id": m.get("contractor_id"),
}, default=str, ensure_ascii=False))
'''


def main() -> int:
    last_err: Exception | None = None
    for attempt in range(4):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(
                HOST,
                username=USER,
                password=PASSWORD,
                timeout=90,
                banner_timeout=90,
                auth_timeout=90,
            )
            print("connected", attempt + 1)
            sftp = ssh.open_sftp()
            for local, remote in FILES:
                data = (ROOT / local).read_bytes()
                with sftp.file(remote, "wb") as f:
                    f.write(data)
                print("uploaded", remote, len(data))
            with sftp.file("/tmp/_pg_diana.py", "w") as f:
                f.write(REMOTE_PG)
            sftp.close()

            _, out, err = ssh.exec_command(
                "systemctl restart cab.service; sleep 2; "
                "systemctl is-active cab.service; "
                "curl -sS https://cab.artean.ru/api/app/health",
                timeout=60,
            )
            print(out.read().decode("utf-8", "replace"))
            e = err.read().decode("utf-8", "replace")
            if e.strip():
                print("ERR", e[:500])

            _, out, err = ssh.exec_command(
                "cd /root/projects/cab_drive && ./venv/bin/python /tmp/_pg_diana.py",
                timeout=60,
            )
            print("PG", out.read().decode("utf-8", "replace"))
            e = err.read().decode("utf-8", "replace")
            if e.strip():
                print("ERR", e[:800])

            _, out, err = ssh.exec_command(
                "journalctl -u cab.service --since '5 days ago' --no-pager "
                "| grep -iE 'payout|182142163|182142160|pending_no_debit|finance' "
                "| tail -50",
                timeout=60,
            )
            print("LOGS", out.read().decode("utf-8", "replace")[:5000])
            ssh.close()
            return 0
        except Exception as ex:
            last_err = ex
            print("fail", attempt + 1, ex)
            time.sleep(8)
    raise SystemExit(f"ssh failed: {last_err}")


if __name__ == "__main__":
    raise SystemExit(main())
