import 'package:flutter_test/flutter_test.dart';
import 'package:cab_drive/backend/schema/enums/enums.dart';
import 'package:cab_drive/order_status_groups.dart';

/// Регрессия «статус-сирот»: каждый StatusOrder обязан быть виден
/// хотя бы на одной вкладке «Мои заказы» у соответствующей роли,
/// либо явно исключён (driverTabHiddenStatuses).
/// Поймал бы баг: cancelled не был виден водителю нигде.
void main() {
  group('Order status tab coverage', () {
    test('driver: every status is in a tab or explicitly hidden', () {
      final covered = <StatusOrder>{
        ...driverActiveStatuses,
        ...driverBidsStatuses,
        ...driverArchiveStatuses,
        ...driverTabHiddenStatuses,
      };
      expect(
        covered,
        containsAll(StatusOrder.values),
        reason:
            'Новый статус StatusOrder забыт во вкладках водителя — '
            'заказ "исчезнет". Добавь в нужный набор '
            'в lib/order_status_groups.dart',
      );
    });

    test('customer: every status is in a tab', () {
      final covered = <StatusOrder>{
        ...customerActiveStatuses,
        ...customerArchiveStatuses,
      };
      expect(
        covered,
        containsAll(StatusOrder.values),
        reason:
            'Новый статус StatusOrder забыт во вкладках клиента — '
            'заказ "исчезнет". Добавь в lib/order_status_groups.dart',
      );
    });

    test('no status is both driver-active and driver-archive', () {
      expect(
        driverActiveStatuses.intersection(driverArchiveStatuses),
        isEmpty,
      );
      expect(
        driverActiveStatuses.intersection(driverBidsStatuses),
        isEmpty,
      );
      expect(
        driverBidsStatuses.intersection(driverArchiveStatuses),
        isEmpty,
      );
    });

    test('no status is both customer-active and customer-archive', () {
      expect(
        customerActiveStatuses.intersection(customerArchiveStatuses),
        isEmpty,
      );
    });
  });

  group('Customer cancel availability', () {
    test('cancel allowed only on pre-completion statuses', () {
      // Синхрон с серверным гардом cancel_order_by_customer:
      // он блокирует completed, cancelled, hidden, on_confirmation.
      for (final s in StatusOrder.values) {
        final serverBlocked = s == StatusOrder.completed ||
            s == StatusOrder.cancelled ||
            s == StatusOrder.hidden ||
            s == StatusOrder.on_confirmation;
        expect(
          customerCancellableStatuses.contains(s),
          isNot(serverBlocked),
          reason:
              'Статус $s: расхождение клиент/сервер по доступности отмены',
        );
      }
    });

    test('cancel menu not shown on on_confirmation (driver completed)', () {
      expect(
        customerCancellableStatuses.contains(StatusOrder.on_confirmation),
        isFalse,
        reason:
            'После «водитель завершил» отмена запрещена — '
            'регресс бага «клиент отменил, водитель без оплаты»',
      );
    });
  });
}
