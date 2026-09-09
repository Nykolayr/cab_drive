"""Deploy pickup/extra PG-first package."""
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
    "app_order_ops.py",
    "orders/api.py",
    "orders/extra_orders.py",
    "orders/view.py",
    "orders/pickup_api.py",
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
        run(ssh, f"mkdir -p {REMOTE_ROOT}/orders")
        for rel in FILES:
            local = os.path.join(LOCAL_ROOT, rel.replace("/", os.sep))
            print(f"upload {rel}")
            sftp.put(local, f"{REMOTE_ROOT}/{rel}")
        print("--- restart ---")
        print(run(ssh, "systemctl restart cab.service && sleep 3 && systemctl is-active cab.service"))
        py = "/root/projects/cab_drive/venv/bin/python"
        remote = "/tmp/_smoke_pickup_extra.py"
        script = (
            "import app_pg\n"
            "from orders.pickup_api import fetch_drivers_within_radius\n"
            "print('helpers', hasattr(app_pg,'list_drivers_for_geo'), hasattr(app_pg,'list_orders_by_statuses'))\n"
            "print('extra_accept', hasattr(__import__('app_order_ops'),'extra_accept'))\n"
            "d = app_pg.list_drivers_for_geo(limit=5)\n"
            "print('drivers_on_shift', len(d))\n"
            "r = fetch_drivers_within_radius(55.75, 37.62, 50.0)\n"
            "print('within_radius', len(r))\n"
            "n = app_pg.list_orders(status='newOrder', limit=5)\n"
            "print('newOrder', len(n))\n"
        )
        with sftp.file(remote, "w") as f:
            f.write(script)
        print("--- smoke ---")
        print(
            run(
                ssh,
                f"cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive {py} {remote}",
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
