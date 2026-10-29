"""Deploy payout pending note + Jump sync polling + heal Diana."""
from __future__ import annotations

import os
import time
from pathlib import Path

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
   
)
ROOT = Path(r"D:\Projects\cab_drive")
FILES = [
    ("server/app_payout_ops.py", "/root/projects/cab_drive/app_payout_ops.py"),
    ("server/app_pg.py", "/root/projects/cab_drive/app_pg.py"),
    ("server/app_finance_log.py", "/root/projects/cab_drive/app_finance_log.py"),
    ("server/app_data/__init__.py", "/root/projects/cab_drive/app_data/__init__.py"),
    ("server/orders/api.py", "/root/projects/cab_drive/orders/api.py"),
    (
        "server/migrations/postgres/007_payouts.sql",
        "/root/projects/cab_drive/migrations/postgres/007_payouts.sql",
    ),
]

DIANA_UID = "132ipwKCpbXrRTyC2p4RNIkkf6D2"
DIANA_JUMP_IDS = [182142163, 182142160, 182024002]

REMOTE_SMOKE = f'''
import json, sys
sys.path.insert(0, "/root/projects/cab_drive")
import app as _a
import app_pg
import app_payout_ops

print("commission200", app_payout_ops.payout_commission(200))
print("amount200", app_payout_ops.amount_to_card(200))

me = app_pg.get_me("{DIANA_UID}") or {{}}
print("diana_before", json.dumps({{
  "balance": me.get("balance"),
  "balance_payout_pending": me.get("balance_payout_pending"),
  "contractor_id": me.get("contractor_id"),
}}, default=str, ensure_ascii=False))

heal = app_payout_ops.heal_legacy_pending_for_user(
    "{DIANA_UID}",
    {DIANA_JUMP_IDS!r},
    debit_current_balance=True,
)
print("heal", json.dumps(heal, default=str, ensure_ascii=False))

sync = app_payout_ops.sync_user_payouts("{DIANA_UID}")
print("sync", json.dumps(sync, default=str, ensure_ascii=False))

me2 = app_pg.get_me("{DIANA_UID}") or {{}}
print("diana_after", json.dumps({{
  "balance": me2.get("balance"),
  "balance_payout_pending": me2.get("balance_payout_pending"),
  "open_payout": app_pg.get_open_payout("{DIANA_UID}"),
  "payouts": app_pg.list_payouts(user_id="{DIANA_UID}", limit=10),
}}, default=str, ensure_ascii=False))
'''


def main() -> int:
    last_err: Exception | None = None
    for attempt in range(6):
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(
                HOST,
                username=USER,
                password=PASSWORD,
                timeout=90,
                banner_timeout=90,
                auth_timeout=90,
            )
            print("connected", attempt + 1)
            sftp = ssh.open_sftp()
            try:
                sftp.stat("/root/projects/cab_drive/migrations/postgres")
            except OSError:
                _, o, e = ssh.exec_command(
                    "mkdir -p /root/projects/cab_drive/migrations/postgres",
                    timeout=30,
                )
                o.read()
                e.read()
            for local, remote in FILES:
                data = (ROOT / local).read_bytes()
                with sftp.file(remote, "wb") as f:
                    f.write(data)
                print("uploaded", remote, len(data))
            with sftp.file("/tmp/_payout_smoke.py", "w") as f:
                f.write(REMOTE_SMOKE)
            sftp.close()

            _, out, err = ssh.exec_command(
                'psql "$(cat /root/cab_drive_database_url.txt)" '
                "-f /root/projects/cab_drive/migrations/postgres/007_payouts.sql",
                timeout=60,
            )
            print("MIGRATE", out.read().decode("utf-8", "replace"))
            e = err.read().decode("utf-8", "replace")
            if e.strip():
                print("MIGRATE_ERR", e[:800])

            _, out, err = ssh.exec_command(
                "systemctl restart cab.service; sleep 4; "
                "systemctl is-active cab.service; "
                "curl -sS https://cab.artean.ru/api/app/health",
                timeout=90,
            )
            print("RESTART", out.read().decode("utf-8", "replace"))
            e = err.read().decode("utf-8", "replace")
            if e.strip():
                print("RESTART_ERR", e[:500])

            _, out, err = ssh.exec_command(
                "cd /root/projects/cab_drive && ./venv/bin/python /tmp/_payout_smoke.py",
                timeout=180,
            )
            print("SMOKE", out.read().decode("utf-8", "replace"))
            e = err.read().decode("utf-8", "replace")
            if e.strip():
                print("SMOKE_ERR", e[:2000])

            _, out, err = ssh.exec_command(
                "journalctl -u cab.service --since '3 min ago' --no-pager "
                "| grep -iE '\\[finance\\]|heal_registered|pending_debited|payout sync' "
                "| tail -40",
                timeout=60,
            )
            print("LOGS", out.read().decode("utf-8", "replace")[:4000])
            ssh.close()
            return 0
        except Exception as ex:
            last_err = ex
            print("fail", attempt + 1, ex)
            time.sleep(10)
    raise SystemExit(f"ssh failed: {last_err}")


if __name__ == "__main__":
    raise SystemExit(main())
