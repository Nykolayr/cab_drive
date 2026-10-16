# Cab Drive — архитектура и критические флоу

Документ обязателен для агента **перед любым изменением auth, роутинга, onboarding, профиля водителя** и **перед сборкой APK/AAB**.

---

## 1. Обзор и стек

| Область | Технология |
|---------|------------|
| Мобильное приложение | Flutter (FlutterFlow-экспорт) |
| State (глобальный) | Provider + `FFAppState` (`ChangeNotifier`) |
| State (экран) | `FlutterFlowModel<T>` на каждый экран (`*_model.dart`) |
| Навигация | go_router (`lib/flutter_flow/nav/nav.dart`) |
| HTTP | `package:http` через `ApiManager` (singleton) |
| Auth | Firebase Auth (телефон → email `{phone}@ydrive.appwave.com`) |
| Пуши | FCM; токены хранятся в Postgres `app_user_fcm_tokens` |
| Карты | `yandex_mapkit` + OpenRouteService + Yandex Geocoder |
| Локализация | `FFLocalizations`, только `ru` |
| Бэкенд | Flask + Gunicorn + Nginx |
| База приложения | Postgres (`app_*`) — **Source of Truth** |
| Админ-DB | MySQL `cab` — только админка/bridge phone |
| Файлы | свой `files/upload` + `files/get` (не Firebase Storage SDK) |

**Google остаётся только для:**
- Firebase Auth
- FCM delivery

**Firestore как БД приложения на проде не используется** (`APP_FS_MIRROR=0`).

---

## 2. Структура монорепо

```text
D:\Projects\cab_drive
├── cab_drive_app/            # Flutter МП
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app_state.dart    # FFAppState
│   │   ├── flutter_flow/     # nav, theme, widgets, util, model
│   │   ├── auth/
│   │   ├── backend/          # Firestore schema, API calls, api_manager
│   │   ├── login/            # auth, onboarding, load
│   │   ├── customer/         # UI заказчика
│   │   ├── driver/           # UI водителя
│   │   ├── admin/            # UI админа
│   │   ├── chat/
│   │   ├── pages/            # профиль, меню, navbar, мои заказы
│   │   └── custom_code/      # actions + widgets
│   ├── android/
│   ├── ios/
│   ├── scripts/              # pre_apk_regression.ps1, release_android.ps1, verify_handoff.ps1
│   ├── tool/                 # sync_env.dart и др.
│   ├── pubspec.yaml
│   └── .env.example
├── server/                   # Flask backend
│   ├── app.py                # entry + OpenAPI + blueprint registration
│   ├── app_data/             # /api/app blueprints
│   ├── app_*.py              # app endpoints
│   ├── users/                # admin auth + Firebase bridge
│   ├── orders/
│   ├── chats/
│   ├── dashboard/
│   ├── payments/
│   ├── tinkoff/
│   ├── yookassa/
│   ├── migrations/           # 001…006_client_errors.sql
│   ├── config.example.py
│   └── requirements.txt
├── docs/                     # legacy docs
├── .cursor/                 # legacy Cursor rules (оставлены)
└── .devin/                   # project-конфигурация Devin
    ├── rules/
    └── docs/
```

---

## 3. Бэкенд (Flask)

### 3.1 Регистрация blueprint'ов (`server/app.py`)

- `/api/app/*` — мобильное приложение (`app_data`)
- `/d/*` — веб-админка (`dashboard`)
- `/d/api/orders/*` — dashboard orders API
- `/users/*` — admin auth / FirebaseUser bridge
- `/tinkoff/*` — Tinkoff webhooks
- `/payments/*` — ЮKassa callbacks

### 3.2 Ключевые модули `/api/app`

| Модуль | Роль |
|--------|------|
| `app_data/__init__.py` | Blueprint `/api/app` |
| `app_auth_mp.py` | verify Firebase UID по Bearer token |
| `app_pg.py` | Postgres access, mirror_*, get_me, orders, pay |
| `app_fs_mirror.py` | soft_fs / APP_FS_MIRROR switch |
| `app_me_ops.py` | shift, fine, me/location |
| `app_order_ops.py` | complete, status, accept-bid, dequeue, cancel, hide, geo, patch |
| `app_bids_ops.py` | bids CRUD, FCM token; `create_bid` → FCM клиенту |
| `app_chat_pg.py` | chats/messages PG |
| `app_reviews_ops.py` | reviews create/list + soft FS |
| `app_verifications_ops.py` | driver KYC create/list/approve/reject + soft FS |
| `app_profile_ops.py` | addresses add/remove + saved_cards CRUD + soft FS |
| `app_fcm_ops.py` | FCM send via `app_user_fcm_tokens`; `notify_safe` |
| `app_push.py` | единая точка событий FCM + smoke по телефону |
| `app_client_errors_ops.py` | приём ошибок МП → `app_client_errors` |
| `app_payout_ops.py` | Jump Finance payout |
| `wss_server.py` | WSS hub на отдельном порту |

