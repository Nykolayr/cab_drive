# Cab Drive — деплой сервера

## Инфраструктура

| Компонент | Адрес / процесс |
|-----------|-----------------|
| VPS | `37.252.20.248` |
| Flask app | gunicorn `:5000`, systemd `cab.service` |
| WSS hub | `:5001`, systemd `cab-wss.service` |
| nginx | `https://cab.artean.ru`, `/ws/` → WSS |
| Postgres app DB | `cab_drive_app` (`DATABASE_URL` в `/root/cab_drive_database_url.txt`) |
| MySQL admin | `cab` — только админка / bridge phone |
| Redis | `127.0.0.1:6379` |

## Расположение кода

```
/root/projects/cab_drive
```

## Systemd

### `cab.service`

```ini
[Unit]
Description=Cab Drive Flask
After=network.target

[Service]
User=root
WorkingDirectory=/root/projects/cab_drive
Environment=APP_FS_MIRROR=0
Environment=DATABASE_URL=postgresql://...
ExecStart=/root/projects/cab_drive/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

### `cab-wss.service`

Аналогично, запускает `wss_server.py` на `:5001`.

## nginx

```nginx
server {
    listen 443 ssl;
    server_name cab.artean.ru;

    client_max_body_size 20m; # /kek/files/upload — фото документов >1МБ

    location / {
        proxy_pass http://127.0.0.1:5000;
        include proxy_params;
    }

    location /ws/ {
        proxy_pass http://127.0.0.1:5001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

## Порядок деплоя

1. Подключиться к VPS (`ssh root@37.252.20.248`).
2. `cd /root/projects/cab_drive`
3. `git pull` (или скопировать изменения).
4. Применить миграции:
   ```bash
   psql "$DATABASE_URL" -f migrations/00X_....sql
   ```
5. Проверить `config.py` и env (не коммитится).
6. `systemctl restart cab.service` (и `cab-wss.service` при изменениях WSS).
7. Проверить логи:
   ```bash
   journalctl -u cab.service -f
   journalctl -u cab-wss.service -f
   ```

## Проверки после деплоя

- [ ] `GET /api/app/health` → `sot=postgres`, `fs_mirror=false`
- [ ] `curl /d/auth` → 200 быстро
- [ ] POST логин админки → ok
- [ ] GET целевой страницы после логина → не 504 (< 10с)
- [ ] journalctl: нет каскада worker SIGKILL на админ-роутах
- [ ] WSS: `wss://cab.artean.ru/ws/` отвечает на auth

## Когда деплой обязателен

После изменений в:
- `server/api.py`, `entities.py`
- `server/dashboard/`
- фоновые циклы (`app.py`)
- миграции
- WSS (`wss_server.py`)

## Важно

- `APP_FS_MIRROR=0` на проде. Переключение в `1` — только откат.
- Не путать Postgres `app_*` и MySQL `cab`.
- Секреты (`config.py`) не в git; на сервере отдельно.
