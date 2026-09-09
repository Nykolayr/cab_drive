"""Deploy FCM package to live VPS root."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD")
REMOTE_ROOT = "/root/projects/cab_drive"
LOCAL_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "server"))

FILES = [
    "app_fcm_ops.py",
    "app_pg.py",
    "app_data/__init__.py",
    "users/api.py",
]


def run(ssh, cmd: str) -> str:
    _, out, err = ssh.exec_command(cmd)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    if not PASSWORD:
        print("CAB_DRIVE_SSH_PASSWORD not set", file=sys.stderr)
        return 1
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username="root", password=PASSWORD, timeout=30)
    sftp = ssh.open_sftp()
    try:
        for rel in FILES:
            local = os.path.join(LOCAL_ROOT, rel.replace("/", os.sep))
            print(f"upload {rel}")
            sftp.put(local, f"{REMOTE_ROOT}/{rel}")
        print("--- restart ---")
        print(run(ssh, "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service"))
        print("--- import ---")
        print(
            run(
                ssh,
                "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
                "python3 -c 'import app_fcm_ops, app_pg; print(\"ok\", hasattr(app_pg,\"list_fcm_tokens\"))'",
            )
        )
        print("--- route ---")
        print(
            run(
                ssh,
                "curl -sS -o /tmp/p.json -w '%{http_code}' -X POST "
                "https://cab.artean.ru/api/app/push -H 'Content-Type: application/json' -d '{}'; "
                "echo; head -c 160 /tmp/p.json",
            )
        )
        print("--- health ---")
        print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
    finally:
        sftp.close()
        ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
