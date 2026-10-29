import json
import sys

sys.path.insert(0, "/root/projects/cab_drive")
import app_pg

PHONE = "9667499985"
UID = "132ipwKCpbXrRTyC2p4RNIkkf6D2"


def run(sql, args=None):
    with app_pg.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, args or ())
            if cur.description is None:
                return []
            cols = [d[0] for d in cur.description]
            return [dict(zip(cols, r)) for r in cur.fetchall()]


me = app_pg.get_me(UID) or {}
print(
    "ME",
    json.dumps(
        {
            "balance": me.get("balance"),
            "bonus_balance": me.get("bonus_balance"),
            "balance_payout_pending": me.get("balance_payout_pending"),
            "phone": me.get("phone_number"),
        },
        ensure_ascii=False,
        default=str,
    ),
)

# pay orders / topups
for table in (
    "app_pay_orders",
    "app_payments",
    "app_balance_log",
    "app_finance_events",
    "app_user_balance_log",
):
    try:
        cols = run(
            """
            SELECT column_name FROM information_schema.columns
            WHERE table_schema='public' AND table_name=%s
            ORDER BY ordinal_position
            """,
            (table,),
        )
        if not cols:
            print("NO_TABLE", table)
            continue
        print("TABLE", table, [c["column_name"] for c in cols])
        rows = run(f"SELECT * FROM {table} WHERE user_id=%s ORDER BY 1 DESC LIMIT 30", (UID,))
        if not rows:
            # try other user id columns
            for col in ("uid", "fb_id", "customer_id", "driver_id"):
                try:
                    rows = run(
                        f"SELECT * FROM {table} WHERE {col}=%s ORDER BY 1 DESC LIMIT 30",
                        (UID,),
                    )
                    if rows:
                        print("ROWS_BY", col)
                        break
                except Exception:
                    pass
        print("ROWS", table, json.dumps(rows, ensure_ascii=False, default=str)[:8000])
    except Exception as e:
        print("ERR", table, e)

# payouts
pays = run(
    """
    SELECT id, jump_payment_id, amount_to_card, commission, balance_before,
           balance_debited, status, jump_status_id, jump_status_title,
           created_at, updated_at
    FROM app_payouts WHERE user_id=%s
    ORDER BY created_at DESC NULLS LAST LIMIT 20
    """,
    (UID,),
)
print("PAYOUTS", json.dumps(pays, ensure_ascii=False, default=str))

# raw_json balance fields on user
u = run(
    """
    SELECT balance, bonus_balance, balance_payout_pending, updated_at,
           raw_json->'balance' as raw_balance,
           left(raw_json::text, 500) as raw_head
    FROM app_users WHERE id=%s
    """,
    (UID,),
)
print("USER_ROW", json.dumps(u, ensure_ascii=False, default=str))
