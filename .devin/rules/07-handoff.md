# Cab Drive: сдача задачи (handoff)

## Запрещено писать пользователю

- «Должно работать» / «перезапусти и проверь» **без** своей проверки в этом же turn.

## Обязательно перед «готово"

1. **`scripts/verify_handoff.ps1`** — агент запускает сам (`powershell -File scripts/verify_handoff.ps1`).
2. Если менялись **карты / плагины / нативка** — чеклист:
   - `pubspec.yaml` — `yandex_mapkit` есть, `google_maps_flutter` **нет**.
   - `android/app/build.gradle` — `maps.mobile` ≥ 4.11 (сейчас `4.22.0-full`), `BuildConfig.YANDEX_MAPS_API_KEY`, `minSdk 26`.
   - `MainActivity.kt` — кэш engine / `shouldDestroyEngineWithHost=false`.
   - `CabDriveApplication.kt` — `FlutterEngineCache` + `MapKitFactory.setApiKey` **до** engine.
   - `ios/Runner/AppDelegate.swift` — UIScene: `FlutterImplicitEngineDelegate`; `YMKMapKit.setApiKey` **до** `super.application`; плагины в `didInitializeImplicitFlutterEngine`.
   - `ios/Runner/SceneDelegate.swift` + `UIApplicationSceneManifest` в `Info.plist`.
   - `lib/main.dart` — `AndroidYandexMap.useAndroidViewSurface` на Android.
   - `grep` по `google_maps_flutter` / `FlutterFlowGoogleMap` в экранах заказа — не должно остаться.
3. Если пользователь прислал **лог** — сначала строка с **первым `E/` / `Exception` / `AssertionError`**, потом правки.
4. Критический путь: **логин → load → mainDriver/mainUser** — при сомнении `AppLog.trace` с `tag: 'Auth'` / `'Nav'`.

## Карты (только Yandex MapKit)

| Слой | Технология |
|------|------------|
| Подложка | `yandex_mapkit` + нативный ключ |
| Маршрут | OpenRouteService (`ORS_API_KEY`) |
| Геокодер/подсказки | Yandex Geocoder API (`YANDEX_GEOCODER_KEY`) |
| Виджеты | `YandexOrderMap`, `YandexPickerMap` |

## Пользователь не тестер

Сначала `verify_handoff` + analyze/build; ручной прогон — только если нет устройства.

## Связь

- `.devin/rules/10-address-search.md` — выбор адреса.
- `.devin/rules/05-release-workflow.md` — сборки.
