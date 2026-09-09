import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Маппинг JSON verifications API → RequestVereficationRecord.
class VerificationRecordMapper {
  VerificationRecordMapper._();

  static DateTime? _dt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
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

  static List<String> _strs(dynamic v) {
    if (v is! List) return const [];
    return v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  static RequestVereficationRecord fromApi(Map<String, dynamic> m) {
    final id = m['id']?.toString() ?? 'tmp';
    final statusRaw = m['status'];
    StatusVerif? status;
    if (statusRaw is StatusVerif) {
      status = statusRaw;
    } else if (statusRaw != null) {
      status = deserializeEnum<StatusVerif>(statusRaw.toString());
    }
    Car? marka;
    final markaRaw = m['marka'];
    if (markaRaw is Car) {
      marka = markaRaw;
    } else if (markaRaw != null) {
      marka = deserializeEnum<Car>(markaRaw.toString());
    }
    final data = <String, dynamic>{
      'email': m['email']?.toString() ?? '',
      'phone_number': m['phone_number']?.toString() ?? '',
      'city': m['city']?.toString() ?? '',
      'name': m['name']?.toString() ?? '',
      'surname': m['surname']?.toString() ?? '',
      'dfb': _dt(m['dfb']),
      'dateCreated': _dt(m['dateCreated'] ?? m['date_created']),
      'number_id': m['number_id'],
      'number_avto': m['number_avto']?.toString() ?? '',
      'marka': marka,
      'avatar': m['avatar']?.toString() ?? '',
      'photo_doc': _strs(m['photo_doc']),
      'photo_avto': _strs(m['photo_avto']),
      'user': _userRef(m['user'] ?? m['user_id']),
      'status': status,
      'commission_percent': m['commission_percent'],
    };
    return RequestVereficationRecord.getDocumentFromData(
      data,
      RequestVereficationRecord.collection.doc(id),
    );
  }
}
