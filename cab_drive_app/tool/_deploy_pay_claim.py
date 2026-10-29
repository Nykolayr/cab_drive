"""Deploy atomic pay_order claim (no double credit on AUTHORIZED+CONFIRMED)."""
from __future__ import annotations

import os
import time
from pathlib import Path

import paramiko

HOST = "37.252.20.248"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)
ROOT = Path(r"D:\Projects\cab_drive\server")
FILES = [
    ("app_pg.py", "/root/projects/cab_drive/app_pg.py"),
    ("tinkoff/webhook.py", "/root/projects/cab_drive/tinkoff/webhook.py"),
]


def run(ssh, cmd: str, timeout: int = 120) -> str:
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    last = None
    for attempt in range(6):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(
                HOST,
                username="root",
                password=PASSWORD,
                timeout=90,
                allow_agent=False,
                look_for_keys=False,
            )
            sftp = ssh.open_sftp()
            for rel, remote in FILES:
                sftp.put(str(ROOT / rel.replace("/", os.sep)), remote)
                print("uploaded", remote)
            sftp.close()
            print(run(ssh, "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service"))
            print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
            smoke = r'''
import sys
sys.path.insert(0, "/root/projects/cab_drive")
import app_pg, inspect
from tinkoff import webhook
assert hasattr(app_pg, "claim_pay_order_paid")
src = inspect.getsource(webhook._apply_paid_pg)
assert "claim_pay_order_paid" in src
assert "already_paid" in src
print("ok claim_pay_order_paid wired")
# dry: claim on already-paid Diana order should return False
print("claim_paid_row", app_pg.claim_pay_order_paid("56da23bfdb834567b3ae000c6b2a2e32", tinkoff_status="CONFIRMED"))
'''
            sftp = ssh.open_sftp()
            with sftp.file("/tmp/_smoke_claim_paid.py", "w") as f:
                f.write(smoke)
            sftp.close()
            print(
                run(
                    ssh,
                    "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
                    "./venv/bin/python /tmp/_smoke_claim_paid.py",
                )
            )
            ssh.close()
            return 0
        except Exception as e:
            last = e
            print(f"attempt {attempt+1} fail: {e}")
            time.sleep(5)
    print("FAILED", last)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
