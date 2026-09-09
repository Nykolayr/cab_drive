-- Chats / messages (Firestore → Postgres + WSS)
CREATE TABLE IF NOT EXISTS app_chats (
    id              TEXT PRIMARY KEY,
    support         BOOLEAN NOT NULL DEFAULT FALSE,
    last_message    TEXT,
    date_created    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    raw_json        JSONB
);

CREATE TABLE IF NOT EXISTS app_chat_members (
    chat_id         TEXT NOT NULL REFERENCES app_chats(id) ON DELETE CASCADE,
    user_id         TEXT NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    PRIMARY KEY (chat_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_app_chat_members_user ON app_chat_members (user_id);

CREATE TABLE IF NOT EXISTS app_messages (
    id              TEXT PRIMARY KEY,
    chat_id         TEXT NOT NULL REFERENCES app_chats(id) ON DELETE CASCADE,
    sender_id       TEXT NOT NULL,
    text            TEXT NOT NULL DEFAULT '',
    list_images     JSONB NOT NULL DEFAULT '[]'::jsonb,
    read            BOOLEAN NOT NULL DEFAULT FALSE,
    date_created    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    date_read       TIMESTAMPTZ,
    raw_json        JSONB
);

CREATE INDEX IF NOT EXISTS idx_app_messages_chat_created
    ON app_messages (chat_id, date_created DESC);
