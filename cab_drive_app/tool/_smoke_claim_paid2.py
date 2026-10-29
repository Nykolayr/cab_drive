import app_pg

print("has_claim", hasattr(app_pg, "claim_pay_order_paid"))
# already paid → False
print(
    "claim_already",
    app_pg.claim_pay_order_paid(
        "56da23bfdb834567b3ae000c6b2a2e32",
        tinkoff_status="CONFIRMED",
    ),
)
with open("/root/projects/cab_drive/tinkoff/webhook.py", encoding="utf-8") as f:
    src = f.read()
print("webhook_has_claim", "claim_pay_order_paid" in src)
