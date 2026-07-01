/// Ключи Яндекса — только через `--dart-define` или `local.properties` (Android).
///
/// Пример запуска:
/// ```
/// flutter run \
///   --dart-define=YANDEX_MAPKIT_KEY=your-mapkit-key \
///   --dart-define=YANDEX_ROUTER_KEY=your-router-key
/// ```
///
/// Android (альтернатива): `yandex.maps.api.key=...` в `android/local.properties`.
class YandexConfig {
  YandexConfig._();

  static const String mapkitKey = String.fromEnvironment('YANDEX_MAPKIT_KEY');

  static const String routerKey = String.fromEnvironment('YANDEX_ROUTER_KEY');

  static const String geocoderKey =
      String.fromEnvironment('YANDEX_GEOCODER_KEY');

  static String get effectiveRouterKey {
    if (routerKey.isNotEmpty) {
      return routerKey;
    }
    return geocoderKey;
  }

  static bool get hasMapkitKey => mapkitKey.isNotEmpty;

  static bool get hasRouterKey => effectiveRouterKey.isNotEmpty;
}
