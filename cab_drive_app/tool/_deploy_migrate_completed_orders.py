"""Запуск migrate_completed_orders_to_hidden.py на сервере."""
from __future__ import annotations

import os
import sys
import time
from pathlib import Path

import paramiko

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
    or "wZX++X-+TJ7kqn"
)
ROOT = Path(r"D:\Projects\cab_drive")
REMOTE_DIR = "/root/projects/cab_drive"
LOCAL_SCRIPT = ROOT / "server" / "scripts" / "migrate_completed_orders_to_hidden.py"
REMOTE_SCRIPT = "/tmp/migrate_completed_orders_to_hidden.py"


def _ssh():
    for attempt in range(6):
        try:
            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            client.connect(HOST, username=USER, password=PASSWORD, timeout=90)
            return client
        except Exception as e:
            print(f"[ssh] attempt {attempt + 1}/6 failed: {e}", file=sys.stderr)
            time.sleep(10)
    raise RuntimeError("ssh failed")


def _run(cmd: str) -> tuple[int, str, str]:
    with _ssh() as client:
        _stdin, stdout, stderr = client.exec_command(cmd)
        out = stdout.read().decode("utf-8", errors="replace")
        err = stderr.read().decode("utf-8", errors="replace")
        code = stdout.channel.recv_exit_status()
        return code, out, err


def _upload(client: paramiko.SSHClient) -> None:
    sftp = client.open_sftp()
    try:
        sftp.put(str(LOCAL_SCRIPT), REMOTE_SCRIPT)
    finally:
        sftp.close()


def main(dry_run: bool = True) -> int:
    print(f"[deploy] {'dry-run' if dry_run else 'APPLY'}: {REMOTE_SCRIPT}")
    flag = "" if dry_run else "--apply"
    with _ssh() as client:
        _upload(client)
    code, out, err = _run(f"cd {REMOTE_DIR} && python {REMOTE_SCRIPT} {flag}")
    print(out)
    if err:
        print(err, file=sys.stderr)
    print(f"[deploy] exit code: {code}")
    return code


if __name__ == "__main__":
    dry = "--apply" not in sys.argv
    raise SystemExit(main(dry_run=dry))
