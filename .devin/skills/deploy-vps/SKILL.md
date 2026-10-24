---
name: deploy-vps
description: >-
  Деплой и диагностика сервера cab_drive на VPS по SSH (paramiko), включая
  запросы к MySQL локально на VPS. Использовать когда нужно задеплоить
  server/*.py, дернуть БД, проверить health или перезапустить сервис.
---

# VPS cab_drive — SSH, деплой, MySQL

## Доступ

- Хост: `37.252.20.248`, user `root`
- Пароль: **только из env** `CAB_DRIVE_SSH_PASSWORD` (или `CAB_SSH_PASSWORD`).
  Хардкода в коде быть не должно — исторический пароль из tool/_*.py вычищен.
- Паттерн — как в `cab_drive_app/tool/_deploy_*.py` (paramiko):

```python
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect("37.252.20.248", username="root",
            password=os.environ["CAB_DRIVE_SSH_PASSWORD"], timeout=45)
```

## Деплой

- Код на сервере: `/root/projects/cab_drive` (sftp-upload нужных файлов).
- Health: `curl -sS http://127.0.0.1:5000/api/app/health`.
- Сервис — systemd `troika.service` (см. server/troika.service);
  перезапуск через `systemctl restart troika` по SSH.

## MySQL — только через SSH

Прямой коннект к `37.252.20.248:3306` с рабочей машины режется IP-фильтром
(handshake проходит, первый запрос убивает соединение). Запросы гонять так:

```python
_, out, _ = ssh.exec_command(
    "mysql -h 127.0.0.1 -u <user> -p'<pass>' cab -e 'SQL'")
```

Креды БД — из `server/config.py` (`Production.SQLALCHEMY_DATABASE_URI`,
`mysql+pymysql://user:pass@host/db`), БД = `cab`.
Таблицы: `users`, `drivers`, `trips` (=заказы), `trips_events`, `payments`,
`tariffs`, `auth_codes`, `fb_users`, `files`.
Заказы = `trips`, статусы — int-enum (см. `server/enums.py`).

## Безопасность

- Только **SELECT** для диагностики; UPDATE/DELETE — отдельное одобрение.
- Пароль SSH/креды БД не выводить в лог/чат (маскировать при печати команд).
