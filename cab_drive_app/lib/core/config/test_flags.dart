/// Тестовые флаги по умолчанию (если в `.env` не задано).
///
/// В **release** `AppEnv.isTest` / `AppEnv.quickDriverLogin` всегда `false`.
class TestFlags {
  /// Debug: водитель + мок-заказ на карте. Переопределяется `IS_TEST` в `.env`.
  static const bool isTest = false;

  /// Debug: сразу экран водителя после логина (без мок-заказа).
  /// Переопределяется `QUICK_DRIVER_LOGIN` в `.env`.
  static const bool quickDriverLogin = false;
}
