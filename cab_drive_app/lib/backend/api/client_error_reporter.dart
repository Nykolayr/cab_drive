import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '/backend/api_requests/payments_api_config.dart';
import '/core/utils/shared_prefs.dart';

/// Отправка клиентских ошибок на `POST /api/app/client-errors` (шаблон digitalsquare).
///
/// Не блокирует UI; rate-limit + fingerprint. Ошибки репорта глотаются.
final class ClientErrorReporter {
  ClientErrorReporter._();

  static ClientErrorReporter? instance;

  static const int _maxPerHour = 40;
  static const int _maxCrumbsPerHour = 300;
  static const Duration _dedupeWindow = Duration(seconds: 90);

  static const String _pendingStepKey = 'crumb_pending_step';

  final List<DateTime> _sentAt = [];
  final List<DateTime> _crumbSentAt = [];
  final Map<String, DateTime> _recentFingerprints = {};

  /// Версия из pubspec — обновлять вместе с `version:` (без package_info_plus).
  static const String appVersion = '1.1.107';
  static const String buildNumber = '107';

  static void install() {
    instance = ClientErrorReporter._();
  }

  /// Breadcrumb: шаг пользовательского флоу (гео, верификация, фото).
  /// Без дедупа, свой лимит — нужен полный след для диагностики.
  void crumb(String tag, String message) {
    if (kIsWeb) return;
    final now = DateTime.now();
    _crumbSentAt
        .removeWhere((t) => now.difference(t) > const Duration(hours: 1));
    if (_crumbSentAt.length >= _maxCrumbsPerHour) return;
    _crumbSentAt.add(now);
    unawaited(
      _send(message: message, tag: 'crumb:$tag', fatal: false),
    );
  }

  /// Ставит персистентный маркер перед рискованным шагом (камера/пикер).
  /// Если приложение убьёт ОС — на следующем старте маркер останется.
  static Future<void> markPendingStep(String step) async {
    try {
      await SharedPrefs.sharedPreferences.setString(_pendingStepKey, step);
    } catch (_) {}
  }

  /// Вызывается на старте: если маркер остался — приложение убили на этом шаге.
  static Future<void> reportPendingStepIfAny() async {
    try {
      final step = SharedPrefs.sharedPreferences.getString(_pendingStepKey);
      if (step == null || step.isEmpty) return;
      await SharedPrefs.sharedPreferences.remove(_pendingStepKey);
      await instance?._send(
        message: 'process_died_during:$step',
        tag: 'crumb:process_death',
        fatal: false,
      );
    } catch (_) {}
  }

  static Future<void> clearPendingStep() async {
    try {
      await SharedPrefs.sharedPreferences.remove(_pendingStepKey);
    } catch (_) {}
  }

  Future<void> report({
    required String message,
    String? tag,
    String? stack,
    bool fatal = false,
  }) async {
    if (kIsWeb) return;
    final cleaned = _sanitize(message);
    if (cleaned.isEmpty) return;

    final fp = '${tag ?? ''}|${cleaned._take(200)}|${(stack ?? '')._take(300)}';
    final now = DateTime.now();
    final last = _recentFingerprints[fp];
    if (last != null && now.difference(last) < _dedupeWindow) return;
    _recentFingerprints[fp] = now;
    _recentFingerprints.removeWhere(
      (_, t) => now.difference(t) > const Duration(minutes: 10),
    );

    _sentAt.removeWhere((t) => now.difference(t) > const Duration(hours: 1));
    if (_sentAt.length >= _maxPerHour) return;
    _sentAt.add(now);

    await _send(
      message: cleaned._take(1024),
      tag: tag != null && tag.trim().isNotEmpty ? tag.trim()._take(64) : null,
      stack: stack,
      fatal: fatal,
    );
  }

  /// Голая отправка без лимита/дедупа — для крошек со своим лимитом.
  Future<void> _send({
    required String message,
    String? tag,
    String? stack,
    bool fatal = false,
  }) async {
    final cleaned = _sanitize(message);
    if (cleaned.isEmpty) return;
    try {
      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
              ? 'ios'
              : Platform.operatingSystem;

      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      try {
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {}

      final uri = Uri.parse(PaymentsApiConfig.path('/api/app/client-errors'));
      await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(<String, dynamic>{
              'message': cleaned._take(1024),
              if (stack != null && stack.trim().isNotEmpty)
                'stack': stack.trim()._take(16000),
              if (tag != null && tag.trim().isNotEmpty)
                'tag': tag.trim()._take(64),
              'platform': platform,
              'appVersion': appVersion,
              'buildNumber': buildNumber,
              'fatal': fatal,
              'deviceInfo':
                  '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'
                      ._take(256),
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Молча: репорт не должен ронять приложение и не логировать в цикл.
    }
  }
}

extension on String {
  String _take(int max) => length <= max ? this : substring(0, max);
}

String _sanitize(String raw) {
  var s = raw.trim();
  s = s.replaceAll(
    RegExp(r'(Bearer\s+)[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
    r'$1***',
  );
  s = s.replaceAll(
    RegExp(r'(password["\s:=]+)[^\s,;"]+', caseSensitive: false),
    r'$1***',
  );
  return s;
}
