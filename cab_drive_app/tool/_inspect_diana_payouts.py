import json
import sys

sys.path.insert(0, "/root/projects/cab_drive")
import app_pg

phone_last10 = "9667499985"


def run(sql, args=None):
    with app_pg.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, args or ())
            if cur.description is None:
                return []
            cols = [d[0] for d in cur.description]
            return [dict(zip(cols, r)) for r in cur.fetchall()]


user_cols = [
    c["column_name"]
    for c in run(
        """
        SELECT column_name FROM information_schema.columns
        WHERE table_schema='public' AND table_name='app_users'
        ORDER BY ordinal_position
        """
    )
]
print("USER_COLS", user_cols)

users = run(
    """
    SELECT id, phone_number, balance, balance_payout_pending
    FROM app_users
    WHERE RIGHT(
        REGEXP_REPLACE(COALESCE(phone_number, ''), '[^0-9]', '', 'g'),
        10
    ) = %s
    LIMIT 5
    """,
    (phone_last10,),
)
print("USERS", json.dumps(users, ensure_ascii=False, default=str))

payout_cols = [
    c["column_name"]
    for c in run(
        """
        SELECT column_name FROM information_schema.columns
        WHERE table_schema='public' AND table_name='app_payouts'
        ORDER BY ordinal_position
        """
    )
]
print("PAYOUT_COLS", payout_cols)

for u in users:
    uid = u["id"]
    me = app_pg.get_me(uid) or {}
    print(
        "ME",
        json.dumps(
            {
                "id": uid,
                "balance": me.get("balance"),
                "balance_payout_pending": me.get("balance_payout_pending"),
                "contractor_id": me.get("contractor_id"),
                "phone": me.get("phone_number") or me.get("phone"),
            },
            ensure_ascii=False,
            default=str,
        ),
    )
    order = "created_at DESC" if "created_at" in payout_cols else "id DESC"
    pays = run(
        f"""
        SELECT * FROM app_payouts
        WHERE user_id=%s
        ORDER BY {order}
        LIMIT 20
        """,
        (uid,),
    )
    print("PAYOUTS", json.dumps(pays, ensure_ascii=False, default=str))

# finance log if exists
try:
    fl = run(
        """
        SELECT * FROM app_finance_log
        WHERE user_id IN (
          SELECT id FROM app_users
          WHERE RIGHT(REGEXP_REPLACE(COALESCE(phone_number,''),'[^0-9]','','g'),10)=%s
        )
        ORDER BY 1 DESC LIMIT 30
        """,
        (phone_last10,),
    )
    print("FINANCE", json.dumps(fl, ensure_ascii=False, default=str))
except Exception as e:
    print("FINANCE_ERR", e)
