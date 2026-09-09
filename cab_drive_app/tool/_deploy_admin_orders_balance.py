"""Deploy admin orders list + driver balance/stats PG-first."""
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
    "users/api.py",
    "orders/api.py",
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
        run(ssh, f"mkdir -p {REMOTE_ROOT}/users {REMOTE_ROOT}/orders")
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
                "python3 -c '"
                "import app_pg; "
                "print(\"ok\", "
                "hasattr(app_pg,\"list_orders_filtered\"), "
                "hasattr(app_pg,\"sum_driver_completed_budget\"), "
                "hasattr(app_pg,\"driver_order_stats\"))"
                "'",
            )
        )
        print("--- health ---")
        print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
        print("--- smoke list_orders_filtered ---")
        print(
            run(
                ssh,
                "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
                "python3 -c '"
                "import app_pg; "
                "r=app_pg.list_orders_filtered(limit=3, offset=0); "
                "print(\"total\", r.get(\"total\"), \"n\", len(r.get(\"orders\") or []), "
                "\"src keys\", list((r.get(\"orders\") or [{}])[0].keys())[:8] if r.get(\"orders\") else [])"
                "'",
            )
        )
    finally:
        sftp.close()
        ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
