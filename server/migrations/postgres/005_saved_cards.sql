-- Driver/customer saved cards (Firestore users/*/saved_cards → Postgres)
CREATE TABLE IF NOT EXISTS app_saved_cards (
    id          TEXT PRIMARY KEY,
    user_id     TEXT NOT NULL,
    pan         TEXT NOT NULL DEFAULT '',
    rebill_id   TEXT,
    card_id     TEXT,
    kind        TEXT NOT NULL DEFAULT 'payout',
    raw_json    JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_saved_cards_user
    ON app_saved_cards (user_id, created_at DESC);
