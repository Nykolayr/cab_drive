import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '/core/config/test_flags.dart';

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

  static bool _boolFromEnv(String key, bool fallback) {
    final raw = get(key).toLowerCase();
    if (raw == 'true' || raw == '1') return true;
    if (raw == 'false' || raw == '0') return false;
    return fallback;
  }

  /// Debug-only: водитель + мок-заказ. Release всегда `false`.
  /// `.env`: `IS_TEST=true`
  static bool get isTest {
    if (kReleaseMode) return false;
    return _boolFromEnv('IS_TEST', TestFlags.isTest);
  }

  /// Debug-only: сразу MainDriver после логина (без мок-заказа).
  /// Release всегда `false`. `.env`: `QUICK_DRIVER_LOGIN=true`
  static bool get quickDriverLogin {
    if (kReleaseMode) return false;
    return _boolFromEnv('QUICK_DRIVER_LOGIN', TestFlags.quickDriverLogin);
  }
}
