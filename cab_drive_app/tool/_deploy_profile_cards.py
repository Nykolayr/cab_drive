"""Deploy addresses + saved_cards to live VPS root."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD")
REMOTE_ROOT = "/root/projects/cab_drive"
LOCAL_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "server"))

FILES = [
    "app_profile_ops.py",
    "app_pg.py",
    "app_data/__init__.py",
    "migrations/postgres/005_saved_cards.sql",
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
        run(ssh, f"mkdir -p {REMOTE_ROOT}/migrations/postgres")
        for rel in FILES:
            local = os.path.join(LOCAL_ROOT, rel.replace("/", os.sep))
            print(f"upload {rel}")
            sftp.put(local, f"{REMOTE_ROOT}/{rel}")
        mig = f"{REMOTE_ROOT}/migrations/postgres/005_saved_cards.sql"
        print("--- migrate ---")
        print(
            run(
                ssh,
                "DBURL=$(cat /root/cab_drive_database_url.txt | tr -d '\\r\\n'); "
                f"psql \"$DBURL\" -v ON_ERROR_STOP=1 -f {mig}",
            )
        )
        print("--- restart ---")
        print(run(ssh, "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service"))
        print("--- import ---")
        print(
            run(
                ssh,
                "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
                "python3 -c 'import app_profile_ops, app_pg; print(\"ok\", app_pg.enabled())'",
            )
        )
        print("--- routes ---")
        for path in (
            "/api/app/cards",
            "/api/app/me/addresses/add",
        ):
            print(
                run(
                    ssh,
                    f"curl -sS -o /tmp/p.json -w '%{{http_code}}' https://cab.artean.ru{path}; echo; head -c 120 /tmp/p.json; echo",
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
