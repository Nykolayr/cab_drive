"""Sample bad FCM tokens."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sql = """
SELECT user_id, token, length(token) FROM app_user_fcm_tokens WHERE length(token) < 80 LIMIT 15;
SELECT user_id, left(token,40), length(token) FROM app_user_fcm_tokens WHERE length(token) >= 80 LIMIT 10;
"""
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_tok_sample.sql", "w") as f:
        f.write(sql)
    sftp.close()
    _, out, err = ssh.exec_command(
        'psql "$(cat /root/cab_drive_database_url.txt)" -f /tmp/_tok_sample.sql'
    )
    print(out.read().decode("utf-8", "replace"))
    print(err.read().decode("utf-8", "replace"))
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
