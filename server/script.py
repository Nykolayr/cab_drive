
from sqlalchemy import text
from db import engine

with engine.connect() as conn:
    # Удалить таблицу friend_requests
    conn.execute(text("""ALTER TABLE fb_users ADD COLUMN user_id VARCHAR(256) DEFAULT NULL;"""))
    # Подтверждение изменений
    conn.commit()