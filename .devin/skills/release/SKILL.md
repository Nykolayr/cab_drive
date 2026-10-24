---
name: release
description: >-
  Сборка релизного Android APK/AAB для cab_drive (RuStore APK / Play AAB) с
  regression-gate, bump версии и копированием в D:\Temp. Использовать когда
  просят «APK заказчику», «билд в сторы», «релиз».
---

# Релиз cab_drive (Android)

Канон процесса: `.devin/docs/RELEASE.md` — сверять с ним перед сборкой.

## Что отдаём

- «для заказчика» → **только RuStore APK** (`com.appwawe.YDrive`)
- «в сторы» → RuStore APK + Play AAB (`com.cab.drive`)

## Версия

`pubspec.yaml`: `version: 1.1.{N}+{N}` — patch == buildNumber, оба +1.

## Шаги (PowerShell)

```powershell
cd cab_drive_app
powershell -File scripts/pre_apk_regression.ps1   # обязателен exit 0
# bump version в pubspec.yaml
dart run tool/sync_env.dart
cd android; ./gradlew --stop; cd ..
```

RuStore APK (**env-переменная, НЕ --dart-define**):

```powershell
$env:CAB_DRIVE_RUSTORE='true'
flutter build apk --release
aapt dump badging build\app\outputs\flutter-apk\app-release.apk | findstr package
# ждём: com.appwawe.YDrive — иначе билд мимо
Copy-Item build\app\outputs\flutter-apk\app-release.apk D:\Temp\cabdrive_{N}_rustore.apk
$env:CAB_DRIVE_RUSTORE=''
```

Play AAB (env rustore СБРОШЕН):

```powershell
flutter build appbundle --release
Copy-Item build\app\outputs\bundle\release\app-release.aab D:\Temp\cabdrive_{N}.aab
```

## Ловушки

- `CAB_DRIVE_RUSTORE` через `--dart-define` не работает — тихо соберётся
  `com.cab.drive`. Всегда проверять `aapt dump badging`.
- `mergeDexRelease` / файл занят → `gradlew --stop`, удалить
  `build/app/intermediates/dex`, повторить один раз.
- APK и AAB — по очереди, не параллельно.
- Build только по явной просьбе; commit/push отдельным разрешением.
