"""Deploy client-errors (шаблон ClientErrorReporter) + migrate 006."""
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
    "app_client_errors_ops.py",
    "app_data/__init__.py",
    "migrations/postgres/006_client_errors.sql",
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
        remote_dir = os.path.dirname(remote)
        run(ssh, f"mkdir -p {remote_dir}")
        print(f"put {rel}")
        sftp.put(local, remote)

    sftp.close()

    print("--- migrate 006 ---")
    print(
        run(
            ssh,
            "DBURL=$(cat /root/cab_drive_database_url.txt); "
            f"psql \"$DBURL\" -v ON_ERROR_STOP=1 "
            f"-f {REMOTE_ROOT}/migrations/postgres/006_client_errors.sql",
        )
    )

    print("--- restart cab.service ---")
    print(run(ssh, "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service"))

    print("--- smoke POST client-errors ---")
    print(
        run(
            ssh,
            "curl -sS -o /tmp/ce_out.txt -w '%{http_code}' -X POST "
            "http://127.0.0.1:5000/api/app/client-errors "
            "-H 'Content-Type: application/json' "
            "-d '{\"message\":\"deploy-smoke\",\"tag\":\"deploy\",\"platform\":\"linux\","
            "\"appVersion\":\"0\",\"buildNumber\":\"0\",\"fatal\":false}' "
            "; echo; cat /tmp/ce_out.txt; echo",
        )
    )

    ssh.close()
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
