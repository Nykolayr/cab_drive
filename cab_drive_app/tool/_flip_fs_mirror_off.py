"""Flip APP_FS_MIRROR=0 on live VPS and smoke health."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD")
ENV_FILE = "/root/cab_drive_database_url.env"


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
        print("--- before health ---")
        print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
        print("--- locate APP_FS_MIRROR ---")
        print(
            run(
                ssh,
                "grep -RIn 'APP_FS_MIRROR' /root/cab_drive_database_url.env "
                "/root/projects/cab_drive /etc/systemd/system/cab.service "
                "/etc/systemd/system/cab.service.d 2>/dev/null | head -n 40 || true",
            )
        )
        print("--- systemd EnvironmentFile ---")
        print(run(ssh, "systemctl cat cab.service | sed -n '1,40p'"))

        remote = "/tmp/_flip_mirror.sh"
        sh = f"""#!/bin/bash
set -euo pipefail
F="{ENV_FILE}"
if [ ! -f "$F" ]; then
  echo "missing $F" >&2
  exit 1
fi
cp -a "$F" "$F.bak.$(date +%Y%m%d%H%M%S)"
if grep -q '^APP_FS_MIRROR=' "$F"; then
  sed -i 's/^APP_FS_MIRROR=.*/APP_FS_MIRROR=0/' "$F"
else
  printf '\\nAPP_FS_MIRROR=0\\n' >> "$F"
fi
echo "now:"
grep '^APP_FS_MIRROR=' "$F" || true
"""
        with sftp.file(remote, "w") as f:
            f.write(sh)
        print("--- apply ---")
        print(run(ssh, f"bash {remote}"))
        print("--- restart cab ---")
        print(
            run(
                ssh,
                "systemctl restart cab.service && sleep 3 && systemctl is-active cab.service",
            )
        )
        print("--- restart wss (best-effort) ---")
        print(
            run(
                ssh,
                "systemctl restart cab-wss.service 2>/dev/null; sleep 1; "
                "systemctl is-active cab-wss.service 2>/dev/null || echo wss-skip",
            )
        )
        print("--- after health ---")
        health = run(ssh, "curl -sS https://cab.artean.ru/api/app/health")
        print(health)
        print("--- process APP_FS_MIRROR ---")
        print(
            run(
                ssh,
                "PID=$(pgrep -n -f '/root/projects/cab_drive/venv/bin/gunicorn' || true); "
                "echo pid=$PID; "
                "if [ -n \"$PID\" ]; then tr '\\0' '\\n' < /proc/$PID/environ | "
                "grep '^APP_FS_MIRROR=' || echo 'APP_FS_MIRROR not in proc env'; fi",
            )
        )
        if '"fs_mirror":false' not in health and '"fs_mirror": false' not in health:
            print("WARNING: health did not show fs_mirror=false", file=sys.stderr)
            return 2
        print("OK mirror off")
        return 0
    finally:
        sftp.close()
        ssh.close()


if __name__ == "__main__":
    raise SystemExit(main())
