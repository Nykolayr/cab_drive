import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/backend.dart';
import '/flutter_flow/lat_lng.dart';

/// Маппинг JSON GET /api/app/me → UsersRecord для session UI.
class UsersRecordMapper {
  UsersRecordMapper._();

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    if (v is num) {
      final n = v.toDouble();
      final ms = n > 1e12 ? n.toInt() : (n * 1000).toInt();
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
    }
    return DateTime.tryParse(v.toString());
  }

  static LatLng? _latLng(dynamic lat, dynamic lng) {
    if (lat is num && lng is num) {
      return LatLng(lat.toDouble(), lng.toDouble());
    }
    return null;
  }

  static List<DocumentReference> _orderRefs(dynamic v) {
    if (v is! List) return const [];
    final out = <DocumentReference>[];
    for (final x in v) {
      if (x is DocumentReference) {
        out.add(x);
        continue;
      }
      final s = x?.toString() ?? '';
      if (s.isEmpty) continue;
      final id = s.contains('/') ? s.split('/').last : s;
      out.add(OrderRecord.collection.doc(id));
    }
    return out;
  }

  static DocumentReference? _chatRef(dynamic idOrRef) {
    if (idOrRef == null) return null;
    if (idOrRef is DocumentReference) return idOrRef;
    final s = idOrRef.toString();
    if (s.isEmpty) return null;
    final id = s.contains('/') ? s.split('/').last : s;
    return ChatsRecord.collection.doc(id);
  }

  /// [previous] — прошлый документ между /me poll (addresses/car/current_order).
  static UsersRecord fromMeApi(
    Map<String, dynamic> m, {
    UsersRecord? previous,
  }) {
    final id = (m['id'] ?? m['uid'] ?? previous?.uid ?? '').toString();
    final ref = UsersRecord.collection.doc(id.isEmpty ? '_' : id);
    final prev = previous?.snapshotData ?? const <String, dynamic>{};

    final data = Map<String, dynamic>.from(prev);

    void put(String key, dynamic value, {bool overwriteNull = false}) {
      if (value == null && !overwriteNull) return;
      data[key] = value;
    }

    put('uid', id);
    put('email', m['email']);
    put('display_name', m['display_name'] ?? m['displayName']);
    put('photo_url', m['photo_url'] ?? m['photoUrl']);
    put('phone_number', m['phone_number'] ?? m['phoneNumber']);
    put('login_complete', m['login_complete'] ?? m['loginComplete']);
    put('is_driver', m['is_driver'] ?? m['isDriver']);
    put('admin', m['admin']);
    put('surname', m['surname']);
    put('city', m['city']);
    put('region', m['region']);
    put('email_user', m['email_user'] ?? m['emailUser']);
    put('verif_compl', m['verif_compl'] ?? m['verifCompl']);
    put('verif_ne_proidena', m['verif_ne_proidena']);
    put('on_verif_now', m['on_verif_now']);
    put('verif_id', m['verif_id'] ?? m['verifId']);
    put('is_blocked', m['is_blocked'] ?? m['isBlocked']);
    put('balance', m['balance']);
    put('bonus_balance', m['bonus_balance'] ?? m['bonusBalance']);
    put(
      'commission_percent',
      m['commission_percent'] ?? m['commission'],
    );
    put('current_commision', m['current_commision'] ?? m['currentCommision']);
    put('on_shift', m['on_shift'] ?? m['onShift']);
    put('fine', m['fine']);
    put('average_rating', m['average_rating']);
    put('number_of_reviews', m['number_of_reviews']);
    put('additional_phone_number', m['additional_phone_number']);
    put('created_time', _dt(m['created_time'] ?? m['createdTime']));
    put('dfb', _dt(m['dfb']));
    put('shift_start_date_time', _dt(m['shift_start_date_time']));
    put('shift_completion_date_time', _dt(m['shift_completion_date_time']));
    put('last_online', _dt(m['last_online']));

    final cityLl = _latLng(m['city_lat'], m['city_lng']);
    if (cityLl != null) put('cityLatlng', cityLl);

    final queue = _orderRefs(m['active_orders_queue'] ?? m['activeOrdersQueue']);
    if (queue.isNotEmpty || m.containsKey('active_orders_queue')) {
      data['active_orders_queue'] = queue;
    }

    final chat = _chatRef(m['chat_with_support_id'] ?? m['chat_with_support']);
    if (chat != null) put('chat_with_support', chat);

    final addresses = m['addresses'];
    if (m.containsKey('addresses')) {
      data['addresses'] = addresses is List ? addresses : const [];
    }
    final car = m['car'];
    if (m.containsKey('car')) {
      if (car is Map) {
        data['car'] = Map<String, dynamic>.from(car);
      } else {
        data.remove('car');
      }
    }
    final currentOrder = m['current_order'] ?? m['currentOrder'];
    if (m.containsKey('current_order') || m.containsKey('currentOrder')) {
      if (currentOrder is Map && currentOrder.isNotEmpty) {
        data['current_order'] = Map<String, dynamic>.from(currentOrder);
      } else {
        data.remove('current_order');
      }
    }

    data.remove('_source');
    return UsersRecord.getDocumentFromData(data, ref);
  }
}