### 3.3 Деплой и процессы

- `cab.service` — gunicorn `:5000`
- `cab-wss.service` — WSS `:5001`
- nginx — `https://cab.artean.ru` + `/ws/` → WSS
- Postgres app DB: `cab_drive_app` (`DATABASE_URL` на сервере)
- MySQL `cab` — только админ SQL

### 3.4 Фоновые циклы (`app.py`)

Запуск через `_start_bg_exclusive` (fcntl lock) — **один** процесс на весь gunicorn.

| Цикл | Зачем | Ограничения |
|------|-------|-------------|
| `check_order_status` | auto-cancel устаревших `newOrder`; auto-hide `completed` → `hidden` | `limit(50)`, sleep **60 с** |
| `notify_busy_drivers_about_new_orders` | FCM «заказ по пути» занятым | `limit(50)`, sleep **30 с** |

---

## 4. Мобильное приложение (Flutter)

### 4.1 Точка входа и bootstrap (`lib/main.dart`)

1. `initFirebase()` → `lib/backend/firebase/firebase_config.dart`
2. `FFAppState().initializePersistedState()` (secure storage)
3. `initializeFirebaseRemoteConfig()` → локальные константы (не fetch Google)
4. `ChangeNotifierProvider` → `MyApp`
5. `createRouter(AppStateNotifier)` → go_router
6. Стрим `cabDriveFirebaseUserStream()` → обновление `AppStateNotifier`
7. FCM token stream

### 4.2 Роутинг после логина (`lib/login/load/load_widget.dart`)

| Условие | Экран |
|---------|-------|
| `admin == true` | `/verifAdmin` |
| `loginComplete && isDriver` | `/mainDriver` |
| `loginComplete && !isDriver` | `/mainUser` |
| иначе | `/geo` (дозаполнение профиля) |

### 4.3 State

- **Firebase Auth** — сессия, `currentUser`, Firestore `users/{uid}`.
- **FFAppState** (secure storage) — локальные флаги `driver`, `roleSelected`, `phone`, `OTP`, `Password` и in-memory сессия заказа (`pointA`, `pointB`, `price*`, `movers`, `selfi`).
- **AuthBloc** — только экран логина (звонок + код).

### 4.4 Структура `lib/`

```text
lib/
├── main.dart                 # entry
├── index.dart                # re-export экранов
├── app_state.dart            # FFAppState
├── flutter_flow/             # инфраструктура FlutterFlow
├── auth/                     # Firebase Auth
├── backend/                  # Firestore schema, API calls, api_manager
│   ├── schema/               # records + structs + enums
│   ├── api_requests/         # ApiManager + api_calls
│   └── firebase/             # config
├── login/                    # auth pipeline, onboarding
├── customer/                 # заказчик
├── driver/                   # водитель
├── admin/                    # UI админа
├── chat/                     # чаты
├── pages/                    # профиль, настройки, navbar, мои заказы
└── custom_code/              # actions + widgets
```

### 4.5 Паттерн экрана

`feature/feature_widget.dart` + `feature_model.dart`; регистрация в `nav.dart` и `index.dart`.

### 4.6 Session `/me` → UsersRecord

JSON `/api/app/me` мапится в `UsersRecord` через `UsersRecordMapper`.  
Адреса с PG приходят как `latlng: {_geo:{lat,lng}}`. Жёсткий `as LatLng?` в `PointStruct` **ронял весь парсер** → `refreshAppMeCache` глотал exception → `currentUserDocument == null`.  
Парсить через `PointStruct.parseLatLng`; ошибки `addresses`/`car`/`current_order` не должны валить весь документ.

---

## 5. Source of Truth и зеркало

```
МП / Dashboard
    │ Bearer Firebase ID token  или  admin session
    ▼
Flask /api/app/*  +  WSS /ws/
    │
    └─► Postgres app_*     = Source of Truth
        (Firestore soft mirror OFF: APP_FS_MIRROR=0)
```

- `GET /api/app/health` → `sot=postgres`, `fs_mirror=false` (прод).
- МП: API/WSS only для app-data; не писать Firestore как SoT.
- Soft FS writes с сервера не идут на проде.
- Откат mirror: `APP_FS_MIRROR=1` + `systemctl restart cab.service`.

### Postgres таблицы (app)

`app_users`, `app_orders`, `app_order_responses`, `app_pay_orders`, `app_user_fcm_tokens`, `app_chats`, `app_chat_members`, `app_messages`, `app_reviews`, `app_verifications`, `app_saved_cards`, `app_client_errors`.

