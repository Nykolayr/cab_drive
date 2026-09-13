"""Deploy payout PG path + ensure contractor_id column."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
    or "wZX++X-+TJ7kqn"
)
REMOTE_ROOT = "/root/projects/cab_drive"
LOCAL_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "server"))

FILES = [
    "app_payout_ops.py",
    "app_pg.py",
    "app_data/__init__.py",
    "config.py",
]


def run(ssh: paramiko.SSHClient, cmd: str, timeout: int = 90) -> str:
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
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

    print("--- alter contractor_id if needed ---")
    print(
        run(
            ssh,
            'psql "$(cat /root/cab_drive_database_url.txt)" -c '
            "\"ALTER TABLE app_users ADD COLUMN IF NOT EXISTS contractor_id bigint;\"",
        )
    )
    print("--- restart ---")
    print(
        run(
            ssh,
            "systemctl restart cab.service && sleep 3 && systemctl is-active cab.service",
        )
    )
    print("--- health ---")
    print(run(ssh, "curl -sS http://127.0.0.1:5000/api/app/health"))
    print("--- import smoke ---")
    print(
        run(
            ssh,
            "cd /root/projects/cab_drive && ./venv/bin/python - <<'PY'\n"
            "import app as _a\n"
            "import app_payout_ops\n"
            "print('commission200', app_payout_ops.payout_commission(200))\n"
            "print('amount200', app_payout_ops.amount_to_card(200))\n"
            "PY",
        )
    )
    ssh.close()
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
