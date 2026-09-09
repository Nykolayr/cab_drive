import 'package:cab_drive/auth/firebase_auth/auth_util.dart';
import 'package:cab_drive/backend/api/app_me_api.dart';
import 'package:cab_drive/backend/api/order_record_mapper.dart';

import '../../../../backend/schema/order_record.dart';

class PaymentHistoryData {
  Future<List<OrderRecord>> fetchUserOrders(
      DateTime startDate, DateTime endDate) async {
    final rows = await AppMeApi.ordersMine(
      role: 'driver',
      status: 'completed',
      limit: 200,
    );
    final out = <OrderRecord>[];
    for (final m in rows) {
      final id = m['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final rec = OrderRecordMapper.fromApi(m, id);
      final created = rec.dateTimeCreated;
      if (created == null) continue;
      if (created.isBefore(startDate) || created.isAfter(endDate)) continue;
      // только свои заказы (API mine уже фильтрует, страховка)
      final me = currentUserUid;
      final driverId = rec.selectedDriver?.id;
      if (me != null && driverId != null && driverId != me) continue;
      out.add(rec);
    }
    return out;
  }
}
