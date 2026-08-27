import 'dart:async';

/// Глобальный in-memory dedup для доставки доп.заказов водителю.
///
/// FCM-обработчик и Firestore-листенер пишут сюда `order_id` чтобы не показать
/// один и тот же bottom sheet дважды. Запись имеет TTL — после истечения id
/// удаляется, что позволяет повторно открыть sheet, если заказ ещё актуален
/// (например, был отклонён первым водителем и снова прилетел нам).
class ExtraOrdersDedup {
  ExtraOrdersDedup._();

  /// TTL для записей. По умолчанию 5 минут (синхронизировано с backend cooldown).
  static Duration ttl = const Duration(minutes: 5);

  static final Map<String, Timer> _seen = {};

  /// Пытается зарезервировать показ для `orderId`.
  /// Возвращает true, если это первый показ; false — если уже отображали.
  static bool tryAdd(String orderId) {
    if (orderId.isEmpty) return false;
    if (_seen.containsKey(orderId)) {
      print('[ExtraOrdersDedup] skip duplicate order_id=$orderId size=${_seen.length}');
      return false;
    }
    _seen[orderId] = Timer(ttl, () {
      _seen.remove(orderId);
      print('[ExtraOrdersDedup] expired order_id=$orderId size=${_seen.length}');
    });
    print('[ExtraOrdersDedup] add order_id=$orderId size=${_seen.length}');
    return true;
  }

  /// Явно сбрасывает запись (например, если показ упал с ошибкой и хочется
  /// дать второй шанс).
  static void forget(String orderId) {
    final t = _seen.remove(orderId);
    t?.cancel();
    print('[ExtraOrdersDedup] forget order_id=$orderId size=${_seen.length}');
  }

  /// Полный сброс — пригодится при logout/смене водителя.
  static void clearAll() {
    for (final t in _seen.values) {
      t.cancel();
    }
    _seen.clear();
    print('[ExtraOrdersDedup] clearAll');
  }
}
