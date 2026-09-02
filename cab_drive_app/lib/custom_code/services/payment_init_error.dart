import 'dart:async';
import 'dart:convert';

import '/backend/api_requests/api_manager.dart';

/// User-facing copy when Init Payment / recurrent init fails.
class PaymentInitError {
  PaymentInitError._();

  static const supportHint =
      'Напишите в «Чат с поддержкой» в меню приложения.';

  static String messageFromCall(ApiCallResponse? response) {
    if (response?.exception is TimeoutException ||
        (response?.exceptionMessage.toLowerCase().contains('timeout') ??
            false)) {
      return 'Платёжный сервис не ответил вовремя. Проверьте интернет и попробуйте снова. Если не поможет — $supportHint';
    }
    final details = _detailsBlob(response);
    if (_looksLikeCertificate(details)) {
      return 'Ошибка сертификата платёжного сервиса. $supportHint';
    }
    if (details.trim().isNotEmpty) {
      return 'Не удалось открыть оплату. $supportHint';
    }
    return 'Не удалось открыть оплату. Проверьте интернет и попробуйте снова. Если не поможет — $supportHint';
  }

  static bool _looksLikeCertificate(String blob) {
    final s = blob.toLowerCase();
    return s.contains('certificate') ||
        s.contains('self-signed') ||
        s.contains('сертификат');
  }

  static String _detailsBlob(ApiCallResponse? response) {
    if (response == null) return '';
    if (response.exception != null) {
      return '${response.exceptionMessage} ${response.statusCode}';
    }
    final body = response.jsonBody;
    if (body is Map) {
      final error = body['error']?.toString() ?? '';
      final details = body['details']?.toString() ?? '';
      final message = body['Message']?.toString() ?? '';
      return '$error $details $message ${response.statusCode}';
    }
    if (body is String) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          final error = decoded['error']?.toString() ?? '';
          final details = decoded['details']?.toString() ?? '';
          return '$error $details ${response.statusCode}';
        }
      } catch (_) {
        return '$body ${response.statusCode}';
      }
      return '$body ${response.statusCode}';
    }
    return '${response.statusCode}';
  }
}
