"""Verify tinkoff mode after fix."""
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
    print("=== file ===")
    print(
        run(
            ssh,
            "python3 -c \"import json; d=json.load(open('/root/projects/cab_drive/settings_model/model.json')); print(d.get('tinkoff_mode'), d.get('payments_base_url'))\"",
        )
    )
    print("=== ls ===")
    print(run(ssh, "ls -la /root/projects/cab_drive/settings_model/model.json"))
    print("=== public tinkoff config if any ===")
    print(
        run(
            ssh,
            "curl -sS http://127.0.0.1:5000/api/tinkoff/config 2>/dev/null | head -c 500; echo; "
            "curl -sS http://127.0.0.1:5000/kek/settings/tinkoff 2>/dev/null | head -c 300",
        )
    )
    print("=== worker log mode ===")
    print(
        run(
            ssh,
            "journalctl -u cab.service -n 30 --no-pager | grep -i tinkoff || true",
        )
    )
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
