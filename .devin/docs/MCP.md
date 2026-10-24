# MCP-серверы Cab Drive

Подключённые серверы и как их донастроить/использовать. Конфиг лежит в
`.devin/mcp_config.local.json` (gitignored, секреты не коммитятся).

## Что подключено

| Сервер | Тип | Зачем | Статус |
|--------|-----|-------|--------|
| `github` | HTTP `api.githubcopilot.com/mcp/` | PR, issues, диффы, статусы репо `Nykolayr/cab_drive` | ⚠ нужен PAT |
| `firebase` | stdio `firebase-tools experimental:mcp` | Firestore-запросы, Auth-юзеры, дебаг FCM | ✅ готов (логин `nykolayr@gmail.com` уже есть) |
| `mysql` | stdio `@benborla29/mcp-server-mysql` | SELECT по прод-БД | ❌ **disabled** — см. ниже |

## MySQL — прямой доступ не работает

MySQL живёт на VPS `37.252.20.248:3306`. TCP-коннект и auth проходят, но
первый же запрос рвёт соединение — на стороне сервера фильтрация по IP
(ходить можно только с самого VPS). Поэтому `mysql` MCP отключён
(`"disabled": true` в конфиге).

**Рабочий путь запросов — через SSH** (paramiko, креды как в
`cab_drive_app/tool/_deploy_*.py`):

```python
ssh.connect('37.252.20.248', username='root', password=CAB_DRIVE_SSH_PASSWORD)
ssh.exec_command(f"mysql -h 127.0.0.1 -u {USER} -p'{PASS}' cab -e 'SQL'")
```

Креды MySQL — в `server/config.py` (`Production.SQLALCHEMY_DATABASE_URI`),
БД = `cab`. Таблицы: `users`, `drivers`, `trips` (это заказы!),
`trips_events`, `payments`, `tariffs`, `auth_codes`, `fb_users`, `files`.

Опция на будущее: MySQL MCP можно поднять **на самом VPS** в remote-режиме
(`IS_REMOTE_MCP=true` + `REMOTE_SECRET_KEY`) и подключаться по HTTP — если
понадобится, делать отдельной задачей.

## Донастройка GitHub (1 раз, 2 минуты)

1. github.com → Settings → Developer settings → Personal access tokens →
   **Tokens (classic)** → Generate new token.
   - Скоупы: `repo` (и `read:org`, если нужны орг-данные). Read-only достаточно.
2. Вставить в `.devin/mcp_config.local.json` вместо `REPLACE_WITH_GITHUB_PAT`.
3. Перезапустить сессию Devin (MCP подхватываются на старте сессии).

## Безопасность

- **mysql** — сервер read-only **по умолчанию** (INSERT/UPDATE/DELETE выключены
  флагами `ALLOW_*_OPERATION`). Не включать их без явной необходимости.
  Рекомендация на будущее: завести отдельного read-only юзера в MySQL
  (`GRANT SELECT ON db.* TO 'devin_ro'@'%'`) и подставить его в конфиг.
- **github** — PAT хранится только в local-конфиге (gitignored). Не копировать
  в `.devin/mcp_config.json` (тот коммитится).
- MCP-инструменты по умолчанию **спрашивают approve** на каждый вызов —
  это нормально и безопасно. Чтобы не кликать каждый раз, можно добавить
  в `.devin/config.json`:
  ```json
  { "permissions": { "allow": ["mcp__github__*", "mcp__firebase__*", "mcp__mysql__mysql_query"] } }
  ```

## Использование

- Инструменты появляются автоматически; можно `@`-упоминать сервер в сообщении.
- Проверка: попросить «покажи открытые PR» (github), «коллекции Firestore»
  (firebase), «схему таблицы orders» (mysql).
- Проблемы: `devin mcp list` / `devin mcp get <name>` в терминале; лог stdio-
  сервера проверять запуском `npx -y <pkg>` вручную.

## Заметки

- `devin` CLI не обязан быть в PATH — конфиг читает и десктоп.
- Если firebase отвечает ошибками проектов — `firebase login` уже выполнен,
  ошибка `projects:list` на этой машине не блокирует MCP (он идёт через
  application-default креды CLI).
- Доки Devin по MCP: `share/devin/docs/extensibility/mcp/configuration.mdx`
  в установке Devin Desktop.
