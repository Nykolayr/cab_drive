/// Тексты ошибок T‑Банка для пользователя (по ErrorCode / статусу).
class PaymentBankError {
  PaymentBankError._();

  static const supportHint =
      'Если не поможет — напишите в «Чат с поддержкой».';

  /// Сообщение по коду банка и режиму терминала (test/prod).
  static String message({
    String? errorCode,
    String? status,
    String? bankMessage,
    String? mode,
  }) {
    final code = (errorCode ?? '').trim();
    final st = (status ?? '').toUpperCase();
    final isTest = (mode ?? '').toLowerCase() == 'test';

    if (code == '1042' || code == '1051') {
      if (isTest) {
        return 'Банк отклонил оплату (код $code).\n\n'
            'Сейчас включён тестовый терминал — обычные карты не проходят. '
            'Нужна тестовая карта T‑Банка или переключение на боевой терминал.\n\n'
            '$supportHint';
      }
      return 'Банк отклонил оплату (код $code). '
          'Проверьте карту или попробуйте другую.\n\n$supportHint';
    }

    if (st == 'REJECTED' || st == 'CANCELED' || st == 'DEADLINE_EXPIRED') {
      final extra = code.isNotEmpty ? ' (код $code)' : '';
      if (isTest) {
        return 'Банк отклонил оплату$extra.\n\n'
            'Тестовый терминал: для проверки используйте тестовые карты T‑Банка.\n\n'
            '$supportHint';
      }
      return 'Банк отклонил оплату$extra.\n\n$supportHint';
    }

    if (bankMessage != null && bankMessage.trim().isNotEmpty) {
      return 'Не удалось оплатить: ${bankMessage.trim()}\n\n$supportHint';
    }

    return 'Не получилось оплатить.\n\n$supportHint';
  }

  static bool isFailUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('/api/tinkoff/return') && u.contains('result=fail');
  }

  static bool isSuccessUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('/api/tinkoff/return') && u.contains('result=success');
  }
}
