# Cutover: Postgres SoT (Auth + FCM остаются на Google)

**Цель (достигнута на проде):** app-data SoT = Postgres. Firestore не используется как БД приложения (`APP_FS_MIRROR=0`). Google: Firebase Auth + доставка FCM. Файлы — свой `files/upload`. Remote Config — локальные константы.

**Актуально:** 2026-09-10. Обзор для агента: `.cursor/rules/cab-drive-own-db-architecture.mdc`.

---

## П.1 Матрица (историческая)

Коллекции FS (`users`, `order`, `responses`, `pay_order`, `chats`/`messages`, `saved_cards`, `request_verefication`, `reviews`, `ff_user_push_notifications`) переведены на `app_*` Postgres + `/api/app/*` / WSS.

### MySQL `cab` (админка SQL)
Отдельный контур (`User`, `FirebaseUser` phone/password) — **не** app data. Не путать с `app_*` Postgres.

---

## План выполнения (статус)

| # | Пункт | Статус |
|---|-------|--------|
| 1 | Матрица | **done** |
| 2 | Users CRUD / `GET|PATCH /me` | **done** |
| 3 | Orders lifecycle API, PG = SoT | **done** |
| 4 | Responses + FCM tokens API | **done** |
| 5 | pay_order PG + webhook | **done** |
| 6 | Bearer + `APP_FS_MIRROR` | **done**; прод **`=0`** |
| 7–11 | МП на API (create/feed/pay/orders/me) | **done** |
| 12–14 | Poll/WSS вместо FS streams | **done** (основные флоу) |
| 15–19 | Cutover mirror off, dashboard/timer PG | **done** |
| 20 | P1 chats/verif/reviews/cards/addresses | **done** |
| 21 | Login/OTP/profile без FS; strip FS fallbacks | **done** (2026-09-09) |
| 22 | Remote Config → локальный конфиг | **done** |
| 23 | Session `/me` parse (`_geo` latlng) + login_complete routing | **done** (2026-09-10) |
| 24 | Client errors → `app_client_errors` (шаблон digitalsquare) | **done** (2026-09-10); релиз МП **1.1.94+94** |
| 25 | Выпил `cloud_firestore` из pubspec | **pending** (хвост чистки) |

### Правило записи

1. **Пишем в Postgres всегда** (SoT).  
2. Firestore — только если `APP_FS_MIRROR=1` (`soft_fs`). На проде **0**.  
3. МП: не писать/не читать FS как SoT; API/WSS only.

---

## P0 API (факт)

```
GET/PATCH  /api/app/me
POST       /api/app/me/shift/start|end
POST       /api/app/me/fine/late-commission|clear
POST       /api/app/me/location
POST       /api/app/me/fcm
GET        /api/app/orders/mine|feed
POST       /api/app/orders/create
GET/PATCH  /api/app/orders/:id
POST       /api/app/orders/:id/status|complete|cancel|accept-bid|dequeue|hide|geo
POST/GET/DELETE /api/app/orders/:id/bids
POST/GET/PATCH /api/app/payments…
POST/GET   /api/app/chats…  (+ WSS /ws/)
POST       /api/app/client-errors   (МП, auth optional)
GET        /api/app/client-errors   (admin session)
```

Источник: шаблон `_my_template/digitalsquare` (`ClientErrorReporter`) + `fastify-api` `002_client_errors.sql`.
Таблица: `app_client_errors` (миграция `006_client_errors.sql`).

Health: `GET /api/app/health` → `sot=postgres`, `fs_mirror=false`.

---

## Формулировка для заказчика

> Source of Truth данных приложения — собственный Postgres. Firestore как база приложения на проде не используется. Google остаётся только для авторизации (Firebase Auth) и доставки push (FCM). Загрузка файлов — на наш сервер.

---

## Хвосты чистки

1. Удалить зависимость `cloud_firestore` / мёртвые query-helpers из МП  
2. PDF политики/условий → свой `files/` (сейчас legacy Storage URL в константах)  
3. Tinkoff GetCardList sync — optional  
