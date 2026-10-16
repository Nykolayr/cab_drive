# Cab Drive — критические пользовательские флоу

## 1. Авторизация / онбординг

### 1.1 Email Firebase

| Место | Формат |
|-------|--------|
| Firebase / OTP legacy | `{10цифр}@ydrive.appwave.com` |
| Сервер `auth_email()` | единственный источник канона |
| Клиент после кода | `signInWithEmail(user.email, user.password)` |

**Запрещено:** создавать Firebase с `@ydrive.com` или отдавать клиенту email, отличный от Firebase.

### 1.2 Цепочка входа (новый пользователь)

```
Onbord → LoginWidget (AuthBloc)
  → POST users/auth (звонок) → call_token
  → POST users/auth_by_code → { user, access_token }
  → SharedPrefs.token = access_token
  → signInWithEmail(user.email, user.password)  // Firebase
  → maybeCreateUser → Firestore users/{uid}
  → LoadWidget
```

**Файлы:** `auth_remote_data_source.dart`, `code_page.dart`, `firebase_auth_manager.dart`, `backend.dart` (`maybeCreateUser`).

### 1.3 Цепочка входа (существующий, в т.ч. iPhone / legacy OTP)

- Firestore + Firebase уже с `@ydrive.appwave.com`, пароль legacy = **равен email**.
- Сервер `create_user_by_phone`: ищет Firebase по `appwave` и `ydrive.com`, привязывает SQL без смены пароля на legacy.
- Клиент **тот же телефон** — не новый аккаунт.

### 1.4 LoadWidget — маршрутизация после входа

| Условие | Экран |
|---------|-------|
| `admin == true` | `/verifAdmin` |
| `loginComplete && isDriver` | `/mainDriver` (+ `toggleRouteTracking`) |
| `loginComplete && !isDriver` | `/mainUser` |
| иначе | `/geo` (onboarding) |

**Источник истины для роли водителя на новом устройстве:** `currentUserDocument.isDriver` (Firestore), не только `FFAppState.driver`.

### 1.5 Профиль и город водителя

| Где | Файл |
|-----|------|
| Онбординг водителя | `verif_driver_widget.dart` → `CityWidget` |
| Профиль | `profile_widget.dart` → «Город поиска» |
| Подсказки | `CityWidget` → `AutocompleteCall` → Yandex Geocoder |

---

## 2. Создание заказа (заказчик)

```
mainUser / detaliySozdanie
  → выбор Откуда / Куда (AddressPlaceSelection.resolve + safePopModal)
  → расчёт цены (ORS / собственные тарифы)
  → создание: POST /api/app/orders/create
  → poll feed / my_orders
```

**Важно:** точки передаются через `pointToApiMap`, не сырым `LatLng`.

---

## 3. Лента заказов и отклики (водитель)

```
mainDriver
  → GET /api/app/orders/feed (poll)
  → tap заказ → orderPageDriver
  → POST /api/app/orders/:id/bids
  → FCM клиенту о новом отклике
```

---

## 4. Принятие отклика / оплата

```
orderPageCustomer
  → POST /api/app/orders/:id/accept-bid
  → FCM водителю
  → оплата: POST /api/app/payments (init/initRecurrent)
  → webhook Tinkoff → PG-first update
```

---

## 5. Выполнение заказа

```
orderPageDriver
  → POST /api/app/orders/:id/status
  → гео: POST /api/app/orders/:id/geo
  → complete: POST /api/app/orders/:id/complete
```

---

## 6. Чаты

```
chats / chat
  → POST /api/app/chats/ensure
  → WSS subscribe + history
  → WSS send / HTTP fallback POST /api/app/chats/:id/messages
```

---

## 7. Выплаты водителю (Jump Finance)

```
driver/sposobviplat
  → POST /api/app/me/payout
  → Jump OpenAPI /payments
  → если статус финальный успех → PG balance = 0
  → если «нужно подтверждение» → баланс не трогаем, текст ошибки в МП
```

Подробнее: `.devin/docs/JUMP_PAYOUT_RECON.md`.

---

## 8. Профиль / настройки

- `GET/PATCH /api/app/me` — основа профиля.
- `FFAppState` — локальные флаги, не источник истины роли.
- Фото, имя, город, телефон — через `patchMe` → PG.

---

## 9. Client errors

- МП: хуки в `main.dart` (`FlutterError` / `PlatformDispatcher`) → `POST /api/app/client-errors`.
- PG: `app_client_errors`.
- Админ: `GET /api/app/client-errors?limit=50`.
- Auth на POST опционален; при Bearer пишется `user_id` / телефон / роль.
