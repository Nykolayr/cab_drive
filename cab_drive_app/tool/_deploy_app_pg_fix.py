"""Deploy app_pg.py fix to server."""
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
LOCAL = Path(r"D:\Projects\cab_drive\server\app_pg.py")
REMOTE = "/root/projects/cab_drive/app_pg.py"


def main() -> int:
    for attempt in range(6):
        try:
            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            client.connect(HOST, username=USER, password=PASSWORD, timeout=90)
            sftp = client.open_sftp()
            try:
                sftp.put(str(LOCAL), REMOTE)
            finally:
                sftp.close()
            client.close()
            print(f"[deploy] uploaded {REMOTE}")
            return 0
        except Exception as e:
            print(f"[ssh] attempt {attempt + 1}/6 failed: {e}", file=sys.stderr)
            time.sleep(10)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
