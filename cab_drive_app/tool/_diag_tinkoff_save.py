"""Diagnose why tinkoff_mode save may fail on VPS."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD") or os.environ.get(
    "CAB_SSH_PASSWORD", ""
)


def run(ssh: paramiko.SSHClient, cmd: str) -> str:
    _, out, err = ssh.exec_command(cmd)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    print("=== cab.service user ===")
    print(run(ssh, "systemctl show cab.service -p User -p Group -p WorkingDirectory -p ExecStart --no-pager"))
    print("=== file perms ===")
    print(run(ssh, "ls -la /root/projects/cab_drive/settings_model/model.json; id; namei -l /root/projects/cab_drive/settings_model/model.json"))
    print("=== try write as service user ===")
    print(
        run(
            ssh,
            "SERVICE_USER=$(systemctl show cab.service -p User --value); "
            "echo service_user=$SERVICE_USER; "
            "if [ -z \"$SERVICE_USER\" ] || [ \"$SERVICE_USER\" = root ]; then "
            "  touch /tmp/cab_write_test && echo root_ok; "
            "  python3 -c \"open('/root/projects/cab_drive/settings_model/model.json','a').close(); print('append_ok')\"; "
            "else "
            "  su -s /bin/bash \"$SERVICE_USER\" -c \"python3 -c \\\"open('/root/projects/cab_drive/settings_model/model.json','a').close(); print('append_ok')\\\"\" 2>&1; "
            "fi",
        )
    )
    print("=== recent settings save logs ===")
    print(
        run(
            ssh,
            "journalctl -u cab.service --since '7 days ago' --no-pager 2>/dev/null | "
            "grep -iE 'tinkoff|settings|model.json|Permission|update_tinkoff' | tail -40",
        )
    )
    print("=== gunicorn cwd / processes ===")
    print(run(ssh, "ps aux | grep -E '[g]unicorn|[c]ab' | head -20"))
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
