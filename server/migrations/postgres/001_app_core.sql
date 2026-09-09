-- Cab Drive app core (Firestore → Postgres), P0
-- Auth остаётся в Firebase; PK users.id = Firebase UID.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------- users ----------
CREATE TABLE IF NOT EXISTS app_users (
    id                  TEXT PRIMARY KEY,              -- Firebase UID
    email               TEXT,
    fb_id               TEXT,
    display_name        TEXT,
    photo_url           TEXT,
    uid                 TEXT,
    created_time        TIMESTAMPTZ,
    phone_number        TEXT,
    login_complete      BOOLEAN NOT NULL DEFAULT FALSE,
    is_driver           BOOLEAN NOT NULL DEFAULT FALSE,
    admin               BOOLEAN NOT NULL DEFAULT FALSE,
    surname             TEXT,
    dfb                 TIMESTAMPTZ,
    city                TEXT,
    region              TEXT,
    city_lat            DOUBLE PRECISION,
    city_lng            DOUBLE PRECISION,
    verif_compl         BOOLEAN NOT NULL DEFAULT FALSE,
    is_blocked          BOOLEAN NOT NULL DEFAULT FALSE,
    block_comment       TEXT,
    verif_ne_proidena   BOOLEAN,
    verif_id            INTEGER,
    on_verif_now        BOOLEAN NOT NULL DEFAULT FALSE,
    email_user          TEXT,
    additional_phone_number TEXT,
    chat_with_support_id TEXT,
    balance             NUMERIC(14, 2) NOT NULL DEFAULT 0,
    bonus_balance       NUMERIC(14, 2) NOT NULL DEFAULT 0,
    average_rating      NUMERIC(6, 3) NOT NULL DEFAULT 0,
    number_of_reviews   INTEGER NOT NULL DEFAULT 0,
    commission_percent  NUMERIC(8, 3),
    current_commision   NUMERIC(14, 2),
    on_shift            BOOLEAN NOT NULL DEFAULT FALSE,
    fine                BOOLEAN NOT NULL DEFAULT FALSE,
    contractor_id       INTEGER,
    last_online         TIMESTAMPTZ,
    shift_start_date_time TIMESTAMPTZ,
    shift_completion_date_time TIMESTAMPTZ,
    driver_lat          DOUBLE PRECISION,
    driver_lng          DOUBLE PRECISION,
    car_json            JSONB,
    addresses_json      JSONB,
    current_order_json  JSONB,
    active_orders_queue TEXT[] DEFAULT '{}',
    raw_json            JSONB,                         -- полный документ на переходный период
    migrated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_users_phone ON app_users (phone_number);
CREATE INDEX IF NOT EXISTS idx_app_users_is_driver_on_shift
    ON app_users (is_driver, on_shift) WHERE is_driver AND on_shift;

CREATE TABLE IF NOT EXISTS app_user_fcm_tokens (
    id          BIGSERIAL PRIMARY KEY,
    user_id     TEXT NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    token       TEXT NOT NULL,
    raw_json    JSONB,
    UNIQUE (user_id, token)
);

-- ---------- orders ----------
CREATE TABLE IF NOT EXISTS app_orders (
    id                          TEXT PRIMARY KEY,
    selected_driver_id          TEXT,
    user_customer_id            TEXT,
    supply                      INTEGER,
    date_time                   TIMESTAMPTZ,
    date_time_created           TIMESTAMPTZ,
    date_upd                    TIMESTAMPTZ,
    point_a_json                JSONB,
    point_b_json                JSONB,
    point_c_json                JSONB,
    images                      TEXT[],
    image_compl                 TEXT[],
    description                 TEXT,
    budget                      INTEGER,
    status                      TEXT,
    status_do_hidden            TEXT,
    driver_reviewed             BOOLEAN NOT NULL DEFAULT FALSE,
    customer_reviewed           BOOLEAN NOT NULL DEFAULT FALSE,
    count_resp                  INTEGER NOT NULL DEFAULT 0,
    user_who_responced          TEXT[] DEFAULT '{}',
    distance                    INTEGER,
    time_text                   TEXT,
    time_left                   TEXT,
    km_left                     TEXT,
    driver_lat                  DOUBLE PRECISION,
    driver_lng                  DOUBLE PRECISION,
    car                         TEXT,
    movers                      INTEGER,
    current_price               INTEGER,
    payment_id                  TEXT,
    pay_method                  TEXT,
    commission_percent          INTEGER,
    is_paid                     BOOLEAN NOT NULL DEFAULT FALSE,
    completion_date_by_the_driver TIMESTAMPTZ,
    raw_json                    JSONB,
    migrated_at                 TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_orders_status ON app_orders (status);
CREATE INDEX IF NOT EXISTS idx_app_orders_driver ON app_orders (selected_driver_id);
CREATE INDEX IF NOT EXISTS idx_app_orders_customer ON app_orders (user_customer_id);
CREATE INDEX IF NOT EXISTS idx_app_orders_created ON app_orders (date_time_created DESC);

CREATE TABLE IF NOT EXISTS app_order_responses (
    id              BIGSERIAL PRIMARY KEY,
    order_id        TEXT NOT NULL REFERENCES app_orders(id) ON DELETE CASCADE,
    firestore_id    TEXT,
    raw_json        JSONB,
    UNIQUE (order_id, firestore_id)
);

-- ---------- pay_orders ----------
CREATE TABLE IF NOT EXISTS app_pay_orders (
    id                      TEXT PRIMARY KEY,
    order_id                TEXT,
    amount_in_cop           INTEGER,
    user_id                 TEXT,
    driver_id               TEXT,
    is_paid                 BOOLEAN NOT NULL DEFAULT FALSE,
    payment_id              TEXT,
    current_order_id        TEXT,
    payment_type            TEXT,
    list_users_upd_balance  TEXT[] DEFAULT '{}',
    summ_upd_balance        NUMERIC(14, 2),
    tinkoff_status          TEXT,
    tinkoff_error_code      TEXT,
    tinkoff_message         TEXT,
    date_time_created       TIMESTAMPTZ,
    raw_json                JSONB,
    migrated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_app_pay_orders_payment_id ON app_pay_orders (payment_id);
CREATE INDEX IF NOT EXISTS idx_app_pay_orders_user ON app_pay_orders (user_id);

-- ---------- migration audit ----------
CREATE TABLE IF NOT EXISTS app_migration_runs (
    id              BIGSERIAL PRIMARY KEY,
    started_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    finished_at     TIMESTAMPTZ,
    mode            TEXT NOT NULL,          -- export | import | verify
    collection      TEXT,
    docs_read       INTEGER DEFAULT 0,
    docs_written    INTEGER DEFAULT 0,
    notes           TEXT
);
