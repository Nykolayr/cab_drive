"""Deploy price_changed FCM for newOrder (on-shift drivers)."""
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
REMOTE = "/root/projects/cab_drive/app_order_ops.py"
LOCAL = ROOT / "server" / "app_order_ops.py"


def run(ssh: paramiko.SSHClient, cmd: str, timeout: int = 120) -> str:
    _, stdout, stderr = ssh.exec_command(cmd, timeout=timeout)
    out = stdout.read().decode("utf-8", "replace")
    err = stderr.read().decode("utf-8", "replace")
    return (out + err).strip()


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
            print(run(ssh, "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service"))
            print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
            # smoke: import patch path
            smoke = r'''
import sys
sys.path.insert(0, "/root/projects/cab_drive")
import app as _a
import inspect, app_order_ops
src = inspect.getsource(app_order_ops.patch_order_by_customer)
assert "list_drivers_for_geo" in src and "price_changed" in src
print("patch_order_price_fcm_ok")
'''
            sftp = ssh.open_sftp()
            with sftp.file("/tmp/_smoke_price_fcm.py", "w") as f:
                f.write(smoke)
            sftp.close()
            print(run(ssh, "cd /root/projects/cab_drive && python3 /tmp/_smoke_price_fcm.py"))
            # FCM smoke to test phone
            fcm = r'''
import sys, json
sys.path.insert(0, "/root/projects/cab_drive")
import app as _a
import app_push
print(json.dumps(app_push.smoke_to_phone("+79526818276", title="Cab Drive", body="Тест пуша: смена цены / complete fix"), ensure_ascii=False))
'''
            sftp = ssh.open_sftp()
            with sftp.file("/tmp/_smoke_fcm.py", "w") as f:
                f.write(fcm)
            sftp.close()
            print(run(ssh, "cd /root/projects/cab_drive && python3 /tmp/_smoke_fcm.py"))
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
