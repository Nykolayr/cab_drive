"""Deploy dashboard verification PG-first package."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD")
REMOTE_ROOT = "/root/projects/cab_drive"
LOCAL_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "server"))

FILES = [
    "app_pg.py",
    "app_verifications_ops.py",
    "users/api.py",
    "users/urls.py",
    "templates/dashboard/user.html",
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
        run(ssh, f"mkdir -p {REMOTE_ROOT}/templates/dashboard {REMOTE_ROOT}/users")
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
                "python3 -c 'import app_verifications_ops, app_pg; "
                "print(\"ok\", hasattr(app_verifications_ops,\"approve_by_user_id\"), "
                "hasattr(app_pg,\"get_latest_verification_for_user\"))'",
            )
        )
        print("--- routes ---")
        for path in (
            "/api/users/verification/approve",
            "/api/users/verification/reject",
        ):
            print(
                run(
                    ssh,
                    f"curl -sS -o /tmp/v.json -w '%{{http_code}}' -X POST "
                    f"https://cab.artean.ru{path} -H 'Content-Type: application/json' -d '{{}}'; "
                    "echo; head -c 120 /tmp/v.json; echo",
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
