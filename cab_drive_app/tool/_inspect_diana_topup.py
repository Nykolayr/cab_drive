import json
import sys

sys.path.insert(0, "/root/projects/cab_drive")
import app_pg

UID = "132ipwKCpbXrRTyC2p4RNIkkf6D2"


def run(sql, args=None):
    with app_pg.connection() as conn:
        with conn.cursor() as cur:
            cur.execute(sql, args or ())
            if cur.description is None:
                return []
            cols = [d[0] for d in cur.description]
            return [dict(zip(cols, r)) for r in cur.fetchall()]


# all paid pay orders
paid = run(
    """
    SELECT id, order_id, amount_in_cop, is_paid, payment_id, payment_type,
           tinkoff_status, date_time_created, updated_at, summ_upd_balance,
           list_users_upd_balance
    FROM app_pay_orders
    WHERE user_id=%s AND (is_paid=true OR tinkoff_status IS NOT NULL OR payment_id IS NOT NULL)
    ORDER BY COALESCE(updated_at, date_time_created) DESC
    LIMIT 50
    """,
    (UID,),
)
print("PAID_LIKE", json.dumps(paid, ensure_ascii=False, default=str))

# recent any pay orders by updated
recent = run(
    """
    SELECT id, order_id, amount_in_cop, is_paid, payment_id, payment_type,
           tinkoff_status, date_time_created, updated_at
    FROM app_pay_orders
    WHERE user_id=%s
    ORDER BY COALESCE(updated_at, date_time_created) DESC
    LIMIT 20
    """,
    (UID,),
)
print("RECENT_PAY", json.dumps(recent, ensure_ascii=False, default=str))

# payout detail for 562
p = run(
    """
    SELECT id, jump_payment_id, amount_to_card, commission, balance_before,
           balance_debited, status, jump_status_id, created_at, updated_at,
           raw_json
    FROM app_payouts WHERE id='po_a464835a7bf946a2'
    """,
)
print("PAYOUT_562", json.dumps(p, ensure_ascii=False, default=str)[:4000])

# search tables with balance in name
tabs = run(
    """
    SELECT table_name FROM information_schema.tables
    WHERE table_schema='public' AND (
      table_name ILIKE '%balanc%' OR table_name ILIKE '%finance%'
      OR table_name ILIKE '%tinkoff%' OR table_name ILIKE '%pay%'
    )
    ORDER BY 1
    """
)
print("TABLES", [t["table_name"] for t in tabs])
