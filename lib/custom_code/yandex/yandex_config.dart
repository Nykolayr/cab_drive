/// Ключ Yandex MapKit — `--dart-define` или `android/local.properties`.
///
/// ```
/// flutter run \
///   --dart-define=YANDEX_MAPKIT_KEY=your-mapkit-key \
///   --dart-define=ORS_API_KEY=your-ors-key
/// ```
///
/// Android: `yandex.maps.api.key=...` в `android/local.properties`.
/// iOS: `YandexMapsAPIKey` в `ios/Runner/Info.plist` (локально).
class YandexConfig {
  YandexConfig._();

  static const String mapkitKey = String.fromEnvironment('YANDEX_MAPKIT_KEY');

  static const String geocoderKey =
      String.fromEnvironment('YANDEX_GEOCODER_KEY');

  static bool get hasMapkitKey => mapkitKey.isNotEmpty;
}
