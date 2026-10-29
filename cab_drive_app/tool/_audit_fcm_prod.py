"""Audit FCM on prod: recent logs + token counts + code hooks."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)


def run(ssh: paramiko.SSHClient, cmd: str) -> str:
    _, out, err = ssh.exec_command(cmd)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    print("=== deployed hooks ===")
    print(
        run(
            ssh,
            "grep -n 'notify_safe\\|create_bid\\|price_changed\\|fcm' "
            "/root/projects/cab_drive/app_bids_ops.py "
            "/root/projects/cab_drive/app_order_ops.py "
            "/root/projects/cab_drive/app_fcm_ops.py 2>/dev/null | head -60",
        )
    )
    print("=== journal fcm last 3d ===")
    print(
        run(
            ssh,
            "journalctl -u cab.service --since '3 days ago' --no-pager 2>/dev/null | "
            "grep -iE 'app_fcm|notify_safe|create_bid|price_changed|No FCM|fcm notify' | tail -80",
        )
    )
    print("=== pg tokens sample ===")
    print(
        run(
            ssh,
            "sudo -u postgres psql -d cab_drive_app -c "
            "\"SELECT COUNT(*) AS tokens, COUNT(DISTINCT user_id) AS users "
            "FROM app_user_fcm_tokens;\" 2>/dev/null || "
            "psql \"$(cat /root/cab_drive_database_url.txt)\" -c "
            "\"SELECT COUNT(*) AS tokens, COUNT(DISTINCT user_id) AS users "
            "FROM app_user_fcm_tokens;\"",
        )
    )
    print("=== get_order has respondents? ===")
    print(
        run(
            ssh,
            "grep -n 'user_who_responced' /root/projects/cab_drive/app_pg.py | head -20",
        )
    )
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
