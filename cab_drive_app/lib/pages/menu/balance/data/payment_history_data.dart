import 'package:cab_drive/auth/firebase_auth/auth_util.dart';
import 'package:cab_drive/backend/api/app_me_api.dart';
import 'package:cab_drive/backend/api/order_record_mapper.dart';
import 'package:cab_drive/backend/schema/enums/enums.dart';

import '../../../../backend/schema/order_record.dart';

class PaymentHistoryData {
  Future<List<OrderRecord>> fetchUserOrders(
      DateTime startDate, DateTime endDate) async {
    // completed быстро уходит в hidden (auto-hide) — берём оба статуса.
    final completed = await AppMeApi.ordersMine(
      role: 'driver',
      status: 'completed',
      limit: 200,
    );
    final hidden = await AppMeApi.ordersMine(
      role: 'driver',
      status: 'hidden',
      limit: 200,
    );

    final seen = <String>{};
    final out = <OrderRecord>[];
    for (final m in [...completed, ...hidden]) {
      final id = m['id']?.toString() ?? '';
      if (id.isEmpty || !seen.add(id)) continue;
      final rec = OrderRecordMapper.fromApi(m, id);
      if (!_isHistoryRow(rec)) continue;

      final when = _historyDate(rec);
      if (when == null) continue;
      if (when.isBefore(startDate) || !when.isBefore(endDate)) continue;

      final me = currentUserUid;
      final driverId = rec.selectedDriver?.id;
      if (me != null && driverId != null && driverId != me) continue;
      out.add(rec);
    }
    return out;
  }

  bool _isHistoryRow(OrderRecord rec) {
    if (rec.status == StatusOrder.completed) return true;
    if (rec.status == StatusOrder.hidden) {
      // авто-архив после completed; иначе (cancel→hidden) не в «заработано»
      final prev = rec.statusDoHidden;
      return prev == null || prev == StatusOrder.completed;
    }
    return false;
  }

  /// Месяц — по факту завершения (date_upd), иначе create.
  DateTime? _historyDate(OrderRecord rec) {
    return rec.dateUpd ?? rec.dateTimeCreated;
  }
}
