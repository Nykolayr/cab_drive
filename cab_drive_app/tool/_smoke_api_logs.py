"""Inspect nginx/app access for /api/app vs firestore soft-fs."""
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
        print("no password", file=sys.stderr)
        return 1
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username="root", password=PASSWORD, timeout=30)
    try:
        print("--- health ---")
        print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
        print("--- recent /api/app (nginx) ---")
        print(
            run(
                ssh,
                "for f in /var/log/nginx/access.log /var/log/nginx/cab.artean.ru.access.log "
                "/var/log/nginx/access.log.1; do "
                "[ -f \"$f\" ] && echo FILE:$f && grep -E '/api/app/' \"$f\" | tail -n 40; "
                "done 2>/dev/null | tail -n 80",
            )
        )
        print("--- journal cab soft_fs / app_pg last 15m ---")
        print(
            run(
                ssh,
                "journalctl -u cab.service --since '15 min ago' --no-pager 2>/dev/null | "
                "grep -E 'soft_fs|APP_FS_MIRROR|extra_notify|/api/app|app_pg' | tail -n 60 || true",
            )
        )
        print("--- count api paths last access log ---")
        print(
            run(
                ssh,
                "LOG=$(ls -1t /var/log/nginx/*access* 2>/dev/null | head -n1); "
                "echo using=$LOG; "
                "grep -oE '/api/app/[A-Za-z0-9_./-]+' \"$LOG\" 2>/dev/null | sort | uniq -c | sort -nr | head -n 30",
            )
        )
    finally:
        ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
