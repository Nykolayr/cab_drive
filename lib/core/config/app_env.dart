import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Ключи из `.env` в корне проекта (не в git). См. `.env.example`.
class AppEnv {
  AppEnv._();

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AppEnv: .env not loaded ($e). Copy .env.example → .env');
      }
    }
    _loaded = true;
  }

  static String get(String key, {String defaultValue = ''}) {
    final fromDotenv = dotenv.maybeGet(key);
    if (fromDotenv != null && fromDotenv.trim().isNotEmpty) {
      return fromDotenv.trim();
    }
    final fromDefine = String.fromEnvironment(key, defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return defaultValue;
  }

  static bool has(String key) => get(key).isNotEmpty;
}
