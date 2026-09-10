/// Утилиты для российского телефона: маска `+7 (___) ___-__-__`.
class RuPhone {
  RuPhone._();

  static const String maskHint = '+7 (___) ___-__-__';
  static const String inputMask = '+7 (###) ###-##-##';

  /// Цифры в виде `7XXXXXXXXXX` (11) или пусто.
  static String digits11(String? raw) {
    var d = (raw ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (d.isEmpty) return '';
    if (d.startsWith('8') && d.length == 11) {
      d = '7${d.substring(1)}';
    }
    if (d.length == 10) {
      d = '7$d';
    }
    if (d.length > 11) {
      d = d.substring(0, 11);
    }
    if (!d.startsWith('7')) {
      // уже набрали без кода — дополним при 10 цифрах выше
      if (d.length <= 10) {
        d = '7$d';
        if (d.length > 11) d = d.substring(0, 11);
      }
    }
    return d;
  }

  /// Маска для поля ввода. Неполный номер тоже форматируется по мере ввода.
  static String mask(String? raw) {
    final d = digits11(raw);
    if (d.isEmpty) return '';
    final n = d.startsWith('7') ? d.substring(1) : d;
    final b = StringBuffer('+7');
    if (n.isEmpty) return b.toString();
    b.write(' (');
    b.write(n.substring(0, n.length.clamp(0, 3)));
    if (n.length <= 3) return b.toString();
    b.write(') ');
    b.write(n.substring(3, n.length.clamp(3, 6)));
    if (n.length <= 6) return b.toString();
    b.write('-');
    b.write(n.substring(6, n.length.clamp(6, 8)));
    if (n.length <= 8) return b.toString();
    b.write('-');
    b.write(n.substring(8, n.length.clamp(8, 10)));
    return b.toString();
  }

  static bool isComplete(String? raw) {
    final d = digits11(raw);
    return d.length == 11 && d.startsWith('7');
  }

  /// Для сохранения в заказе / sender (как `phone_number` в профиле — 10 цифр).
  static String forStorage(String? raw) {
    final d = digits11(raw);
    if (d.length == 11 && d.startsWith('7')) return d.substring(1);
    return d;
  }
}
