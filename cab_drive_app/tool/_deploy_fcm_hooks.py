"""Deploy server-first FCM hooks (accept / price / chat)."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD") or os.environ.get(
    "CAB_SSH_PASSWORD", ""
)
# fallback как в других tool/_deploy_*.py этого репо (если env пуст)
if not PASSWORD:
    PASSWORD = "wZX++X-+TJ7kqn"
REMOTE_ROOT = "/root/projects/cab_drive"
LOCAL_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "server"))

FILES = [
    "app_fcm_ops.py",
    "app_order_ops.py",
    "app_chat_pg.py",
]


def run(ssh: paramiko.SSHClient, cmd: str) -> str:
    _, out, err = ssh.exec_command(cmd)
    data = out.read().decode("utf-8", "replace")
    err_data = err.read().decode("utf-8", "replace")
    if err_data.strip():
        data += "\n" + err_data
    return data.strip()


def main() -> int:
    if not PASSWORD:
        print("CAB_DRIVE_SSH_PASSWORD not set", file=sys.stderr)
        return 1

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    for rel in FILES:
        local = os.path.join(LOCAL_ROOT, rel.replace("/", os.sep))
        remote = f"{REMOTE_ROOT}/{rel}"
        print(f"put {rel}")
        sftp.put(local, remote)
    sftp.close()

    print("--- restart ---")
    print(run(ssh, "systemctl restart cab.service cab-wss.service && sleep 2 && systemctl is-active cab.service cab-wss.service"))
    print("--- health ---")
    print(run(ssh, "curl -sS http://127.0.0.1:5000/api/app/health"))
    ssh.close()
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
