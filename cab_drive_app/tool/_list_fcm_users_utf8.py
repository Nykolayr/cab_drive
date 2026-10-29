"""UTF-8 names of users with valid FCM (not owner)."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)

SQL = r"""
SET client_encoding TO 'UTF8';
SELECT id,
       display_name,
       surname,
       phone_number,
       is_driver,
       updated_at::text AS updated_at
FROM app_users u
WHERE RIGHT(REGEXP_REPLACE(COALESCE(phone_number,''), '[^0-9]', '', 'g'), 10) <> '9526818276'
  AND EXISTS (
    SELECT 1 FROM app_user_fcm_tokens t
    WHERE t.user_id = u.id AND length(t.token) >= 80 AND position(':' in t.token) > 0
  )
ORDER BY updated_at DESC NULLS LAST
LIMIT 20;
"""


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_tok_users.sql", "w") as f:
        f.write(SQL)
    sftp.close()
    _, out, err = ssh.exec_command(
        'psql "$(cat /root/cab_drive_database_url.txt)" -f /tmp/_tok_users.sql'
    )
    print(out.read().decode("utf-8", "replace"))
    print(err.read().decode("utf-8", "replace"))
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
