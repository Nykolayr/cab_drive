# Cab Drive — iOS / Xcode / TestFlight

> Правило: `.cursor/rules/cab-drive-ios-testflight.mdc`  
> Ориентир SDK: **Flutter 3.47+**, **Xcode 26+**, мин. **iOS 15**, **UIScene** обязателен.

**Только по явной просьбе** («подготовь Xcode», «TestFlight», «Archive»). После фикса — не предлагать Upload сам.

---

## 1. Что уже должно быть в репо (Flutter 3.47)

| Файл | Содержимое |
|------|------------|
| `ios/Runner/AppDelegate.swift` | `FlutterImplicitEngineDelegate`; MapKit `setApiKey` до `super`; плагины в `didInitializeImplicitFlutterEngine` |
| `ios/Runner/SceneDelegate.swift` | `class SceneDelegate: FlutterSceneDelegate {}` |
| `ios/Runner/Info.plist` | `UIApplicationSceneManifest` → `$(PRODUCT_MODULE_NAME).SceneDelegate` |
| `ios/Podfile` | `platform :ios, '15.0.0'`, `ENV['YANDEX_MAPKIT_VARIANT'] = 'full'`, pod `YandexMapsMobile` |
| `project.pbxproj` | `IPHONEOS_DEPLOYMENT_TARGET = 15.0`, Bundle `com.appwawe.YDrive`, Team `VR8CMD6LAY` |

Если чего-то нет — **сначала** восстановить по правилу UIScene, не «просто pod install».

Канон: [UIScene adoption](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate).

---

## 2. Подготовка на Mac (агент)

```bash
cd cab_drive_app
# CocoaPods требует UTF-8:
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# .env уже с ключами (не в git)
dart run tool/sync_env.dart
flutter pub get
cd ios && pod install
cd ..
flutter build ios --release --no-codesign
```

Перед коммитом: в `Info.plist` вернуть  
`<string>your-yandex-mapkit-key</string>` (ключ остаётся локально через повторный `sync_env` перед Archive).

Открыть workspace:

```bash
open -a Xcode ios/Runner.xcworkspace
```

---

## 3. Действия в Xcode (TestFlight)

1. **Signing & Capabilities** — Runner и ImageNotification: Team = аккаунт App Store Connect (если конфликт `VR8CMD6LAY` vs другой Distribution team — выбрать правильный в UI, **не** коммитить чужой team без запроса).
2. Scheme **Runner**, Destination **Any iOS Device (arm64)**.
3. **Product → Archive**.
4. Organizer → **Distribute App** → App Store Connect → Upload.
5. [App Store Connect](https://appstoreconnect.apple.com) → приложение → TestFlight → дождаться Processing → добавить в группу тестеров.

Версия: из `pubspec.yaml` (`CFBundleShortVersionString` / `CFBundleVersion` = `1.1.{N}+{N}`).

---

## 4. CocoaPods vs SPM

Пока в зависимостях есть без SPM (`yandex_mapkit`, часть secure_storage/permissions и т.д.) — **остаёмся на CocoaPods**.  
`flutter build ios` может предупреждать про SPM — это ожидаемо, не ошибка.

Не включать SPM глобально без плана миграции MapKit.

---

## 5. Типичные ошибки

| Симптом | Что проверить |
|---------|----------------|
| `pod` Encoding::CompatibilityError | `LANG` / `LC_ALL=en_US.UTF-8` |
| FATAL MapKit / setApiKey | ключ через `sync_env`; порядок в AppDelegate |
| Нет Scene / не стартует на новых SDK | `UIApplicationSceneManifest` + `SceneDelegate` |
| Signing / provisioning | Team в Xcode vs App Store Connect; Bundle `com.appwawe.YDrive` |
| Push на TestFlight | после Upload Automatic → production APS |

---

## 6. Связано

- `cab-drive-do-not-touch.mdc` — не трогать MapKit/Engine «заодно»
- `cab-drive-handoff.mdc` — чеклист карт
- `cab-drive-apk-workflow.mdc` — Android, не iOS
- `docs/ARCHITECTURE_AND_FLOWS.md` — auth/регрессия (перед стором при правках auth)
