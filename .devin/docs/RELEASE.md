# Cab Drive — релизный процесс (Android / iOS)

## Общие принципы

- APK/AAB/IPA — **только по явной просьбе** пользователя.
- После обычного фикса — `flutter run` / `flutter test`, не сборка стора.
- Commit/push кода ≠ разрешение на релиз.

### Что отдаём

| Ситуация | Артефакт |
|----------|----------|
| «для заказчика» / APK на проверку | **только RuStore APK** (`com.appwawe.YDrive`) в `D:\Temp` |
| «в сторы» / релиз | **весь набор**: RuStore APK + Play AAB (и iOS, если просят) |

Заказчику AAB не нужен — не собирать лишнего.

## Android

### Версии

Формат в `pubspec.yaml`:

```yaml
version: 1.1.{N}+{N}
```

**patch и buildNumber всегда одинаковые.**  
Пример: `1.1.87+87` → следующий `1.1.88+88`.

### Пакеты по сторам

| Артефакт | Стор | `applicationId` | Команда |
|----------|------|-----------------|---------|
| AAB | Google Play | `com.cab.drive` | `flutter build appbundle --release` |
| APK | RuStore | `com.appwawe.YDrive` | `$env:CAB_DRIVE_RUSTORE='true'; flutter build apk --release` |

### Полный релиз (RuStore APK + Play AAB)

```powershell
cd cab_drive_app
powershell -File scripts/pre_apk_regression.ps1
# bump version 1.1.{N}+{N}
powershell -File scripts/release_android.ps1
```

`release_android.ps1` делает:
- gate ключей (не `your-*`)
- `dart run tool/sync_env.dart`
- `gradlew --stop`
- APK (RuStore) + AAB (Play) **по очереди**
- `aapt dump badging` для APK
- копирование в `D:\Temp`

### Вручную (RuStore APK)

```powershell
cd cab_drive_app
powershell -File scripts/pre_apk_regression.ps1  # exit 0
# bump version
dart run tool/sync_env.dart
$env:CAB_DRIVE_RUSTORE='true'
flutter build apk --release
aapt dump badging build\app\outputs\flutter-apk\app-release.apk | findstr package
Copy-Item build\app\outputs\flutter-apk\app-release.apk D:\Temp\cabdrive_{build}_rustore.apk
$env:CAB_DRIVE_RUSTORE=''
```

### Вручную (Google Play AAB)

```powershell
cd cab_drive_app
powershell -File scripts/pre_apk_regression.ps1  # exit 0
# bump version
$env:CAB_DRIVE_RUSTORE=''
dart run tool/sync_env.dart
flutter build appbundle --release
Copy-Item build\app\outputs\bundle\release\app-release.aab D:\Temp\cabdrive_{build}.aab
```

### Надёжная сборка

- До `flutter build`: gate ключей → `sync_env` → `gradlew --stop`.
- **Не** гонять холостой `flutter build` перед `--stop`.
- APK и AAB — **по очереди**, не параллельно.
- `flutter clean` — только при lock/OOM/битом cache.
- Симптом `l8DexDesugarLibRelease` / файл занят → `gradlew --stop`, удалить `build/app/intermediates/desugar_lib_dex` (или `dex/`), повторить **один** раз.
- `CAB_DRIVE_RUSTORE` — **env-переменная** (читается в `build.gradle` через `System.getenv`), НЕ `--dart-define`. С `--dart-define` сборка тихо идёт с `com.cab.drive` — всегда сверять `aapt dump badging`.

---

## iOS / TestFlight

### Когда

Только по явной просьбе: «TestFlight», «Archive», «Xcode».

### Требования

- Flutter ≥ 3.47
- Xcode 26+
- iOS min **15.0**
- **UIScene** обязателен (`SceneDelegate`, `UIApplicationSceneManifest`)
- `yandex_mapkit` через CocoaPods, **без SPM**
- `ENV['YANDEX_MAPKIT_VARIANT'] = 'full'` в `ios/Podfile`

### Подготовка

```bash
cd cab_drive_app
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

dart run tool/sync_env.dart
flutter pub get
cd ios && pod install
cd ..
flutter build ios --release --no-codesign
```

Перед коммитом: вернуть placeholder MapKit key в `ios/Runner/Info.plist`.

### Xcode

1. `open -a Xcode ios/Runner.xcworkspace` (**не** `.xcodeproj`)
2. Signing & Capabilities → правильный Team (не менять в git без просьбы)
3. Destination → Any iOS Device (arm64)
4. Product → Archive
5. Organizer → Distribute App → App Store Connect → Upload
6. App Store Connect → TestFlight → обработка → группа тестеров

### Bundle

- Bundle ID: `com.appwawe.YDrive`
- Version: `1.1.{N}+{N}` из `pubspec.yaml`

---

## Что проверить перед сдачей

- [ ] `pre_apk_regression.ps1` exit 0 (Android) / `flutter build ios --release --no-codesign` ок (iOS).
- [ ] Версия bump'нута корректно.
- [ ] RuStore package = `com.appwawe.YDrive`, Play = `com.cab.drive`.
- [ ] Файлы в `D:\Temp` с нужным именем.
- [ ] Git commit/push — только если пользователь просил.
