import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReviewsRecord extends FirestoreRecord {
  ReviewsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_who_was_reviewed" field.
  DocumentReference? _userWhoWasReviewed;
  DocumentReference? get userWhoWasReviewed => _userWhoWasReviewed;
  bool hasUserWhoWasReviewed() => _userWhoWasReviewed != null;

  // "user_who_wrote_the_review" field.
  DocumentReference? _userWhoWroteTheReview;
  DocumentReference? get userWhoWroteTheReview => _userWhoWroteTheReview;
  bool hasUserWhoWroteTheReview() => _userWhoWroteTheReview != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  // "rating" field.
  int? _rating;
  int get rating => _rating ?? 0;
  bool hasRating() => _rating != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "name_user_who_wrote" field.
  String? _nameUserWhoWrote;
  String get nameUserWhoWrote => _nameUserWhoWrote ?? '';
  bool hasNameUserWhoWrote() => _nameUserWhoWrote != null;

  void _initializeFields() {
    _userWhoWasReviewed =
        snapshotData['user_who_was_reviewed'] as DocumentReference?;
    _userWhoWroteTheReview =
        snapshotData['user_who_wrote_the_review'] as DocumentReference?;
    _text = snapshotData['text'] as String?;
    _rating = castToType<int>(snapshotData['rating']);
    _date = snapshotData['date'] as DateTime?;
    _nameUserWhoWrote = snapshotData['name_user_who_wrote'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('reviews');

  static Stream<ReviewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ReviewsRecord.fromSnapshot(s));

  static Future<ReviewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ReviewsRecord.fromSnapshot(s));

  static ReviewsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ReviewsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ReviewsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ReviewsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ReviewsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ReviewsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createReviewsRecordData({
  DocumentReference? userWhoWasReviewed,
  DocumentReference? userWhoWroteTheReview,
  String? text,
  int? rating,
  DateTime? date,
  String? nameUserWhoWrote,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_who_was_reviewed': userWhoWasReviewed,
      'user_who_wrote_the_review': userWhoWroteTheReview,
      'text': text,
      'rating': rating,
      'date': date,
      'name_user_who_wrote': nameUserWhoWrote,
    }.withoutNulls,
  );

  return firestoreData;
}

class ReviewsRecordDocumentEquality implements Equality<ReviewsRecord> {
  const ReviewsRecordDocumentEquality();

  @override
  bool equals(ReviewsRecord? e1, ReviewsRecord? e2) {
    return e1?.userWhoWasReviewed == e2?.userWhoWasReviewed &&
        e1?.userWhoWroteTheReview == e2?.userWhoWroteTheReview &&
        e1?.text == e2?.text &&
        e1?.rating == e2?.rating &&
        e1?.date == e2?.date &&
        e1?.nameUserWhoWrote == e2?.nameUserWhoWrote;
  }

  @override
  int hash(ReviewsRecord? e) => const ListEquality().hash([
        e?.userWhoWasReviewed,
        e?.userWhoWroteTheReview,
        e?.text,
        e?.rating,
        e?.date,
        e?.nameUserWhoWrote
      ]);

  @override
  bool isValidKey(Object? o) => o is ReviewsRecord;
}
