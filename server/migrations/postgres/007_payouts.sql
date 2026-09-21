-- Выводы Jump: списание balance при create, сумма «на одобрении», возврат при отмене.
ALTER TABLE app_users
    ADD COLUMN IF NOT EXISTS balance_payout_pending DOUBLE PRECISION NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS app_payouts (
    id              TEXT PRIMARY KEY,
    user_id         TEXT NOT NULL REFERENCES app_users(id),
    jump_payment_id BIGINT,
    amount_to_card  DOUBLE PRECISION NOT NULL DEFAULT 0,
    commission      DOUBLE PRECISION NOT NULL DEFAULT 0,
    balance_before  DOUBLE PRECISION NOT NULL DEFAULT 0,
    balance_debited DOUBLE PRECISION NOT NULL DEFAULT 0,
    status          TEXT NOT NULL DEFAULT 'pending',
    jump_status_id  INT,
    jump_status_title TEXT,
    pan_tail        TEXT,
    raw_json        JSONB,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_payouts_user_created
    ON app_payouts (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_app_payouts_user_status
    ON app_payouts (user_id, status);

CREATE UNIQUE INDEX IF NOT EXISTS idx_app_payouts_jump_payment_id
    ON app_payouts (jump_payment_id)
    WHERE jump_payment_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_app_payouts_pending
    ON app_payouts (status, updated_at)
    WHERE status = 'pending';