### Firestore — legacy

Коллекции: `users`, `order`, `responses`, `pay_order`, `chats`/`messages`, `saved_cards`, `request_vererefication`, `reviews`, `ff_push_notifications`.  
**Не SoT на проде.** Админка и старый код могут ещё читать/писать в FS; новый код пишет только в PG.

---

## 6. API и WSS

### 6.1 API МП (Bearer Firebase token) — ядро

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
POST       /api/app/client-errors   (auth optional)
GET        /api/app/client-errors   (admin session)
```

### 6.2 WSS протокол

Формат сообщений: `{ "t": "...", "id?": "...", "p": {...} }`.

- `auth` → `auth.ok`
- `chat.subscribe` / `history` / `send` → `chat.new` / `chat.history.ok`
- Задел: `order.updated` (ещё не wired с сервера заказов).

### 6.3 REST API в МП

- Клиент: `lib/backend/api_requests/api_manager.dart` (`ApiManager.instance`).
- Описание вызовов: `lib/backend/api_requests/api_calls.dart`.
- **Секреты захардкожены в `api_calls.dart`** (Google API key, SMS token, Jump Client-Key) — при рефакторинге выносить в env / Remote Config / backend proxy.

Полный референс см. `.devin/docs/API_REFERENCE.md`.

---

## 7. Критические флоу

### 7.1 Канон авторизации

**Email Firebase:** `{10цифр}@ydrive.appwave.com`.  
Сервер `auth_email()` — единственный источник.

**Новый пользователь:**

```
Onbord → LoginWidget (AuthBloc)
  → POST users/auth (звонок) → call_token
  → POST users/auth_by_code → { user, access_token }
  → SharedPrefs.token = access_token
  → signInWithEmail(user.email, user.password)
  → maybeCreateUser → Firestore users/{uid}
  → LoadWidget
```

**Существующий пользователь (в т.ч. iPhone / legacy OTP):**
- Firestore + Firebase уже с `@ydrive.appwave.com`, пароль legacy = email.
- Сервер `create_user_by_phone` ищет Firebase по `appwave` и `ydrive.com`, привязывает SQL без смены пароля.
- Клиент **тот же телефон** — не новый аккаунт.

### 7.2 Город водителя

| Где | Файл |
|-----|------|
| Онбординг водителя | `verif_driver_widget.dart` → `CityWidget` |
| Профиль | `profile_widget.dart` → «Город поиска» |
| Подсказки | `CityWidget` → `AutocompleteCall` → Yandex Geocoder |

### 7.3 Заказ / отклики

- Create/repeat order, edit order load+save — API.
- Точки через `pointToApiMap` (не сырой LatLng).
- Feed / order detail / bids / my_orders — API poll.
- `create_bid` → FCM клиенту; `accept_bid` → FCM водителю; `extra_accept` → клиенту; `patch_order` цена → откликнувшиеся.

### 7.4 Оплата и выплаты

**Заказчик (карта):** `lib/customer/pay_init/`, `pay_add_card/` → Tinkoff Cloud Run прокси.

**Водитель (выплаты):** `lib/driver/sposobviplat/` → Jump.finance `POST /api/app/me/payout`.  
Баланс списывается в `0` **только** если Jump вернул финальный успех.  
Подробнее: `.devin/docs/JUMP_PAYOUT_RECON.md`.

### 7.5 Чаты

- `POST /api/app/chats/ensure` + WSS/HTTP history+send.
- Inbox poll; `chat_bar` без FS write.
- Dashboard: `chats/api.py` — PG-first list/send.

---

## 8. Деплой и инфраструктура

### 8.1 Сервер

- VPS: `37.252.20.248`
- Код: `/root/projects/cab_drive`
- `cab.service` — gunicorn `:5000`
- `cab-wss.service` — WSS `:5001`
- nginx: `https://cab.artean.ru` + `/ws/`
- Postgres: `cab_drive_app`
- MySQL: `cab`

### 8.2 После правок `server/`

Деплой на VPS **до** теста заказчиком при изменениях:
- `api.py`, `entities.py`
- `dashboard/`
- фоновые циклы
- миграции

### 8.3 Проверка после деплоя

- `GET /api/app/health` → `sot=postgres`, `fs_mirror=false`
- `curl /d/auth` → 200 быстро
- POST логин админки → ok
- GET целевой страницы после логина → не 504
- journalctl: нет каскада worker SIGKILL

---

## 9. Секреты и окружение

### 9.1 МП (`cab_drive_app/.env`)

- `YANDEX_MAPKIT_KEY`
- `YANDEX_GEOCODER_KEY`
- `YANDEX_SUGGEST_KEY`
- `ORS_API_KEY`
- `IS_TEST`, `QUICK_DRIVER_LOGIN`

