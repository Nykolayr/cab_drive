-- Reviews (Firestore reviews → Postgres)
CREATE TABLE IF NOT EXISTS app_reviews (
    id                  TEXT PRIMARY KEY,
    reviewed_user_id    TEXT NOT NULL,
    author_user_id      TEXT NOT NULL,
    text                TEXT NOT NULL DEFAULT '',
    rating              INTEGER NOT NULL DEFAULT 0,
    name_author         TEXT,
    order_id            TEXT,
    date_created        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    raw_json            JSONB,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_reviews_reviewed
    ON app_reviews (reviewed_user_id, date_created DESC);

CREATE INDEX IF NOT EXISTS idx_app_reviews_author
    ON app_reviews (author_user_id, date_created DESC);
