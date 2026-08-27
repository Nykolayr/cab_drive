# Cab Drive (monorepo)

Единый репозиторий приложения и бэкенда.

```text
cab_drive_app/   Flutter-клиент (Android / iOS)
server/          Flask API + админка (с VPS, без venv/storage/логов)
```

## Локально

- Старый каталог `cab_drive/` — **бэкап**, в git не входит (см. корневой `.gitignore`).
- Секреты: `cab_drive_app/.env`, `server/.env` — **не коммитить**.
- Подпись Android: `key.jks` / `key.properties` только на машине.

## Flutter

```powershell
cd cab_drive_app
# положить .env рядом с pubspec (из .env.example)
dart run tool/sync_env.dart
flutter pub get
flutter run
```

## Server

Код с прод-VPS без `venv`, `storage/`, `logs/`. Для запуска — свой venv + конфиг/секреты.

## GitHub

Remote: `mine` → `https://github.com/Nykolayr/cab_drive.git`
