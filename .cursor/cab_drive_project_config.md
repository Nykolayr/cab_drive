# Cab Drive — конфигурация проекта (справочник для агента)

> Обновлено по состоянию репозитория. Проект **не** из шаблона digitalsquare — это **FlutterFlow + Firebase**.
> В чате: `@.cursor/cab_drive_project_config.md`

---

## 1. Идентификация

| Параметр | Значение |
|----------|----------|
| Имя пакета (`pubspec.yaml` → `name`) | `cab_drive` |
| Импорты | `package:cab_drive/...` |
| Отображаемое имя | Cab Drive |
| Версия | `1.0.5+13` (`pubspec.yaml`) |
| Dart SDK | `>=3.0.0 <4.0.0` |
| Android `applicationId` | `com.appwawe.YDrive` |
| Android namespace | `com.appwawe.YDrive` |
| Исходный бренд / Firebase | **YDrive** (`ydrive-a35d2`) |

---

## 2. Стек (фактический)

| Область | Технология |
|---------|------------|
| Генератор UI | **FlutterFlow** (экспорт в код) |
| State (глобальный) | **Provider** + `FFAppState` (`ChangeNotifier`) |
| State (экран) | `FlutterFlowModel<T>` на каждый экран (`*_model.dart`) |
| Навигация | **go_router** (`lib/flutter_flow/nav/nav.dart`) |
| Бэкенд данных | **Cloud Firestore** (прямые запросы из UI) |
| Auth | **Firebase Auth** (телефон, email, Google, Apple, GitHub, anonymous, JWT) |
| Push | **FCM** + Cloud Functions |
| REST | **`package:http`** через `ApiManager` (не Dio) |
| Локальное хранение | `flutter_secure_storage` (через `FFAppState`) |
| Карты | `google_maps_flutter`, custom widgets |
| Локализация | `FFLocalizations`, только **`ru`** |
| Remote Config | Firebase Remote Config (`poll`, `usl` — PDF-ссылки) |

**Не использовать без явного запроса:** BLoC, GetIt, Clean Architecture из digitalsquare — в проекте их нет.

---

## 3. Точка входа и bootstrap

**Файл:** `lib/main.dart`

Порядок запуска:

1. `initFirebase()` — `lib/backend/firebase/firebase_config.dart`
2. `FFAppState().initializePersistedState()` — secure storage
3. `initializeFirebaseRemoteConfig()` — `lib/flutter_flow/firebase_remote_config_util.dart`
4. `ChangeNotifierProvider` → `MyApp`
5. `createRouter(AppStateNotifier)` — GoRouter
6. Стрим `cabDriveFirebaseUserStream()` → обновление `AppStateNotifier`
7. Подписки: auth stream, FCM token stream

**Стартовый маршрут:** `/` → если залогинен `LoadWidget`, иначе `OnbordWidget`.

**Роутинг после логина** (`lib/login/load/load_widget.dart`):

- `admin == true` → `/verifAdmin`
- `loginComplete && isDriver` → `/mainDriver` (+ опционально `toggleRouteTracking`)
- `loginComplete && !isDriver` → `/mainUser`
- иначе → `/geo` (дозаполнение профиля)

---

## 4. Структура `lib/`

```text
lib/
├── main.dart                 # entry
├── index.dart                # re-export экранов для роутера
├── app_state.dart            # FFAppState (глобальное состояние)
│
├── flutter_flow/             # инфраструктура FlutterFlow
│   ├── nav/nav.dart          # GoRouter, AppStateNotifier, FFRoute
│   ├── flutter_flow_theme.dart
│   ├── flutter_flow_widgets.dart   # FFButtonWidget и др.
│   ├── flutter_flow_util.dart
│   ├── flutter_flow_model.dart     # базовый класс *_model
│   └── ...
│
├── auth/                     # Firebase Auth
│   └── firebase_auth/
│
├── backend/
│   ├── backend.dart          # query-хелперы Firestore
│   ├── firebase/firebase_config.dart
│   ├── schema/               # Firestore records + structs + enums
│   ├── api_requests/         # ApiManager + api_calls (REST)
│   ├── cloud_functions/
│   ├── push_notifications/
│   └── firebase_storage/
│
├── login/                    # онбординг, OTP, верификация
├── customer/                 # UI заказчика
├── driver/                   # UI водителя
├── admin/                    # UI админа
├── chat/                     # чаты
├── pages/                    # общие: заказы, меню, профиль, navbar
├── custom_code/
│   ├── actions/              # кастомные action (Dart)
│   └── widgets/              # кастомные виджеты (карты и т.д.)
│
└── components/               # переиспользуемые FF-компоненты (если есть)
```

