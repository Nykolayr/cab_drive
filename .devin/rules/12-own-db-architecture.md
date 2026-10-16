# Cab Drive — архитектура Postgres SoT

## Монорепо

- Flutter МП: `cab_drive_app/`
- Flask backend: `server/`
- VPS: `37.252.20.248`, systemd `cab.service` (gunicorn :5000), `cab-wss.service` (:5001)
- Nginx: `https://cab.artean.ru`, WSS `wss://cab.artean.ru/ws/`
- Postgres app: `cab_drive_app` (`DATABASE_URL` на сервере)
- MySQL `cab` — **только** админ SQL (`User` / `FirebaseUser` phone bridge), **не** app data

## Что остаётся на Google (намеренно)

| Сервис | Зачем |
|--------|-------|
| **Firebase Auth** | телефон / ID token; Bearer для `/api/app/*` |
| **FCM** | доставка пушей (токены в PG `app_user_fcm_tokens`) |

## SoT и зеркало

```
МП / Dashboard
    │ Bearer Firebase ID token  или  admin session
    ▼
Flask /api/app/*  +  WSS /ws/
    │
    └─► Postgres app_*     = Source of Truth
        (Firestore soft mirror OFF: APP_FS_MIRROR=0)
```

- Health: `GET /api/app/health` → `sot=postgres`, `fs_mirror=false` (прод).
- Клиент: **API/WSS only** для app-data; не писать FS как SoT.
- Откат mirror: `APP_FS_MIRROR=1` в env + `systemctl restart cab.service`.

## Правила для агента

1. Новые app-данные — **только PG**, не dual-write в FS.
2. Auth = Firebase; пароли/секреты не в git.
3. Деплой: `cab.service` + при WSS `cab-wss.service`; nginx `/ws/`.
4. Прод: `APP_FS_MIRROR=0` — не включать `1` без причины (откат).
5. Не путать MySQL `cab` и Postgres `app_*`.
6. Client errors — смотреть `app_client_errors` / admin GET при жалобах заказчика.
7. APK/bundle — только по явной просьбе пользователя.

## Ключевые модули бэкенда

| Модуль | Роль |
|--------|------|
| `app_data/__init__.py` | Blueprint `/api/app` |
| `app_auth_mp.py` | verify Firebase UID |
| `app_pg.py` | Postgres access, mirror_*, get_me, orders, pay |
| `app_fs_mirror.py` | soft_fs / APP_FS_MIRROR |
| `app_me_ops.py` | shift, fine, me/location |
| `app_order_ops.py` | complete, status, accept-bid, dequeue, cancel, hide, geo, patch |
| `app_bids_ops.py` | bids CRUD, FCM token; `create_bid` → FCM клиенту |
| `app_chat_pg.py` | chats/messages PG |
| `app_reviews_ops.py` | reviews create/list + soft FS |
| `app_verifications_ops.py` | driver KYC create/list/approve/reject + soft FS |
| `app_profile_ops.py` | addresses add/remove + saved_cards CRUD + soft FS |
| `app_fcm_ops.py` | FCM send via `app_user_fcm_tokens` (PG); `notify_safe` |
| `app_push.py` | единая точка событий FCM + smoke по телефону |
| `app_client_errors_ops.py` | приём ошибок МП → `app_client_errors` |
| `wss_server.py` | WSS hub (отдельный процесс) |
| `tinkoff/webhook.py` | PG-first paid + accept_bid card |
| `chats/api.py` | dashboard: PG-first list/send |

## Хвосты чистки

1. Выпил `cloud_firestore` / мёртвых `query*Record` импортов из pubspec/МП.
2. Legacy PDF URL в «О приложении» → перенести PDF на свой `files/`.
3. `ClientErrorReporter.appVersion` — синхронизировать с `pubspec` при релизе.
4. Tinkoff GetCardList sync — optional.

## Связь

- `.devin/docs/ARCHITECTURE.md` — полная архитектура.
- `.devin/docs/API_REFERENCE.md` — endpoints / WSS.
- `.devin/docs/CUTOVER_OWN_DB.md` — история и матрица cutover.
