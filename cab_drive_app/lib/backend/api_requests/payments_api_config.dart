import 'dart:convert';

import 'package:http/http.dart' as http;

/// Базовый URL платёжного API (без секретов).
/// Bootstrap: [defaultBaseUrl]. После [load] — значение с сервера (смена домена без стора).
class PaymentsApiConfig {
  PaymentsApiConfig._();

  /// Стабильный bootstrap-хост (HTTPS). Не убирать — с него МП читает актуальный URL.
  static const String defaultBaseUrl = 'https://cab.artean.ru';

  static String _baseUrl = defaultBaseUrl;

  static String get baseUrl => _baseUrl;

  static String path(String relative) {
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final rel = relative.startsWith('/') ? relative : '/$relative';
    return '$base$rel';
  }

  /// Тянет GET /api/tinkoff/config. Ошибки глотаем — остаётся fallback.
  static Future<void> load() async {
    try {
      final uri = Uri.parse('$defaultBaseUrl/api/tinkoff/config');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return;
      }
      final body = jsonDecode(response.body);
      if (body is! Map) return;
      final raw = body['paymentsBaseUrl'] ?? body['payments_base_url'];
      if (raw is String && raw.trim().isNotEmpty) {
        _baseUrl = raw.trim().replaceAll(RegExp(r'/+$'), '');
      }
    } catch (_) {
      // оставляем defaultBaseUrl
    }
  }
}