**Паттерн экрана:** `feature/feature_widget.dart` + `feature_model.dart`.

---

## 5. Роли пользователей

Enum `Role` в `lib/backend/schema/enums/enums.dart`: `driver`, `user`, `admin`.

Флаги в `users` (Firestore): `is_driver`, `admin`, `login_complete`, `verif_compl`, `on_verif_now`.

`FFAppState.driver` — локальный флаг режима (persist `ff_driver`).

---

## 6. Навигация (основные маршруты)

Конфигурация: `lib/flutter_flow/nav/nav.dart`.  
У каждого экрана: `static routeName`, `static routePath`.

| Path | Экран | Роль |
|------|-------|------|
| `/` | splash / redirect | все |
| `/onbord` | онбординг | гость |
| `/login`, `/otp`, `/otpLogin` | вход | гость |
| `/geo`, `/vibor` | гео / выбор роли | регистрация |
| `/verifUser`, `/verifDriver` | верификация | user/driver |
| `/load` | пост-логин роутер | auth |
| `/mainUser` | главная заказчика | customer |
| `/mainDriver` | главная водителя | driver |
| `/detaliySozdanie` | создание заказа | customer |
| `/orderPageCustomer` | детали заказа (клиент) | customer |
| `/orderPageDriver` | детали заказа (водитель) | driver |
| `/myOrders` | мои заказы | оба |
| `/chats`, `/chat` | чаты | оба |
| `/profile`, `/nastroiki` | профиль, настройки | оба |
| `/verifAdmin`, `/chatAdmin`, `/profilAdmin`, `/detaliZayavkiAdmin` | админка | admin |

Переходы: `context.pushNamed`, `context.goNamed` (extensions из `flutter_flow_util.dart`).

---

## 7. Firebase

### Проект

| Параметр | Значение |
|----------|----------|
| `projectId` | `ydrive-a35d2` |
| `storageBucket` | `ydrive-a35d2.firebasestorage.app` |
| `messagingSenderId` | `1070996805603` |

**Конфиг клиента:**

- Web: явные `FirebaseOptions` в `lib/backend/firebase/firebase_config.dart`
- Android/iOS: `google-services.json` / `GoogleService-Info.plist` (стандартный FF-путь)

**Правила и индексы:** `firebase/firestore.rules`, `firebase/firestore.indexes.json`, `firebase/storage.rules`

### Firestore — коллекции

| Коллекция | Record-класс | Назначение |
|-----------|--------------|------------|
| `users` | `UsersRecord` | профили, роли, баланс, рейтинг |
| `order` | `OrderRecord` | заказы |
| `order/{id}/responses` | `ResponsesRecord` | отклики водителей (subcollection) |
| `chats` | `ChatsRecord` | чаты |
| `messages` | `MessagesRecord` | сообщения |
| `request_verefication` | `RequestVereficationRecord` | заявки на верификацию |
| `reviews` | `ReviewsRecord` | отзывы |
| `rewiews_of_the_app` | `RewiewsOfTheAppRecord` | отзывы о приложении |
| `pay_order` | `PayOrderRecord` | платежи по заказам |
| `users/{id}/saved_cards` | `SavedCardsRecord` | сохранённые карты (subcollection) |
| `ff_push_notifications` | — | очередь push (FF) |
| `ff_user_push_notifications` | — | user push (FF) |
| `users/{id}/fcm_tokens` | — | FCM токены |

Query-хелперы: `lib/backend/backend.dart` (`queryUsersRecord`, `queryOrderRecord`, …).

