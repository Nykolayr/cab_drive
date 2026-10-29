"""Deploy simplified tinkoff UI."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)
REMOTE = "/root/projects/cab_drive/templates/dashboard/tinkoff.html"
LOCAL = os.path.abspath(
    os.path.join(
        os.path.dirname(__file__),
        "..",
        "..",
        "server",
        "templates",
        "dashboard",
        "tinkoff.html",
    )
)


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    print("put tinkoff.html")
    sftp.put(LOCAL, REMOTE)
    sftp.close()
    _, out, err = ssh.exec_command(
        "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service"
    )
    print(out.read().decode(), err.read().decode())
    ssh.close()
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
