---
name: debug-install
description: >-
  Сборка debug APK cab_drive и установка на телефон по USB (adb) для проверки
  пользователем. Использовать когда просят «поставь дебаг на телефон»,
  «запусти чтобы проверил».
---

# Debug-установка на телефон

## Устройство

- Телефон: `97c277d3` (23124RA7EO, Android 15)
- Пакет debug: `com.cab.drive` (без `CAB_DRIVE_RUSTORE`!)
- adb: `C:\Users\nykolay\AppData\Local\Android\Sdk\platform-tools\adb.exe`

## Шаги

```powershell
cd cab_drive_app
dart run tool/sync_env.dart
flutter build apk --debug            # applicationId=com.cab.drive
adb -s 97c277d3 install -r build\app\outputs\flutter-apk\app-debug.apk
adb -s 97c277d3 shell monkey -p com.cab.drive -c android.intent.category.LAUNCHER 1
adb -s 97c277d3 shell pidof com.cab.drive   # подтверждение запуска
```

## Правила

- Ставим **поверх** (`-r`), данные сохраняются. Не удалять приложение без
  просьбы — слетит авторизация у пользователя.
- `flutter run` / `flutter attach` — **только в видимом терминале
  пользователя**, не из скрытого shell агента.
- RuStore-релиз (`com.appwawe.YDrive`) с debug-пакетом не конфликтует —
  удалять ничего не нужно.
- Если `install` падает по подписи — стоп, сообщить пользователю.
- После установки дать пользователю чек-лист по формату
  `agent-qa-checks` (где/шаги/ожидание/провал).