### Structs (вложенные объекты)

`lib/backend/schema/structs/`: `PointStruct`, `CardStruct`, `FiltersStruct`, `CarStruct`, `CurrentOrderStruct`, `SenderStruct`.

### Enums

`lib/backend/schema/enums/enums.dart`:

- `StatusOrder`: newOrder, completed, hidden, cancelled, spec_set, at_work, on_confirmation
- `StatusVerif`: onVerif, Completed, otklonena
- `Car`: largusTermo, largus, fiat
- `PayMethod`: card, cahs
- `PaymentType`: regular, initRecurrent, chargeRecurrent, regularCustomer

---

## 8. REST API

**Клиент:** `lib/backend/api_requests/api_manager.dart` (`http` package, singleton `ApiManager.instance`).

**Описание вызовов:** `lib/backend/api_requests/api_calls.dart` — классы `*Call` со статическим `call()`.

| Класс | Сервис | Назначение |
|-------|--------|------------|
| `ApSmsCall` | `a2p-sms-api.mcn.ru` | SMS / OTP |
| `AutocompleteCall` | Google Places Autocomplete | поиск адреса |
| `GeocodeLatLngCall`, `GeocodePlaceIDCall` | Google Geocoding | координаты ↔ адрес |
| `DistanceMatrixCall` | Google Distance Matrix | расстояние/время |
| `InitPaymentCall` | Cloud Run `init-payment-*.run.app` | инициализация оплаты |
| `InitRecurrentPaymentCall` | Cloud Run `init-recurrent-payment-*` | рекуррент |
| `ChargeRecurrentPaymentCall` | Cloud Run `charge-recurrent-payment-*` | списание |
| `PrepareRecurrentPaymentCall` | Cloud Run `prepare-recurrent-payment-*` | подготовка рекуррента |
| `GetCardListCall` | Cloud Run `getcardlist-*` | список карт |
| `CreateClientAndPayoutCall` | Jump.finance API | выплата + создание контрагента |
| `PayoutCall` | Jump.finance API | выплата водителю |

**Секреты захардкожены в `api_calls.dart`** (Google API key, SMS token, Jump Client-Key) — при рефакторинге выносить в env / Remote Config / backend proxy.

**Дополнительно:** `lib/custom_code/` — прямой `http` для Google Directions (маршруты на карте).

**Private API FlutterFlow:** константа `ffPrivateApiCall` в `api_calls.dart`, но `firebase/functions/api_manager.js` — `callMap` пустой (не используется).

---

## 9. Cloud Functions

**Папка:** `firebase/functions/`

| Function | Триггер | Назначение |
|----------|---------|------------|
| `addFcmToken` | HTTPS callable | сохранение FCM токена |
| `sendPushNotificationsTrigger` | Firestore onCreate `ff_push_notifications` | массовые push |
| `sendUserPushNotificationsTrigger` | onCreate `ff_user_push_notifications` | push по user_refs |
| `sendScheduledPushNotifications` | Pub/Sub каждую 1 мин | отложенные push |
| `onUserDeleted` | Auth onDelete | заготовка очистки user |

Клиент: `lib/backend/cloud_functions/cloud_functions.dart` → `makeCloudCall(name, input)`.

---

## 10. Глобальное состояние `FFAppState`

**Файл:** `lib/app_state.dart`

Persist в Secure Storage (`ff_*`):

- `phone`, `OTP`, `Password`, `driver`, `mskGeo`, `filter`, `payMethod`, `card`

In-memory (сессия заказа):

- `pointA`, `pointB`, `distanceKm`, `distanceTime`
- `priceLargus`, `priceTermo`, `priceFiat`, `movers`
- `selfi`

Доступ: `FFAppState()` (singleton) или `context.watch<FFAppState>()`.

---

## 11. Custom code (ручной Dart поверх FF)

### Actions (`lib/custom_code/actions/`)

