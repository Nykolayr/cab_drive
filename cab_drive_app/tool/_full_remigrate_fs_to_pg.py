"""Full Firestore -> Postgres remigrate on production VPS."""
from __future__ import annotations

import os
import sys
import time

import paramiko

HOST = "37.252.20.248"
PASSWORD = os.environ.get("CAB_DRIVE_SSH_PASSWORD")
REMOTE = "/root/projects/cab_drive"
LOCAL_SERVER = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "server")
)
LOCAL_TOOL = os.path.dirname(__file__)
OUT = "/tmp/cab_fs_export_full"
PY = f"{REMOTE}/venv/bin/python"


def run(ssh: paramiko.SSHClient, cmd: str, timeout: int = 600) -> str:
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    data = out.read().decode("utf-8", "replace")
    ed = err.read().decode("utf-8", "replace")
    if ed.strip():
        data += "\n" + ed
    # avoid Windows console UnicodeEncodeError on ≈ and Cyrillic
    return data.strip().encode("ascii", "replace").decode("ascii")


def main() -> int:
    if not PASSWORD:
        print("CAB_DRIVE_SSH_PASSWORD missing", file=sys.stderr)
        return 1

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username="root", password=PASSWORD, timeout=60)
    sftp = ssh.open_sftp()

    uploads = [
        (
            os.path.join(LOCAL_SERVER, "scripts", "migrate_firestore_to_postgres.py"),
            f"{REMOTE}/scripts/migrate_firestore_to_postgres.py",
        ),
        (
            os.path.join(LOCAL_SERVER, "scripts", "migrate_chats_firestore_to_postgres.py"),
            f"{REMOTE}/scripts/migrate_chats_firestore_to_postgres.py",
        ),
        (
            os.path.join(LOCAL_TOOL, "_migrate_extra_fs_collections.py"),
            f"{REMOTE}/scripts/_migrate_extra_fs_collections.py",
        ),
    ]
    for local, remote in uploads:
        print("upload", remote)
        sftp.put(local, remote)
    sftp.close()

    env = (
        f"set -a; . /root/cab_drive_database_url.env; set +a; "
        f"export PYTHONPATH={REMOTE}; cd {REMOTE}"
    )

    print("=== FS counts ===")
    print(
        run(
            ssh,
            env
            + f" && {PY} -c \""
            "import firebase_admin; from firebase_admin import credentials, firestore; "
            "firebase_admin._apps or firebase_admin.initialize_app(credentials.Certificate('s.json')); "
            "db=firestore.client(); "
            "names=['users','order','pay_order','chats','messages','reviews','request_verefication']; "
            "[print(n, sum(1 for _ in db.collection(n).stream())) for n in names]"
            "\"",
            timeout=1200,
        )
    )

    print("=== EXPORT ===")
    t0 = time.time()
    print(
        run(
            ssh,
            env
            + f" && rm -rf {OUT} && mkdir -p {OUT} && "
            f"{PY} scripts/migrate_firestore_to_postgres.py "
            f"--creds {REMOTE}/s.json export --out {OUT} "
            f"--collections users order pay_order",
            timeout=2400,
        )
    )
    print(f"export_sec={time.time() - t0:.1f}")
    print(run(ssh, f"wc -l {OUT}/*.jsonl 2>/dev/null || true"))

    print("=== IMPORT --apply ===")
    t0 = time.time()
    print(
        run(
            ssh,
            env
            + f" && {PY} scripts/migrate_firestore_to_postgres.py "
            f"--creds {REMOTE}/s.json import --in {OUT} --apply",
            timeout=2400,
        )
    )
    print(f"import_sec={time.time() - t0:.1f}")

    print("=== VERIFY ===")
    print(
        run(
            ssh,
            env
            + f" && {PY} scripts/migrate_firestore_to_postgres.py verify --in {OUT}",
            timeout=300,
        )
    )

    print("=== CHATS --apply ===")
    t0 = time.time()
    print(
        run(
            ssh,
            env + f" && {PY} scripts/migrate_chats_firestore_to_postgres.py --apply",
            timeout=2400,
        )
    )
    print(f"chats_sec={time.time() - t0:.1f}")

    print("=== EXTRA reviews/verifs/cards --apply ===")
    t0 = time.time()
    print(
        run(
            ssh,
            env + f" && {PY} scripts/_migrate_extra_fs_collections.py --apply",
            timeout=3600,
        )
    )
    print(f"extra_sec={time.time() - t0:.1f}")

    print("=== HEAL login/created_time ===")
    print(
        run(
            ssh,
            env
            + f" && {PY} -c \""
            "import os,psycopg2; conn=psycopg2.connect(os.environ['DATABASE_URL']); cur=conn.cursor(); "
            "cur.execute('''UPDATE app_users SET login_complete=TRUE, updated_at=NOW() "
            "WHERE COALESCE(login_complete,FALSE)=FALSE AND ("
            "COALESCE(NULLIF(TRIM(display_name),\\'\\'),\\'\\')<>\\'\\' OR COALESCE(verif_compl,FALSE) "
            "OR COALESCE(on_verif_now,FALSE) OR (COALESCE(is_driver,FALSE) AND car_json IS NOT NULL) "
            "OR EXISTS (SELECT 1 FROM app_orders o WHERE o.user_customer_id=app_users.id OR o.selected_driver_id=app_users.id)"
            ")'''); print('healed_login', cur.rowcount); "
            "cur.execute('UPDATE app_users SET created_time=COALESCE(created_time,updated_at,NOW()) WHERE created_time IS NULL'); "
            "print('healed_created', cur.rowcount); conn.commit(); conn.close()"
            "\"",
            timeout=120,
        )
    )

    print("=== PG counts after ===")
    print(
        run(
            ssh,
            env
            + f" && {PY} -c \""
            "import os,psycopg2; conn=psycopg2.connect(os.environ['DATABASE_URL']); cur=conn.cursor(); "
            "tables=['app_users','app_orders','app_pay_orders','app_chats','app_messages',"
            "'app_reviews','app_verifications','app_saved_cards','app_user_fcm_tokens']; "
            "[(cur.execute(f'SELECT COUNT(*) FROM {t}'), print(t, cur.fetchone()[0])) for t in tables]; "
            "cur.execute('SELECT COUNT(*) FROM app_users WHERE COALESCE(login_complete,false)=true'); "
            "print('login_complete_true', cur.fetchone()[0]); conn.close()"
            "\"",
        )
    )

    print("=== health ===")
    print(run(ssh, "curl -sS https://cab.artean.ru/api/app/health"))
    ssh.close()
    print("FULL_REMIGRATE_DONE")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
