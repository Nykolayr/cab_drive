import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/backend.dart';
import '/flutter_flow/lat_lng.dart';

/// Маппинг JSON из Postgres API → OrderRecord / ResponsesRecord для UI.
class OrderRecordMapper {
  OrderRecordMapper._();

  static String _uid(String pathOrId) {
    final i = pathOrId.lastIndexOf('/');
    return i >= 0 ? pathOrId.substring(i + 1) : pathOrId;
  }

  static DocumentReference? userRef(dynamic v) {
    if (v == null) return null;
    if (v is DocumentReference) return v;
    if (v is String && v.isNotEmpty) {
      return UsersRecord.collection.doc(_uid(v));
    }
    if (v is Map) {
      final ref = v['_ref']?.toString();
      if (ref != null && ref.isNotEmpty) {
        return UsersRecord.collection.doc(_uid(ref));
      }
    }
    return null;
  }

  static DateTime? dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    if (v is num) {
      final n = v.toDouble();
      // секунды vs миллисекунды
      final ms = n > 1e12 ? n.toInt() : (n * 1000).toInt();
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
    }
    return DateTime.tryParse(v.toString());
  }

  static LatLng? latLng(dynamic v) {
    if (v == null) return null;
    if (v is LatLng) return v;
    if (v is GeoPoint) return LatLng(v.latitude, v.longitude);
    if (v is Map) {
      final geo = v['_geo'];
      if (geo is Map) {
        final lat = geo['lat'] ?? geo['latitude'];
        final lng = geo['lng'] ?? geo['longitude'];
        if (lat is num && lng is num) {
          return LatLng(lat.toDouble(), lng.toDouble());
        }
      }
      final lat = v['latitude'] ?? v['lat'];
      final lng = v['longitude'] ?? v['lng'];
      if (lat is num && lng is num) {
        return LatLng(lat.toDouble(), lng.toDouble());
      }
    }
    if (v is List && v.length >= 2 && v[0] is num && v[1] is num) {
      return LatLng((v[0] as num).toDouble(), (v[1] as num).toDouble());
    }
    return null;
  }

  static Map<String, dynamic>? point(dynamic v) {
    if (v == null) return null;
    if (v is! Map) return null;
    final m = Map<String, dynamic>.from(v);
    final ll = latLng(m['latlng']);
    if (ll != null) m['latlng'] = ll;
    return m;
  }

  static List<DocumentReference> userRefs(dynamic v) {
    if (v is! List) return const [];
    return v.map(userRef).whereType<DocumentReference>().toList();
  }

  static OrderRecord fromApi(Map<String, dynamic> m, String id) {
    final data = Map<String, dynamic>.from(m);
    data['selected_driver'] = userRef(m['selected_driver']);
    data['user_customer'] = userRef(m['user_customer']);
    data['dateTime'] = dt(m['dateTime']);
    data['dateTime_created'] = dt(m['dateTime_created']);
    data['date_upd'] = dt(m['date_upd']);
    data['completion_date_by_the_driver'] =
        dt(m['completion_date_by_the_driver']);
    data['driver_location'] = latLng(m['driver_location']);
    data['user_who_responced'] = userRefs(m['user_who_responced']);
    final pa = point(m['pointA']);
    final pb = point(m['pointB']);
    final pc = point(m['pointC']);
    if (pa != null) data['pointA'] = pa;
    if (pb != null) data['pointB'] = pb;
    if (pc != null) data['pointC'] = pc;
    // убрать служебные ключи API
    data.remove('_source');
    data.remove('selected_driver_id');
    data.remove('user_customer_id');
    return OrderRecord.getDocumentFromData(
      data,
      OrderRecord.collection.doc(id),
    );
  }

  /// Контакт точки: не показывать «,» при пустых phone/name.
  static String senderContactLine(SenderStruct sender) {
    final phone = sender.phone.trim();
    final name = sender.name.trim();
    if ((phone.isEmpty || phone == ',' || phone == ' ') && name.isEmpty) {
      return '—';
    }
    if (phone.isEmpty || phone == ',' || phone == ' ') return name;
    if (name.isEmpty) return phone;
    return '$phone, $name';
  }

  /// Ожидаемая стоимость: raised currentPrice, иначе budget.
  static String expectedPriceText(OrderRecord order) {
    final cp = order.currentPrice;
    final value = cp > 0 ? cp : order.budget;
    return '${value.toString()} ₽';
  }

  static ResponsesRecord bidFromApi(Map<String, dynamic> m, String orderId) {
    final id = m['id']?.toString() ?? '';
    final driver = userRef(m['user_driver'] ?? m['driver_id']);
    final data = <String, dynamic>{
      'user_driver': driver,
      'viewed': m['viewed'] == true,
      'text': m['text']?.toString() ?? '',
      'price': m['price'],
      'date_created': dt(m['date_created']),
      'time': m['time']?.toString() ?? '',
      'distance': m['distance']?.toString() ?? '',
    };
    return ResponsesRecord.getDocumentFromData(
      data,
      ResponsesRecord.createDoc(
        OrderRecord.collection.doc(orderId),
        id: id.isEmpty ? null : id,
      ),
    );
  }
}
