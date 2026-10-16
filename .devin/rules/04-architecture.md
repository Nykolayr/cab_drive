# Архитектура Cab Drive

## Стек (фактический)

| Область | Технология |
|---------|------------|
| МП | Flutter (FlutterFlow-экспорт) |
| State | Provider + `FFAppState` (`ChangeNotifier`) + `FlutterFlowModel<T>` |
| Навигация | go_router (`lib/flutter_flow/nav/nav.dart`) |
| HTTP | `package:http` через `ApiManager` (не Dio) |
| Auth | Firebase Auth (телефон/email) |
| Пуши | FCM |
| Карты | `yandex_mapkit` + ORS + Yandex Geocoder |
| Бэкенд | Flask + Gunicorn + Nginx |
| App data | Postgres = Source of Truth |
| Admin auth | MySQL `cab` (users/FirebaseUser) |
| Файлы | свой `files/upload` + `files/get` |

## Монорепо

```text
D:\Projects\cab_drive
├── cab_drive_app/      # Flutter МП
├── server/             # Flask backend
├── docs/               # legacy docs (переносятся в .devin/docs/)
├── .cursor/            # legacy Cursor rules (оставляем)
└── .devin/             # project-конфигурация Devin
```

## Source of Truth

- **Postgres** (`app_*` таблицы) — единственный SoT для app-data.
- **Firebase** — только Auth + FCM доставка.
- **Firestore** — soft mirror, на проде выключен (`APP_FS_MIRROR=0`).
- **MySQL `cab`** — только админка, не app-data.

## Канонические справочники

- `.devin/docs/ARCHITECTURE.md` — полная архитектура.
- `.devin/docs/API_REFERENCE.md` — endpoints / WSS.
- `.devin/docs/FLOWS.md` — пользовательские флоу.
- `.devin/docs/DEPLOY.md` — деплой.
- `.devin/docs/SECRETS.md` — секреты и env.

## Правила для агента

1. Новые app-данные — **только PG**, не dual-write в FS.
2. Auth = Firebase; пароли/секреты не в git.
3. Деплой: `cab.service` + при WSS `cab-wss.service`; nginx `/ws/`.
4. Прод: `APP_FS_MIRROR=0` — не включать `1` без причины (откат).
5. Не путать MySQL `cab` и Postgres `app_*`.
6. Client errors — смотреть `app_client_errors` / admin GET при жалобах.
