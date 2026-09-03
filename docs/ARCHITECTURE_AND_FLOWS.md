# Cab Drive — архитектура, критические флоу, регрессия перед APK

Документ обязателен для агента **перед любым изменением auth, роутинга, onboarding, профиля водителя** и **перед сборкой APK/AAB**.

---

## 1. Принцип работы агента

1. **Одна задача — один узкий diff.** Не трогать auth при задаче про карты/оплату/UI.
2. **Перед планом** — раздел «Влияние на флоу» (см. §6).
3. **Перед APK** — `cab_drive_app/scripts/pre_apk_regression.ps1` (обязательно, exit 0).
4. **Не отдавать заказчику** сборку без прогона регрессии.
5. **Священные зоны** — см. `.cursor/rules/cab-drive-do-not-touch.mdc` (MapKit engine, подпись, APK без запроса).

---

## 2. Слои приложения (МП)

```
lib/
├── login/                    # Auth, onboarding, Load → маршрутизация после входа
│   ├── login/presentation/   # AuthBloc, LoginWidget (канон входа)
│   └── load/load_widget.dart # Развилка: admin / driver / user / vibor / geo
├── driver/                   # Экран водителя, город (CityWidget), фильтры
├── customer/                 # Заказчик, карта, адреса
├── pages/menu/profile/       # Профиль (город поиска для водителя)
├── auth/firebase_auth/       # Firebase session, maybeCreateUser
├── backend/                  # Firestore, API calls
└── core/utils/app_dio.dart   # HTTP к бэкенду (37.252.20.248:5000/kek/)
```

**State:**
- **Firebase Auth** — сессия, `currentUser`, Firestore `users/{uid}`.
- **FFAppState** (secure storage) — локальные флаги `driver`, `roleSelected` (дополнение, не источник истины для роли).
- **AuthBloc** — только экран логина (звонок + код).

---

## 3. Канон авторизации (НЕ ЛОМАТЬ)

### 3.1 Email Firebase

| Место | Формат |
|-------|--------|
| Firebase / OTP legacy | `{10цифр}@ydrive.appwave.com` |
| Сервер `auth_email()` | `users/entities.py` — **единственный источник** |
| Клиент после кода | `signInWithEmail(user.email, user.password)` из ответа API |

**Запрещено:** создавать Firebase с `@ydrive.com` или отдавать клиенту email, отличный от Firebase.

### 3.2 Цепочка входа (новый пользователь)

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

### 3.3 Цепочка входа (существующий, в т.ч. iPhone / legacy OTP)

- Firestore + Firebase уже с `@ydrive.appwave.com`, пароль legacy = **равен email**.
- Сервер `create_user_by_phone`: ищет Firebase по `appwave` и `ydrive.com`, привязывает SQL без смены пароля на legacy.
- Клиент **тот же телефон** — не новый аккаунт.

### 3.4 LoadWidget — маршрутизация после входа

| Условие | Экран |
|---------|--------|
| `admin` | VerifAdmin |
| `login_complete` + `is_driver` (Firestore) | MainDriver (+ синхрон FFAppState) |
| `login_complete` + roleSelected + driver (local) | MainDriver |
| `login_complete` + roleSelected + !driver | MainUser |
| `login_complete` + !roleSelected + !firestore driver | Vibor |
| !login_complete | Geo (onboarding) |

**Источник истины для роли водителя на новом устройстве:** `currentUserDocument.isDriver` (Firestore), не только `FFAppState.driver`.

### 3.5 Город водителя

| Где | Файл |
|-----|------|
| Онбординг водителя | `verif_driver_widget.dart` → `CityWidget` |
| Профиль | `profile_widget.dart` → «Город поиска» (**должен быть виден на phone**) |
| Подсказки | `CityWidget` → `AutocompleteCall` → Yandex Geocoder (ключ `.env`) |

---

## 4. Сервер (Flask) и данные

```
server/
├── app.py              # gunicorn entry; фоновые циклы (один worker через fcntl lock)
├── ttl_cache.py        # process-local TTL-кэш админки
├── cache.py            # Redis (общий кэш между workers, напр. stats)
├── users/              # auth, Firebase users, SQL
├── orders/api.py       # заказы Firestore, статистика, check_order_status, notify
├── chats/api.py        # чаты поддержки
└── dashboard/urls.py   # веб-админка /d/*
```

**Base URL в МП:** `http://37.252.20.248:5000/kek/` (`app_dio.dart`).  
**Админка:** `https://cab.artean.ru/d/` (nginx → gunicorn `:5000`), сервис `cab.service`, код на VPS `/root/projects/cab_drive`.

После правок `api.py` / `entities.py` / `dashboard/` / фоновых циклов — **деплой на VPS** до теста заказчиком.

### 4.1 Зачем Firebase / Firestore, если есть VPS

| Слой | Роль |
|------|------|
| **VPS (Flask + SQL + Redis)** | HTTP API, админка, платежи Tinkoff, бизнес-логика, фоновые задачи |
| **Firebase Auth** | Вход МП (телефон → email `{phone}@ydrive.appwave.com`) |
| **Cloud Firestore** | Документы заказов (`order`), чаты, часть профилей `users/{uid}` — то, что МП читает/пишет «по-firebase» |

Это **гибрид**, не «вместо VPS». Полный перенос на Postgres = большой рефакторинг клиента.

### 4.2 Квота Firestore (критично)

Бесплатный дневной лимит (сброс ~полночь **PT**):

