/// Ключ OpenRouteService — через `--dart-define` (не коммитить в git).
///
/// Пример (ключ как в joy_pick, передаётся локально):
/// ```
/// flutter run --dart-define=ORS_API_KEY=your-ors-key
/// ```
class RouteConfig {
  RouteConfig._();

  static const String orsApiKey = String.fromEnvironment('ORS_API_KEY');

  static bool get hasOrsApiKey => orsApiKey.isNotEmpty;
}
