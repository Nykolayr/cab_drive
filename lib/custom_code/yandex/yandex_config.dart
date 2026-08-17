import '/core/config/app_env.dart';

/// Ключи Yandex — из `.env` (см. `.env.example`).
class YandexConfig {
  YandexConfig._();

  static String get mapkitKey => AppEnv.get('YANDEX_MAPKIT_KEY');

  static String get geocoderKey => AppEnv.get('YANDEX_GEOCODER_KEY');

  static bool get hasMapkitKey => mapkitKey.isNotEmpty;

  static bool get hasGeocoderKey =>
      geocoderKey.isNotEmpty || mapkitKey.isNotEmpty;
}
