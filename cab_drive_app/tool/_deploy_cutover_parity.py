"""Deploy cutover session/order parity fixes + heal login_complete on PG."""
from __future__ import annotations

import os
import sys

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD")
REMOTE_ROOT = "/root/projects/cab_drive"
LOCAL_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "server"))

FILES = [
    "app_pg.py",
    "app_data/__init__.py",
    "app_me_ops.py",
    "app_order_ops.py",
    "users/api.py",
]

HEAL_SQL = r"""
UPDATE app_users u
SET login_complete = TRUE, updated_at = NOW()
WHERE COALESCE(login_complete, FALSE) = FALSE
  AND (
    COALESCE(NULLIF(TRIM(display_name), ''), '') <> ''
    OR COALESCE(verif_compl, FALSE)
    OR COALESCE(on_verif_now, FALSE)
    OR (COALESCE(is_driver, FALSE) AND car_json IS NOT NULL)
    OR COALESCE(number_of_reviews, 0) > 0
    OR COALESCE(balance, 0) <> 0
    OR cardinality(COALESCE(active_orders_queue, '{}'::text[])) > 0
    OR EXISTS (
      SELECT 1 FROM app_orders o
      WHERE o.user_customer_id = u.id OR o.selected_driver_id = u.id
    )
  );

UPDATE app_users
SET phone_number = RIGHT(REGEXP_REPLACE(split_part(email, '@', 1), '[^0-9]', '', 'g'), 10),
    updated_at = NOW()
WHERE (phone_number IS NULL OR TRIM(phone_number) = '')
  AND email ~ '^[0-9]{10,}@';

UPDATE app_orders
SET raw_json = COALESCE(raw_json, '{}'::jsonb)
      || jsonb_build_object(
           'currentPrice', current_price,
           'budget', COALESCE((raw_json->>'budget')::numeric, budget, current_price)
         ),
    updated_at = NOW()
WHERE current_price IS NOT NULL
  AND (
    raw_json IS NULL
    OR raw_json->>'currentPrice' IS NULL
    OR (raw_json->>'currentPrice')::numeric IS DISTINCT FROM current_price
  );
"""


def run(ssh: paramiko.SSHClient, cmd: str) -> str:
    _, out, err = ssh.exec_command(cmd)
    data = out.read().decode("utf-8", "replace")
    err_data = err.read().decode("utf-8", "replace")
    if err_data.strip():
        data += "\n" + err_data
    return data.strip()


def main() -> int:
    if not PASSWORD:
        print("CAB_DRIVE_SSH_PASSWORD not set", file=sys.stderr)
        return 1

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    try:
        for rel in FILES:
            local = os.path.join(LOCAL_ROOT, rel.replace("/", os.sep))
            remote = f"{REMOTE_ROOT}/{rel}"
            print(f"upload {rel} -> {remote}")
            sftp.put(local, remote)

        # heal SQL via python in remote project (psycopg from PYTHONPATH/deps)
        heal_py = r'''
import os
url = ""
envp = "/root/cab_drive_database_url.env"
if os.path.isfile(envp):
    for line in open(envp):
        line=line.strip()
        if line.startswith("DATABASE_URL="):
            url=line.split("=",1)[1].strip().strip('"').strip("'")
if not url and os.path.isfile("/root/cab_drive_database_url.txt"):
    url=open("/root/cab_drive_database_url.txt").read().strip()
import psycopg2
conn=psycopg2.connect(url)
cur=conn.cursor()
cur.execute("""
UPDATE app_users u
SET login_complete = TRUE, updated_at = NOW()
WHERE COALESCE(login_complete, FALSE) = FALSE
  AND (
    COALESCE(NULLIF(TRIM(display_name), ''), '') <> ''
    OR COALESCE(verif_compl, FALSE)
    OR COALESCE(on_verif_now, FALSE)
    OR (COALESCE(is_driver, FALSE) AND car_json IS NOT NULL)
    OR COALESCE(number_of_reviews, 0) > 0
    OR COALESCE(balance, 0) <> 0
    OR cardinality(COALESCE(active_orders_queue, '{}'::text[])) > 0
    OR EXISTS (
      SELECT 1 FROM app_orders o
      WHERE o.user_customer_id = u.id OR o.selected_driver_id = u.id
    )
  )
""")
print("healed_login", cur.rowcount)
cur.execute("""
UPDATE app_users
SET phone_number = RIGHT(REGEXP_REPLACE(split_part(email, '@', 1), '[^0-9]', '', 'g'), 10),
    updated_at = NOW()
WHERE (phone_number IS NULL OR TRIM(phone_number) = '')
  AND email ~ '^[0-9]{10,}@'
""")
print("healed_phone", cur.rowcount)
cur.execute("""
UPDATE app_orders
SET raw_json = COALESCE(raw_json, '{}'::jsonb)
      || jsonb_build_object('currentPrice', current_price),
    updated_at = NOW()
WHERE current_price IS NOT NULL
  AND (
    raw_json IS NULL
    OR raw_json->>'currentPrice' IS NULL
    OR (raw_json->>'currentPrice')::numeric IS DISTINCT FROM current_price
  )
""")
print("healed_prices", cur.rowcount)
cur.execute("""
UPDATE app_users
SET created_time = COALESCE(created_time, updated_at, NOW()),
    updated_at = NOW()
WHERE created_time IS NULL
""")
print("healed_created_time", cur.rowcount)
cur.execute("SELECT COUNT(*) FROM app_users WHERE COALESCE(login_complete,false)=false")
print("login_false_left", cur.fetchone()[0])
cur.execute("SELECT COUNT(*) FROM app_users")
print("users_total", cur.fetchone()[0])
for p in ["9667499985"]:
    cur.execute("""
      SELECT id, display_name, phone_number, login_complete, is_driver
      FROM app_users
      WHERE phone_number ILIKE %s OR email ILIKE %s
      LIMIT 5
    """, ("%"+p+"%", "%"+p+"%"))
    print("phone", p, cur.fetchall())
conn.commit(); conn.close(); print("HEAL_OK")
'''
        with sftp.file("/tmp/_heal_cutover_run.py", "w") as f:
            f.write(heal_py)

        print("--- restart ---")
        print(run(ssh, "systemctl restart cab.service && sleep 2 && systemctl is-active cab.service"))
        print("--- import ---")
        print(
            run(
                ssh,
                "cd /root/projects/cab_drive && "
                "PYTHONPATH=/root/projects/cab_drive "
                "/root/projects/cab_drive/venv/bin/python -c "
                "'import app_pg, app_me_ops, app_order_ops; "
                "print(\"import_ok\", app_pg.enabled(), hasattr(app_pg,\"heal_session_user\"))'",
            )
        )
        print("--- heal ---")
        heal_out = run(
            ssh,
            "/root/projects/cab_drive/venv/bin/python /tmp/_heal_cutover_run.py",
        )
        print(heal_out)
        print("--- health ---")
        print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
    finally:
        sftp.close()
        ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
