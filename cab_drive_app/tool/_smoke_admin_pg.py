"""Smoke admin PG helpers via cab.service venv on VPS."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD")


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
    try:
        print("--- unit ---")
        print(run(ssh, "systemctl cat cab.service | sed -n '1,50p'"))
        print("--- resolve python ---")
        print(
            run(
                ssh,
                "grep ExecStart /etc/systemd/system/cab.service; "
                "ls -la /root/projects/cab_drive/venv/bin/python 2>/dev/null; "
                "ls -la /root/projects/cab_drive/.venv/bin/python 2>/dev/null",
            )
        )
        py = "/root/projects/cab_drive/venv/bin/python"
        print("using", py)
        print("--- smoke ---")
        # Write a tiny remote script to avoid shell quoting issues.
        script = (
            "import datetime\n"
            "import app_pg\n"
            "r = app_pg.list_orders_filtered(limit=3, offset=0)\n"
            "print('enabled', app_pg.enabled())\n"
            "print('total', r.get('total'), 'n', len(r.get('orders') or []))\n"
            "s = app_pg.driver_order_stats(\n"
            "    'x',\n"
            "    month_start=datetime.datetime(2026, 1, 1),\n"
            "    month_end=datetime.datetime(2026, 1, 31),\n"
            ")\n"
            "print('stats_empty_driver', s)\n"
            "b = app_pg.sum_driver_completed_budget('x')\n"
            "print('sum_budget', b)\n"
        )
        remote = "/tmp/_smoke_admin_pg.py"
        sftp = ssh.open_sftp()
        try:
            with sftp.file(remote, "w") as f:
                f.write(script)
        finally:
            sftp.close()
        print(
            run(
                ssh,
                f"cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
                f"{py} {remote}",
            )
        )
    finally:
        ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
