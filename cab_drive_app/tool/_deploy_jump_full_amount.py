"""Deploy Jump amount=full balance (no double commission)."""
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
LOCAL = Path(r"D:\Projects\cab_drive\server\app_payout_ops.py")
REMOTE = "/root/projects/cab_drive/app_payout_ops.py"


def run(ssh: paramiko.SSHClient, cmd: str, timeout: int = 120) -> str:
    _, stdout, stderr = ssh.exec_command(cmd, timeout=timeout)
    return (stdout.read() + stderr.read()).decode("utf-8", "replace").strip()


def main() -> int:
    last_err: Exception | None = None
    for attempt in range(6):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(
                HOST,
                username=USER,
                password=PASSWORD,
                timeout=90,
                allow_agent=False,
                look_for_keys=False,
            )
            sftp = ssh.open_sftp()
            sftp.put(str(LOCAL), REMOTE)
            sftp.close()
            print("uploaded", REMOTE)
            print(
                run(
                    ssh,
                    "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service",
                )
            )
            print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
            smoke = r'''
import sys
sys.path.insert(0, "/root/projects/cab_drive")
import inspect
import app_payout_ops as p

assert p.amount_to_card(200) == 100.0, p.amount_to_card(200)
assert p.payout_commission(200) == 100.0, p.payout_commission(200)
src = inspect.getsource(p.create_payout if hasattr(p, "create_payout") else p)
# function name for create
src = inspect.getsource(p)
assert "jump_amount = round(balance, 2)" in src
assert '"amount": jump_amount' in src
assert "двойное обрезание" in src or "jump_amount" in src
print("ok", "amount_to_card(200)=", p.amount_to_card(200), "commission=", p.payout_commission(200))
print("diana", __import__("json").dumps({
  "note": "create now sends jump_amount=balance; UI still shows amount_to_card",
}, ensure_ascii=False))
'''
            sftp = ssh.open_sftp()
            with sftp.file("/tmp/_smoke_jump_amount.py", "w") as f:
                f.write(smoke)
            sftp.close()
            print(
                run(
                    ssh,
                    "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
                    "./venv/bin/python /tmp/_smoke_jump_amount.py",
                )
            )
            # confirm live file
            print(
                run(
                    ssh,
                    "grep -n 'jump_amount = round' /root/projects/cab_drive/app_payout_ops.py | head",
                )
            )
            ssh.close()
            return 0
        except Exception as e:
            last_err = e
            print(f"attempt {attempt+1} fail: {e}")
            time.sleep(5)
    print("FAILED", last_err)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
