# Cab Drive — работа с секретами

## Запрещено

- Подставлять / оставлять / коммитить значения вида `your-*`, `xxx`, `changeme`, `TODO`, `placeholder`, пустые ключи.
- Собирать release APK/AAB/IPA, если в `.env` / `local.properties` / `Info.plist` placeholder или пусто.
- Писать «sync_env OK», не проверив, что значение **не** placeholder.

## МП (`cab_drive_app/.env`)

Шаблон: `cab_drive_app/.env.example`

```bash
IS_TEST=false
QUICK_DRIVER_LOGIN=false
YANDEX_MAPKIT_KEY=...
YANDEX_GEOCODER_KEY=...
YANDEX_SUGGEST_KEY=...
ORS_API_KEY=...
```

`.env` — gitignored.

### Синхронизация в нативные файлы

```powershell
cd cab_drive_app
dart run tool/sync_env.dart
```

Это пишет:
- `YANDEX_MAPKIT_KEY` → `android/local.properties` (`yandex.maps.api.key`)
- `YANDEX_MAPKIT_KEY` → `ios/Runner/Info.plist` (`YandexMapsAPIKey`)

**В git:** `local.properties` gitignored; `Info.plist` должен содержать placeholder `your-yandex-mapkit-key`.

## Сервер (`server/config.py`)

Шаблон: `server/config.example.py`

```python
class Production:
    SQLALCHEMY_DATABASE_URI = "postgresql://..."
    ZVONOK_API_KEY = '...'
    REDIS_PASSWORD = '...'
    MAPS_TOKEN = '...'
    YANDEX_SUGGEST = '...'
    TWO_GIS_KEY = '...'
    YOOKASSA_SHOP_ID = '...'
    YOOKASSA_TOKEN = '...'
    TINKOFF_TERMINAL_KEY = '...'
    TINKOFF_PASSWORD = '...'
    TINKOFF_PROD_TERMINAL_KEY = '...'
    TINKOFF_PROD_PASSWORD = '...'
    JUMP_CLIENT_KEY = '...'
    SMS_TOKEN = 'Bearer ...'
    GOOGLE_API_KEY = '...'
```

`config.py` — gitignored.

## Android подпись

- `android/key.properties` — gitignored.
- `key.jks` / keystore — gitignored.
- Один keystore для **Play и RuStore**.
- `CAB_DRIVE_RUSTORE=true` переключает `applicationId` на `com.appwawe.YDrive`.

## Firebase

- `google-services.json` (Android) и `GoogleService-Info.plist` (iOS) — в репо, но без секретных ключей API.
- `projectId`: `ydrive-a35d2`

## Проверка перед сборкой

- [ ] `.env` существует и не копия example с `your-*`.
- [ ] `android/local.properties` → `yandex.maps.api.key` не placeholder.
- [ ] `ios/Runner/Info.plist` → `YandexMapsAPIKey` placeholder в git, но реальный ключ локально после `sync_env`.
- [ ] `server/config.py` заполнен.
- [ ] `android/key.properties` и keystore на месте.

## Если ключей нет

**Стоп.** Не собирать стор. Сказать пользователю: нужны ключи из старой папки / кабинета Яндекса. Не выдумывать и не подставлять example.
