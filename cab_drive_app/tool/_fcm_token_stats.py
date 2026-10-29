"""Token length stats on prod."""
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
SELECT length(token) AS len, COUNT(*) FROM app_user_fcm_tokens GROUP BY 1 ORDER BY 1;
SELECT COUNT(*) AS bad FROM app_user_fcm_tokens WHERE length(token) < 80 OR position(':' in token) = 0;
"""
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_tok_stats.sql", "w") as f:
        f.write(sql)
    sftp.close()
    _, out, err = ssh.exec_command(
        'psql "$(cat /root/cab_drive_database_url.txt)" -f /tmp/_tok_stats.sql'
    )
    print(out.read().decode("utf-8", "replace"))
    print(err.read().decode("utf-8", "replace"))
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
