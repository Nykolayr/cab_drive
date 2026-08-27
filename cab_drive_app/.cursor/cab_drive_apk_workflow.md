# Cab Drive — сборка APK по запросу «сделай апк»

> Правило: `.cursor/rules/cab-drive-apk-workflow.mdc`

**APK/AAB только по явной просьбе.** После фикса — сначала проверка через `flutter run`. Не собирать релиз «на всякий случай» и не предлагать отдавать заказчику без команды пользователя.

## Первый раз на машине

```powershell
copy .env.example .env
# ключи уже могут быть в .env — иначе заполни
dart run tool/sync_env.dart
flutter pub get
```

Дальше **`flutter run` / `flutter build apk` / `flutter build appbundle`** — **без** `--dart-define`.

Ключи лежат в **`.env`** (не в git). Android/iOS MapKit подхватываются через `sync_env` (автоматически при `pod install` на iOS; Gradle читает `.env` напрямую на Android).

## Пакеты

| Стор | Артефакт | applicationId | Команда |
|------|----------|---------------|---------|
| RuStore | APK | `com.appwawe.YDrive` | `$env:CAB_DRIVE_RUSTORE='true'; flutter build apk --release` |
| Google Play | AAB | `com.cab.drive` | `flutter build appbundle --release` |

## Когда пользователь пишет «сделай апк» (RuStore)

1. **Поднять версию** в `pubspec.yaml` (`+build` на 1), если не сказал «без bump».
2. **`dart run tool/sync_env.dart`** (если меняли `.env`).
3. **`$env:CAB_DRIVE_RUSTORE='true'; flutter build apk --release`**
4. Проверить package = `com.appwawe.YDrive` (`aapt dump badging`)
5. **Скопировать** в `D:\Temp\cabdrive_{build}_rustore.apk`
6. Сбросить `$env:CAB_DRIVE_RUSTORE`
7. **Git:** commit + push — если просил в том же запросе / полном сценарии.

## Когда пользователь пишет «сделай aab» (Play)

1. Bump (если не «без bump»).
2. `dart run tool/sync_env.dart`
3. `flutter build appbundle --release` (без `-Prustore`)
4. Копировать в `D:\Temp\cabdrive_{build}.aab`

## iOS (Mac)

```bash
cp .env.example .env   # один раз
dart run tool/sync_env.dart
flutter build ios --release
```

`pod install` сам вызывает `sync_env`, если есть `.env`.