Шаблон: `.env.example`.  
`tool/sync_env.dart` синхронизирует MapKit ключ в `android/local.properties` и `ios/Runner/Info.plist`.

### 9.2 Сервер (`server/config.py`)

- DB URI (Postgres/MySQL)
- Zvonok API
- Redis
- Tinkoff терминалы и URL
- Jump Client Key
- SMS token
- Google API Key

Шаблон: `config.example.py`.

### 9.3 Подпись Android

- `android/key.properties` + `key.jks` (gitignored)
- Один keystore для Play и RuStore
- `CAB_DRIVE_RUSTORE=true` переключает `applicationId` на `com.appwawe.YDrive`

---

## 10. Релизный процесс

### 10.1 Перед любой сборкой

- `powershell -File scripts/pre_apk_regression.ps1` — exit 0.
- `.env` заполнен реальными ключами.
- Bump версии `1.1.{N}+{N}` (patch = buildNumber).

### 10.2 Android

| Артефакт | Стор | Package | Команда |
|----------|------|---------|---------|
| AAB | Google Play | `com.cab.drive` | `flutter build appbundle --release` |
| APK | RuStore | `com.appwawe.YDrive` | `$env:CAB_DRIVE_RUSTORE='true'; flutter build apk --release` |

Полный релиз: `scripts/release_android.ps1`.

### 10.3 iOS / TestFlight

- Только по явной просьбе.
- Flutter 3.47+, iOS 15+, UIScene обязателен.
- `dart run tool/sync_env.dart` → `flutter pub get` → `pod install` → `flutter build ios --release --no-codesign` → Xcode Archive/Upload.
- MapKit ключ в `Info.plist` — placeholder в git.

### 10.4 Регрессия перед APK

Автоматически:
- `pre_apk_regression.ps1`
- `flutter analyze` (без error)
- `flutter test` (auth + role)

Ручной smoke (если есть устройство):
1. Новый номер — звонок → код → Load → Vibor или Geo.
2. Существующий водитель — вход → MainDriver без повторного онбординга.
3. Профиль водителя — «Город поиска» открывается.
4. Home → назад — нет FATAL MapKit / повторного выбора роли.

---

## 11. Чеклист «Влияние на флоу» (в каждый план)

Перед кодом ответить письменно:

- [ ] Трогаю ли `login/`, `auth/`, `load_widget`, `server/users/`?
- [ ] Меняется ли формат email/телефона/токена?
- [ ] Нужен ли деплой сервера вместе с APK?
- [ ] Ломает ли это вход **существующего** водителя с iPhone на Android?
- [ ] Ломает ли **новую регистрацию**?
- [ ] Нужно ли обновить `pre_apk_regression.ps1` / тесты?
- [ ] Трогаю ли Firestore stream / фоновые циклы / админку? (риск 429 и 504)

Если хотя бы один «да» на auth — **обязателен** прогон `pre_apk_regression.ps1`.

---

## 12. История инцидентов и хвосты

### 12.1 APK 88 (2026-09)

| Симптом | Причина |
|---------|---------|
| Не создаётся аккаунт | Firebase `@ydrive.com`, API отдавал `@ydrive.appwave.com` |
| Водитель с iPhone не входит на Android | То же + пароль SQL ≠ Firebase legacy |
| Нет города | `responsiveVisibility(phone: false)` в профиле + auth не поднял сессию |

### 12.2 Firestore quota / админка 504 (2026-09)

- Причина: `check_order_status` без sleep × N workers + полные stream.
- Сделано: exclusive bg lock + sleep/limit; safe stats + баннер квоты; TTL/Redis; быстрый `/d/statistics` без тяжёлых filter-lists.

### 12.3 Хвосты чистки

1. Выпил `cloud_firestore` из pubspec / мёртвых query-helpers.
2. Legacy PDF URL в «О приложении» → свой `files/`.
3. `ClientErrorReporter.appVersion` → синхронизировать с `pubspec`.
4. Tinkoff GetCardList sync — optional.

---

## 13. Связанные документы

- `.devin/docs/API_REFERENCE.md` — полный HTTP/WSS референс.
- `.devin/docs/FLOWS.md` — пользовательские флоу.
- `.devin/docs/RELEASE.md` — пошаговый релиз Android/iOS.
- `.devin/docs/DEPLOY.md` — деплой сервера.
- `.devin/docs/SECRETS.md` — работа с секретами и env.
- `.devin/docs/CUTOVER_OWN_DB.md` — история и матрица cutover.
- `.devin/docs/FIRESTORE_WRITE_AUDIT.md` — аудит write в Firestore.
- `.devin/docs/JUMP_PAYOUT_RECON.md` — сверка Jump-выплат.
- `.devin/rules/` — project-правила Devin.
