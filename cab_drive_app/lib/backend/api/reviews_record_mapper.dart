import '/backend/backend.dart';

/// Маппинг JSON reviews API → ReviewsRecord.
class ReviewsRecordMapper {
  ReviewsRecordMapper._();

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

  static ReviewsRecord fromApi(Map<String, dynamic> m) {
    final id = m['id']?.toString() ?? '';
    final reviewed = _userRef(
      m['user_who_was_reviewed'] ?? m['reviewed_user_id'],
    );
    final author = _userRef(
      m['user_who_wrote_the_review'] ?? m['author_user_id'],
    );
    final data = <String, dynamic>{
      'user_who_was_reviewed': reviewed,
      'user_who_wrote_the_review': author,
      'text': m['text']?.toString() ?? '',
      'rating': m['rating'],
      'date': _dt(m['date'] ?? m['date_created']),
      'name_user_who_wrote':
          m['name_user_who_wrote']?.toString() ?? m['name_author']?.toString(),
    };
    return ReviewsRecord.getDocumentFromData(
      data,
      ReviewsRecord.collection.doc(id.isEmpty ? 'tmp' : id),
    );
  }
}
