-- Клиентские ошибки МП (шаблон digitalsquare / ClientErrorReporter).
-- Retention ~14 дней — purge по крону/руками при необходимости.
CREATE TABLE IF NOT EXISTS app_client_errors (
    id            BIGSERIAL PRIMARY KEY,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_id       TEXT NULL,
    login         TEXT NULL,
    role          TEXT NULL,
    platform      TEXT NULL,
    app_version   TEXT NULL,
    build_number  TEXT NULL,
    tag           TEXT NULL,
    message       TEXT NOT NULL,
    stack_text    TEXT NULL,
    fatal         BOOLEAN NOT NULL DEFAULT FALSE,
    device_info   TEXT NULL,
    fingerprint   CHAR(40) NULL
);

CREATE INDEX IF NOT EXISTS idx_app_client_errors_created
    ON app_client_errors (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_app_client_errors_fp_created
    ON app_client_errors (fingerprint, created_at DESC);
