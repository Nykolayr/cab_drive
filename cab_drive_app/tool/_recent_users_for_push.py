"""Find recent users / admins besides owner's phone."""
from __future__ import annotations

import os

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)
OWNER_LAST10 = "9526818276"


def run(ssh: paramiko.SSHClient, cmd: str, timeout: int = 60) -> str:
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    return (out.read() + err.read()).decode("utf-8", "replace").strip()


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)

    sql = f"""
-- recent app users (not owner)
SELECT id, display_name, surname, phone_number, is_driver, on_shift, updated_at,
       (SELECT COUNT(*) FROM app_user_fcm_tokens t
        WHERE t.user_id = u.id AND length(t.token) >= 80 AND position(':' in t.token) > 0) AS valid_tok
FROM app_users u
WHERE RIGHT(REGEXP_REPLACE(COALESCE(phone_number,''), '[^0-9]', '', 'g'), 10) <> '{OWNER_LAST10}'
ORDER BY updated_at DESC NULLS LAST
LIMIT 25;

-- users with valid fcm tokens (not owner)
SELECT u.id, u.display_name, u.surname, u.phone_number, u.updated_at
FROM app_users u
JOIN app_user_fcm_tokens t ON t.user_id = u.id
WHERE length(t.token) >= 80 AND position(':' in t.token) > 0
  AND RIGHT(REGEXP_REPLACE(COALESCE(u.phone_number,''), '[^0-9]', '', 'g'), 10) <> '{OWNER_LAST10}'
ORDER BY u.updated_at DESC NULLS LAST
LIMIT 20;
"""
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_recent_users.sql", "w") as f:
        f.write(sql)
    sftp.close()
    print("=== PG recent ===")
    print(
        run(
            ssh,
            'psql "$(cat /root/cab_drive_database_url.txt)" -f /tmp/_recent_users.sql',
        )
    )

    # MySQL admin users if available
    print("=== MySQL admins (best effort) ===")
    print(
        run(
            ssh,
            "mysql -N -e \"SHOW DATABASES LIKE 'cab%';\" 2>/dev/null; "
            "mysql cab -e \"SELECT id, login, phone, is_super_admin, last_login FROM user ORDER BY last_login DESC LIMIT 15;\" 2>/dev/null || "
            "mysql cab -e \"SHOW TABLES;\" 2>/dev/null | head -40",
        )
    )
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
