import '/backend/backend.dart';

/// Маппинг JSON GET /api/app/payments/:id → PayOrderRecord.
class PayOrderRecordMapper {
  PayOrderRecordMapper._();

  static DocumentReference? _orderRef(dynamic v) {
    if (v == null) return null;
    if (v is DocumentReference) return v;
    if (v is Map && v['_ref'] != null) {
      final s = v['_ref'].toString();
      final id = s.contains('/') ? s.split('/').last : s;
      return OrderRecord.collection.doc(id);
    }
    final s = v.toString();
    if (s.isEmpty) return null;
    final id = s.contains('/') ? s.split('/').last : s;
    return OrderRecord.collection.doc(id);
  }

  static DocumentReference? _userRef(dynamic v) {
    if (v == null) return null;
    if (v is DocumentReference) return v;
    if (v is Map && v['_ref'] != null) {
      final s = v['_ref'].toString();
      final id = s.contains('/') ? s.split('/').last : s;
      return UsersRecord.collection.doc(id);
    }
    final s = v.toString();
    if (s.isEmpty) return null;
    final id = s.contains('/') ? s.split('/').last : s;
    return UsersRecord.collection.doc(id);
  }

  static PayOrderRecord fromApi(Map<String, dynamic> m, String id) {
    final orderId = m['order_id']?.toString() ?? m['orderId']?.toString() ?? '';
    final currentOrder = _orderRef(
      m['current_order_doc_ref'] ?? m['current_order_id'] ?? m['currentOrderId'],
    );
    final driver = _userRef(m['driver'] ?? m['driver_id']);
    final user = _userRef(m['user'] ?? m['user_id']);
    final paymentTypeRaw = m['paymentType'] ?? m['payment_type'];
    final data = <String, dynamic>{
      'order_id': orderId,
      'amount_in_cop': m['amount_in_cop'] ?? m['amountInCop'],
      'user': user,
      'is_paid': m['is_paid'] == true || m['isPaid'] == true,
      'paymentId': m['paymentId'] ?? m['payment_id'],
      'current_order_doc_ref': currentOrder,
      'driver': driver,
      'tinkoff_status': m['tinkoff_status'] ?? m['tinkoffStatus'],
      'tinkoff_error_code': m['tinkoff_error_code'] ?? m['tinkoffErrorCode'],
      'tinkoff_message': m['tinkoff_message'] ?? m['tinkoffMessage'],
      'summ_upd_ballance': m['summ_upd_ballance'] ?? m['summUpdBallance'],
      if (paymentTypeRaw != null) 'paymentType': paymentTypeRaw,
    };
    data.removeWhere((k, v) => v == null && k != 'is_paid');
    return PayOrderRecord.getDocumentFromData(
      data,
      PayOrderRecord.collection.doc(id),
    );
  }

  static bool isPaid(Map<String, dynamic> m) =>
      m['is_paid'] == true || m['isPaid'] == true;

  static const failStatuses = {
    'REJECTED',
    'CANCELED',
    'DEADLINE_EXPIRED',
    'AUTH_FAIL',
    'REVERSED',
  };

  static String tinkoffStatus(Map<String, dynamic> m) =>
      (m['tinkoff_status'] ?? m['tinkoffStatus'] ?? '').toString().toUpperCase();
}
