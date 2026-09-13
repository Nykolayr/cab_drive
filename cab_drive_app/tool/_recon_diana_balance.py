"""Reconcile Diana balance: PG + Firestore + Jump payments."""
from __future__ import annotations

import json
import os
import sys

import paramiko

HOST = "37.252.20.248"
USER = "root"
PASSWORD = (
    os.environ.get("CAB_DRIVE_SSH_PASSWORD")
    or os.environ.get("CAB_SSH_PASSWORD")
    or "wZX++X-+TJ7kqn"
)
PHONE = "%9667499985%"
JUMP_KEY = "12b46b45-f258-4e3c-9509-9dc7280cdeed"

REMOTE = r'''
import json
import urllib.request
import urllib.error

import app as _a
import app_pg

PHONE_LIKE = "%9667499985%"
JUMP_KEY = "12b46b45-f258-4e3c-9509-9dc7280cdeed"

def jget(url):
    req = urllib.request.Request(
        url,
        headers={"Accept": "application/json", "Client-Key": JUMP_KEY},
        method="GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode("utf-8", "replace")
            return resp.status, json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", "replace")
        try:
            payload = json.loads(body) if body else {}
        except Exception:
            payload = {"raw": body[:800]}
        return e.code, payload
    except Exception as e:
        return 0, {"error": str(e)}

# --- PG ---
with app_pg.connection() as conn:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT id, phone_number, display_name, surname, balance, bonus_balance,
                   contractor_id, updated_at
            FROM app_users
            WHERE phone_number LIKE %s
            LIMIT 3
            """,
            (PHONE_LIKE,),
        )
        cols = [d[0] for d in cur.description]
        rows = [dict(zip(cols, r)) for r in cur.fetchall()]
for r in rows:
    for k, v in list(r.items()):
        if hasattr(v, "isoformat"):
            r[k] = v.isoformat()
        elif v is not None and not isinstance(v, (str, int, float, bool)):
            r[k] = str(v)
print("PG", json.dumps(rows, ensure_ascii=False))

uid = rows[0]["id"] if rows else None
contractor_id = rows[0].get("contractor_id") if rows else None

# --- Firestore ---
fs = {"ok": False}
if uid:
    try:
        from firebase_admin import firestore
        db = firestore.client()
        snap = db.collection("users").document(uid).get()
        if snap.exists:
            d = snap.to_dict() or {}
            fs = {
                "ok": True,
                "exists": True,
                "balance": d.get("balance"),
                "bonus_balance": d.get("bonus_balance") or d.get("bonusBalance"),
                "ContractorID": d.get("ContractorID") or d.get("contractor_id"),
                "display_name": d.get("display_name") or d.get("displayName"),
                "phone_number": d.get("phone_number") or d.get("phoneNumber"),
            }
        else:
            fs = {"ok": True, "exists": False}
    except Exception as e:
        fs = {"ok": False, "error": str(e)[:300]}
print("FS", json.dumps(fs, ensure_ascii=False))

# --- Jump: try list endpoints ---
urls = [
    "https://api.jump.finance/services/openapi/payments?limit=20&search=79667499985",
    "https://api.jump.finance/services/openapi/payments?limit=20&search=%2B79667499985",
    "https://api.jump.finance/services/openapi/contractors?limit=20&search=79667499985",
]
if contractor_id:
    cid = int(contractor_id)
    urls.extend([
        f"https://api.jump.finance/services/openapi/contractors/{cid}",
        f"https://api.jump.finance/services/openapi/payments?contractor_id={cid}&limit=20",
    ])
# recent payments (any) — last resort sample
urls.append("https://api.jump.finance/services/openapi/payments?limit=5")

jump_out = []
for u in urls:
    status, payload = jget(u)
    # keep compact
    keys = list(payload.keys()) if isinstance(payload, dict) else type(payload).__name__
    items = None
    if isinstance(payload, dict):
        for k in ("items", "data", "payments", "item"):
            if k in payload:
                items = payload[k]
                break
    jump_out.append({
        "url": u,
        "status": status,
        "keys": keys,
        "items_type": type(items).__name__ if items is not None else None,
        "items_len": len(items) if isinstance(items, list) else None,
        "sample": (items[:3] if isinstance(items, list) else items) if items is not None else (
            {k: payload.get(k) for k in list(payload)[:8]} if isinstance(payload, dict) else str(payload)[:400]
        ),
    })
print("JUMP", json.dumps(jump_out, ensure_ascii=False, default=str)[:8000])
print("OK")
'''


def safe_print(s: str) -> None:
    try:
        print(s)
    except UnicodeEncodeError:
        sys.stdout.buffer.write((s + "\n").encode("utf-8", "replace"))


def main() -> int:
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASSWORD, timeout=45)
    sftp = ssh.open_sftp()
    with sftp.file("/tmp/_recon_diana_balance.py", "w") as f:
        f.write(REMOTE)
    sftp.close()
    _, out, err = ssh.exec_command(
        "cd /root/projects/cab_drive && PYTHONPATH=/root/projects/cab_drive "
        "./venv/bin/python /tmp/_recon_diana_balance.py",
        timeout=90,
    )
    safe_print(out.read().decode("utf-8", "replace"))
    e = err.read().decode("utf-8", "replace").strip()
    if e:
        safe_print("STDERR: " + e)
    ssh.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
