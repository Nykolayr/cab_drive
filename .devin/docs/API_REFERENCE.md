# Cab Drive — API reference

## Базовые URL

| Клиент | URL |
|--------|-----|
| МП (release) | `https://cab.artean.ru/api/app/...` |
| МП (legacy direct) | `http://37.252.20.248:5000/kek/...` (устарел) |
| Админка | `https://cab.artean.ru/d/...` |
| WSS | `wss://cab.artean.ru/ws/` |

## Auth

### МП

Bearer `Firebase ID token`.

### Админка

- `POST /d/auth` → JSON `{status: ok}` + session cookie.
- UI redirect: `templates/dashboard/auth.html` → `/d/statistics` (после логина — `/d/order_settings` вместо тяжёлой статистики).

---

## `/api/app/*` — мобильное приложение

### Me

```http
GET    /api/app/me
PATCH  /api/app/me
POST   /api/app/me/shift/start
POST   /api/app/me/shift/end
POST   /api/app/me/fine/late-commission
POST   /api/app/me/fine/clear
POST   /api/app/me/location
POST   /api/app/me/fcm
POST   /api/app/me/payout          # Jump Finance payout
```

### Orders

```http
GET    /api/app/orders/mine
GET    /api/app/orders/feed
POST   /api/app/orders/create
GET    /api/app/orders/:id
PATCH  /api/app/orders/:id
POST   /api/app/orders/:id/status
POST   /api/app/orders/:id/complete
POST   /api/app/orders/:id/cancel
POST   /api/app/orders/:id/accept-bid
POST   /api/app/orders/:id/dequeue
POST   /api/app/orders/:id/hide
POST   /api/app/orders/:id/geo
```

### Bids

```http
POST   /api/app/orders/:id/bids
GET    /api/app/orders/:id/bids
DELETE /api/app/orders/:id/bids/:bid_id
```

### Payments

```http
POST   /api/app/payments
GET    /api/app/payments
PATCH  /api/app/payments/:id
```

### Chats

```http
POST   /api/app/chats/ensure
GET    /api/app/chats
GET    /api/app/chats/:id/messages
POST   /api/app/chats/:id/messages
```

### Client errors

```http
POST   /api/app/client-errors    # auth optional
GET    /api/app/client-errors?limit=50   # admin session
```

### Misc

```http
GET    /api/app/health            # {sot: "postgres", fs_mirror: false}
POST   /api/app/reviews
GET    /api/app/reviews
POST   /api/app/verifications
GET    /api/app/verifications
POST   /api/app/addresses
GET    /api/app/addresses
DELETE /api/app/addresses/:id
POST   /api/app/cards
GET    /api/app/cards
DELETE /api/app/cards/:id
```

---

## `/d/*` — админка

```http
POST   /d/auth
GET    /d/statistics
GET    /d/order_settings
GET    /d/users
GET    /d/chats
GET    /d/trips
...
```

Полный список в `server/dashboard/urls.py`.

---

## `/users/*` — admin auth / FirebaseUser bridge

```http
POST   /users/auth          # звонок → call_token
POST   /users/auth_by_code  # { user, access_token }
```

Email формат: `{10цифр}@ydrive.appwave.com`.  
Сервер `auth_email()` — единственный источник канонического email.

---

## `/tinkoff/*` — webhooks

```http
POST   /tinkoff/webhook
```

Обработка уведомлений об оплате. PG-first update + accept_bid card flow.

---

## WSS `/ws/`

Формат сообщений:

```json
{ "t": "auth", "p": { "token": "..." } }
{ "t": "chat.subscribe", "p": { "chat_id": "..." } }
{ "t": "chat.history", "p": { "chat_id": "..." } }
{ "t": "chat.send", "p": { "chat_id": "...", "text": "..." } }
```

Ответы:

```json
{ "t": "auth.ok" }
{ "t": "chat.new", "p": {...} }
{ "t": "chat.history.ok", "p": {...} }
```

Задел: `order.updated` (ещё не wired с сервера заказов).

---

## Status enums

### `StatusOrder`

- `newOrder`
- `completed`
- `hidden`
- `cancelled`
- `spec_set`
- `at_work`
- `on_confirmation`

### `StatusVerif`

- `onVerif`
- `Completed`
- `otklonena`

### `Car`

- `largusTermo`
- `largus`
- `fiat`

### `PayMethod`

- `card`
- `cash`

### `PaymentType`

- `regular`
- `initRecurrent`
- `chargeRecurrent`
- `regularCustomer`

---

## Health

```http
GET /api/app/health
```

Ожидаемый ответ (прод):

```json
{
  "sot": "postgres",
  "fs_mirror": false
}
```

Если `fs_mirror: true` — на проде включён откат к Firestore.
