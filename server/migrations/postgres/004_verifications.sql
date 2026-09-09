-- Driver verification requests (Firestore request_verefication → Postgres)
CREATE TABLE IF NOT EXISTS app_verifications (
    id                  TEXT PRIMARY KEY,
    user_id             TEXT NOT NULL,
    number_id           INTEGER,
    status              TEXT NOT NULL DEFAULT 'onVerif',
    email               TEXT,
    phone_number        TEXT,
    city                TEXT,
    name                TEXT,
    surname             TEXT,
    dfb                 TIMESTAMPTZ,
    date_created        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    number_avto         TEXT,
    marka               TEXT,
    marka_avto          TEXT,
    avatar              TEXT,
    photo_doc           TEXT[] NOT NULL DEFAULT '{}',
    photo_avto          TEXT[] NOT NULL DEFAULT '{}',
    commission_percent  NUMERIC(8,3),
    raw_json            JSONB,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_verifications_user
    ON app_verifications (user_id, date_created DESC);

CREATE INDEX IF NOT EXISTS idx_app_verifications_status
    ON app_verifications (status, date_created DESC);

CREATE UNIQUE INDEX IF NOT EXISTS uq_app_verifications_number_id
    ON app_verifications (number_id) WHERE number_id IS NOT NULL;

CREATE SEQUENCE IF NOT EXISTS app_verifications_number_id_seq;