| Операция | Free / день |
|----------|-------------|
| Reads | 50 000 |
| Writes | 20 000 |
| Deletes | 20 000 |
| Storage | 1 GiB |

При превышении без billing → **`429 Quota exceeded`** → gunicorn workers виснут → nginx **504**, админка «после логина падает».

Консоль: Firebase → Firestore → **Usage**;  
https://console.cloud.google.com/apis/api/firestore.googleapis.com/quotas

**Правила:**
- Никогда не делать полный `collection.stream()` без `limit` в админке/фонах.
- `fetch_firebase_orders` — hard_cap (≤250 docs), не «все заказы ради пагинации в Python».
- Опрос допустим только для **таймеров** (auto-cancel / auto-hide); смена статуса по действию пользователя — на **write path**, не поллингом.

### 4.3 Фоновые циклы (`app.py`)

Запуск через `_start_bg_exclusive` (fcntl lock `/tmp/cab_drive_bg_*.lock`) — **один** процесс на весь gunicorn, не ×N workers.

| Цикл | Зачем | Ограничения |
|------|--------|-------------|
| `check_order_status` | Авто-cancel устаревших `newOrder`; auto-hide `completed` → `hidden` | `limit(50)`, sleep **60 с** |
| `notify_busy_drivers_about_new_orders` | FCM «заказ по пути» занятым | `limit(50)`, sleep **30 с** |

Исторический баг: `while True` **без sleep** × каждый worker → выжигание reads за часы.

### 4.4 Админка `/d/*` (устойчивость к 429)

- Таймауты: `_call_timeout` с `ThreadPoolExecutor.shutdown(wait=False)` — иначе worker ждёт зависший Firestore-поток до SIGKILL.
- Статистика: sample ≤400 docs / ~120 дней + TTL (process + Redis); баннер `firestore_quota_exhausted` при 429/таймауте.
- После логина → `/d/statistics` (не settings). Первый экран статистики **не** грузит полные списки users/drivers (дорого); фильтры city/date работают.
- Users/chats/trips: пагинация, без полного stream ради `count`, TTL-кэш списков.

### 4.5 Auth админки

`POST /d/auth` → JSON `{status: ok}` + session; редирект в UI: `templates/dashboard/auth.html` → `/d/statistics`.

---

## 5. Два applicationId (Android)

| Сборка | Package | Команда |
|--------|---------|---------|
| RuStore APK | `com.appwawe.YDrive` | `CAB_DRIVE_RUSTORE=true` |
| Play AAB | `com.cab.drive` | без rustore |

Auth/Firebase **общий** (телефон), но установки на одном телефоне — **разные приложения**.

---

## 6. Чеклист «Влияние на флоу» (в каждый план агента)

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

## 7. Регрессия перед APK

### Автоматически (агент)

```powershell
cd cab_drive_app
powershell -File scripts/pre_apk_regression.ps1
```

Включает:
- инварианты auth (email, LoadWidget, профиль/город);
- `flutter test` (auth + role);
- `flutter analyze` (без error);
- опционально smoke API сервера.

### Ручной smoke (если есть устройство)

1. **Новый номер** — звонок → код → Load → Vibor или Geo.
2. **Существующий водитель** (телефон с iPhone) — вход → MainDriver без повторного онбординга.
3. **Профиль водителя** — «Город поиска» открывается, список городов не пустой.
4. **Home → назад** — нет FATAL MapKit / повторного выбора роли.

---

## 8. История инцидента (2026-09, APK 88)

| Симптом | Причина |
|---------|---------|
| Не создаётся аккаунт | Firebase `@ydrive.com`, API отдавал `@ydrive.appwave.com` |
| Водитель с iPhone не входит на Android | То же + пароль SQL ≠ Firebase legacy |
| Нет города | `responsiveVisibility(phone: false)` в профиле + auth не поднял сессию |

**Урок:** не сдавать APK без §7.

---

## 9. Инцидент админки / Firestore quota (2026-09)

| Симптом | Причина |
|---------|---------|
| Логин ок → 504 / nav pending | После входа шла тяжёлая статистика (полный stream `order`) при уже выжженной квоте |
| Квота 50k reads/день съедена | `check_order_status` без sleep × N workers + полные stream |
| Soft-timeout всё равно вешал страницы | `_call_timeout` + `shutdown(wait=True)` ждал зависший поток |

**Сделано:** exclusive bg lock + sleep/limit; safe stats + баннер квоты; TTL/Redis; быстрый `/d/statistics` без тяжёлых filter-lists; редирект логина на статистику.

**Урок:** опрос Firestore ≠ реакция на запись; полный stream в админке запрещён; при 429 — soft-fail без убийства worker.

---

## 10. Связанные правила

- `cab_drive_app/.cursor/rules/cab-drive-do-not-touch.mdc`
- `cab_drive_app/.cursor/rules/cab-drive-do-not-break-flows.mdc`
- `cab_drive_app/.cursor/rules/cab-drive-apk-workflow.mdc`
- `cab_drive_app/.cursor/rules/cab-drive-ios-testflight.mdc`
- `cab_drive_app/.cursor/cab_drive_ios_testflight.md`
- `cab_drive_app/.cursor/rules/cab-drive-handoff.mdc`
- `cab_drive_app/.cursor/rules/cab-drive-address-search.mdc`
- `cab_drive_app/.cursor/rules/cab-drive-no-placeholder-secrets.mdc`
- `cab_drive_app/.cursor/rules/cab-drive-release-build.mdc`