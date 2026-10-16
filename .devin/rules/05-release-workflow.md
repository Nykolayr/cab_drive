# Релизный workflow (Android APK/AAB)

## Жёсткий запрет

- **Не** собирать `apk` / `appbundle` / копировать в `D:\Temp` / предлагать «отдай заказчику», пока пользователь **явно** не попросил.
- После фикса бага / фичи — **сначала** `flutter run` (или что попросил проверить), APK не делать сам.
- Commit/push кода ≠ разрешение на APK. APK — отдельная явная команда.

## Пакеты по сторам

| Артефакт | Стор | `applicationId` | Как собрать |
|----------|------|-----------------|-------------|
| **AAB** | Google Play | `com.cab.drive` | `flutter build appbundle --release` (без rustore-флага) |
| **APK** | RuStore | `com.appwawe.YDrive` | `$env:CAB_DRIVE_RUSTORE='true'; flutter build apk --release` |

- «Сделай апк» / «для рустор» → **всегда** `CAB_DRIVE_RUSTORE=true`, проверить badging = `com.appwawe.YDrive`.
- «Сделай aab» / Play → **всегда** `com.cab.drive`, env rustore **сбросить**.

## Версии в `pubspec.yaml`

Формат: `1.1.{N}+{N}` — **patch и buildNumber всегда одинаковые**.

- Не делать `1.1.2+87` / `1.1.88+87`.
- При bump увеличивать **оба** числа на 1: `1.1.{N+1}+{N+1}`.

## Полный релиз (RuStore APK + Play AAB)

0. **`powershell -File cab_drive_app/scripts/pre_apk_regression.ps1`** — exit 0.
1. Bump `1.1.{N}+{N}` (если не «без bump»).
2. **`powershell -File cab_drive_app/scripts/release_android.ps1`** — gate ключей, sync_env, gradle stop, APK+AAB, копии в `D:\Temp`.
3. Git commit/push — только если просил.

## Сборка вручную (RuStore APK)

0. `powershell -File scripts/pre_apk_regression.ps1` — exit 0.
1. Поднять версию по схеме `1.1.{N}+{N}` (если не «без bump»).
2. `dart run tool/sync_env.dart`
3. `$env:CAB_DRIVE_RUSTORE='true'; flutter build apk --release`
4. Проверить `aapt dump badging` → `package: name='com.appwawe.YDrive'`.
5. Скопировать в `D:\Temp\cabdrive_{buildNumber}_rustore.apk`.
6. Сбросить `$env:CAB_DRIVE_RUSTORE`.

## Сборка вручную (Google Play AAB)

0. `powershell -File scripts/pre_apk_regression.ps1` — exit 0.
1. Bump по схеме.
2. `dart run tool/sync_env.dart`.
3. Убедиться, что `CAB_DRIVE_RUSTORE` не задан.
4. `flutter build appbundle --release`.
5. Копировать в `D:\Temp\cabdrive_{N}.aab`.

## Правила надёжной сборки

- До `flutter build`: gate ключей (не `your-*`) → `sync_env` → `gradlew --stop` → при необходимости снести `build/app/intermediates/desugar_lib_dex`.
- **Запрещено** перед `--stop` гонять холостой `flutter build`.
- APK и AAB — **строго по очереди**, не параллельно.
- `flutter clean` — только после lock/OOM/битого cache.

## Секреты

- Один `.env` в корне `cab_drive_app` (шаблон `.env.example`).
- RuStore и Play — **один и тот же** upload-keystore.
- Сборка без `.env` на машине — запрещена.

## Запрещено

- APK «на всякий случай» после правок без запроса.
- Грузить в RuStore APK с `com.cab.drive` или в Play AAB с `com.appwawe.YDrive`.
- Пропускать bump / push / копирование в `D:\Temp`, когда пользователь заказал полный сценарий.
