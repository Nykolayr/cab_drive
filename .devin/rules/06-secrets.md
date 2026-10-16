# Секреты и `.env` — жёсткий запрет плейсхолдеров

## Запрещено

- Подставлять / оставлять / коммитить значения вида `your-*`, `xxx`, `changeme`, `TODO`, `placeholder`, пустые ключи для:
  - `YANDEX_MAPKIT_KEY`, `YANDEX_GEOCODER_KEY`, `YANDEX_SUGGEST_KEY`, `ORS_API_KEY`
  - любых других API/Firebase/подписи, которые нужны приложению в runtime или release-сборке.
- Копировать только `.env.example` в `.env` и считать это «готово».
- Собирать **release APK/AAB/IPA** или делать handoff в стор, если в `.env` / `local.properties` / `Info.plist` ещё плейсхолдер или пусто.
- Писать в чат, что «sync_env OK», не проверив, что значение **не** placeholder.

## Где живут секреты

| Секрет | Файл | Примечание |
|--------|------|------------|
| MapKit/Geocoder/ORS/тест-флаги | `cab_drive_app/.env` | gitignored, шаблон `.env.example` |
| Android MapKit key | `android/local.properties` → `yandex.maps.api.key` | генерируется `tool/sync_env.dart` |
| iOS MapKit key | `ios/Runner/Info.plist` | генерируется `sync_env`, в git placeholder |
| Бэкенд DB/API/провайдеры | `server/config.py` | шаблон `config.example.py`, gitignored |
| Подпись Android | `android/key.properties`, `key.jks` | gitignored |
| Firebase | `google-services.json`, `GoogleService-Info.plist` | в репо, но без секретных ключей |

## Обязательно при переносе/настройке

1. Найти **старый** `.env` и **скопировать живые ключи** в новый.
2. Перенести связанные секреты: `android/key.properties`, keystore (путь), `google-services.json`.
3. Запустить `dart run tool/sync_env.dart`.
4. Проверить **до сборки**: MapKit/Geocoder/ORS = реальные значения, не `your-*`.
5. Только после этого — `flutter run` / release APK/AAB.

## Перед любой release-сборкой (чек)

- [ ] `.env` существует и **не** копия example с `your-`.
- [ ] `android/local.properties` → `yandex.maps.api.key` не `your-yandex-mapkit-key`.
- [ ] При сомнении: сравнить с `cab_drive_old/.env` или известным рабочим источником ключей.

## Если ключей нет

**Стоп.** Не собирать стор. Сказать пользователю: нужны ключи из старой папки / кабинета Яндекса. Не выдумывать и не подставлять example.
