"""Redeploy reviews to live VPS root (/root/projects/cab_drive)."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD")
REMOTE_ROOT = "/root/projects/cab_drive"
LOCAL_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "server"))

FILES = [
    "app_reviews_ops.py",
    "app_pg.py",
    "app_data/__init__.py",
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
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=30)
    sftp = ssh.open_sftp()
    try:
        for rel in FILES:
            local = os.path.join(LOCAL_ROOT, rel.replace("/", os.sep))
            remote = f"{REMOTE_ROOT}/{rel}"
            print(f"upload {rel} -> {remote}")
            sftp.put(local, remote)

        print("--- restart ---")
        print(run(ssh, "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service"))
        print("--- import ---")
        print(
            run(
                ssh,
                "cd /root/projects/cab_drive && "
                "PYTHONPATH=/root/projects/cab_drive python3 -c "
                "'import app_reviews_ops, app_pg; print(\"import_ok\", app_pg.enabled())'",
            )
        )
        print("--- health ---")
        print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
        print("--- reviews auth ---")
        print(
            run(
                ssh,
                "curl -sS -o /tmp/rev.json -w '%{http_code}' "
                "https://cab.artean.ru/api/app/reviews?mine=true; echo; head -c 200 /tmp/rev.json",
            )
        )
    finally:
        sftp.close()
        ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