| Файл | Назначение |
|------|------------|
| `toggle_route_tracking.dart` | трекинг маршрута водителя (http + Firestore) |
| `open_yandex_route.dart` | открыть маршрут в Яндекс |
| `open2_g_i_s_route.dart` | открыть маршрут в 2GIS |
| `users_ball.dart` | рейтинг пользователей |
| `lock_orientation.dart` | ориентация экрана |
| `close_keyboard.dart` | скрыть клавиатуру |

### Widgets (`lib/custom_code/widgets/`)

| Файл | Назначение |
|------|------------|
| `polyline_map.dart` | карта с полилинией маршрута |
| `driver_tracking_map.dart` | карта трекинга водителя |
| `phone_input_widget.dart` | ввод телефона |
| `read_message.dart` | прочитанность сообщений |

---

## 12. Платежи и выплаты (потоки)

**Заказчик (карта):** экраны `lib/customer/pay_init/`, `pay_add_card/` → `InitPaymentCall`, `InitRecurrentPaymentCall`, `GetCardListCall`.

**Водитель (выплаты):** `lib/driver/sposobviplat/`, `create_otklick/` → Jump.finance `CreateClientAndPayoutCall`, `PayoutCall`.

**Cloud Run** сервисы в проекте GCP `1070996805603` (регион `us-central1`) — прокси к платёжному провайдеру (Tinkoff-подобный API по полям ответа).

---

## 13. Android-сборка

| Файл | Что смотреть |
|------|----------------|
| `android/app/build.gradle` | `applicationId`, SDK 35, signing |
| `android/key.properties` | keystore (не в git) |
| `pubspec.yaml` | `version`, launcher icons |

**Важно:** в `build.gradle` release сейчас `signingConfig signingConfigs.debug` — перед стором переключить на release keystore.

Чеклисты релиза: `.cursor/android_release.md`, `.cursor/rustore_aab_signature.md`, `.cursor/edge_to_edge_play_checklist.md`.

---

## 14. Assets

`pubspec.yaml` → `assets/fonts/`, `images/`, `videos/`, `audios/`, `jsons/`, `pdfs/`, `rive_animations/`.

Шрифты: `SF` (Pro Display), `Ydrive2`.

---

## 15. Доменные зоны UI

| Папка | Содержание |
|-------|------------|
| `lib/customer/` | создание заказа, главная клиента, оплата, отмена |
| `lib/driver/` | лента заказов, отклики, фильтры, гео, баланс, выплаты |
| `lib/admin/` | верификация, чаты поддержки, заявки |
| `lib/chat/` | чат, список чатов, SMS-чат |
| `lib/pages/` | профиль, настройки, navbar, мои заказы |
| `lib/login/` | auth pipeline, верификация документов |

---

## 16. Правила для агента при работе с этим репо

0. **План до кода** — см. `.cursor/rules/plan-first.mdc`: вопросы → feasibility (если интеграция) → план → **утверждение** → только потом правки.
1. **Не навязывать** digitalsquare (BLoC/GetIt/Clean Architecture) — проект FlutterFlow.
2. **Новые экраны** — по паттерну `*_widget.dart` + `*_model.dart`, регистрация в `nav.dart` и `index.dart`.
3. **Данные** — в первую очередь Firestore records в `backend/schema/`, не выдумывать REST-слой.
4. **HTTP** — через `ApiManager` / новый класс в `api_calls.dart`, не подключать Dio без запроса.
5. **Секреты** — не дублировать в новые файлы; по возможности выносить с бэкенда.
6. **Правки из FlutterFlow** — при re-export из FF могут перезаписаться файлы вне `custom_code/`; кастом логику держать в `lib/custom_code/`.
7. **Анализ:** `flutter pub get`, `dart analyze` из корня проекта.

---

## 17. Связанные файлы в `.cursor/`

| Файл | Для чего |
|------|----------|
| `README.md` | правила шаблона digitalsquare (наследованы, но стек cab_drive другой) |
| `flutter_upgrade_checklist.md` | обновление Flutter/Dart |
| `android_release.md` | сборка AAB/APK |
| **этот файл** | карта cab_drive |
| `cab_drive_apk_workflow.md` | по запросу «сделай apk»: bump версии → `D:\Temp\cabdrive_{build}.apk` → push |
