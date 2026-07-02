import '/core/config/app_env.dart';

/// OpenRouteService — ключ из `.env` (см. `.env.example`).
class RouteConfig {
  RouteConfig._();

  static String get orsApiKey => AppEnv.get('ORS_API_KEY');

  static bool get hasOrsApiKey => orsApiKey.isNotEmpty;
}
