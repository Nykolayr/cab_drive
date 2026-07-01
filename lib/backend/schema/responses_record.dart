import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ResponsesRecord extends FirestoreRecord {
  ResponsesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_driver" field.
  DocumentReference? _userDriver;
  DocumentReference? get userDriver => _userDriver;
  bool hasUserDriver() => _userDriver != null;

  // "viewed" field.
  bool? _viewed;
  bool get viewed => _viewed ?? false;
  bool hasViewed() => _viewed != null;

  // "text" field.
  String? _text;
  String get text => _text ?? '';
  bool hasText() => _text != null;

  // "price" field.
  int? _price;
  int get price => _price ?? 0;
  bool hasPrice() => _price != null;

  // "date_created" field.
  DateTime? _dateCreated;
  DateTime? get dateCreated => _dateCreated;
  bool hasDateCreated() => _dateCreated != null;

  // "time" field.
  String? _time;
  String get time => _time ?? '';
  bool hasTime() => _time != null;

  // "distance" field.
  String? _distance;
  String get distance => _distance ?? '';
  bool hasDistance() => _distance != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userDriver = snapshotData['user_driver'] as DocumentReference?;
    _viewed = snapshotData['viewed'] as bool?;
    _text = snapshotData['text'] as String?;
    _price = castToType<int>(snapshotData['price']);
    _dateCreated = snapshotData['date_created'] as DateTime?;
    _time = snapshotData['time'] as String?;
    _distance = snapshotData['distance'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('responses')
          : FirebaseFirestore.instance.collectionGroup('responses');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('responses').doc(id);

  static Stream<ResponsesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ResponsesRecord.fromSnapshot(s));

  static Future<ResponsesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ResponsesRecord.fromSnapshot(s));

  static ResponsesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ResponsesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ResponsesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ResponsesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ResponsesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ResponsesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createResponsesRecordData({
  DocumentReference? userDriver,
  bool? viewed,
  String? text,
  int? price,
  DateTime? dateCreated,
  String? time,
  String? distance,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_driver': userDriver,
      'viewed': viewed,
      'text': text,
      'price': price,
      'date_created': dateCreated,
      'time': time,
      'distance': distance,
    }.withoutNulls,
  );

  return firestoreData;
}

class ResponsesRecordDocumentEquality implements Equality<ResponsesRecord> {
  const ResponsesRecordDocumentEquality();

  @override
  bool equals(ResponsesRecord? e1, ResponsesRecord? e2) {
    return e1?.userDriver == e2?.userDriver &&
        e1?.viewed == e2?.viewed &&
        e1?.text == e2?.text &&
        e1?.price == e2?.price &&
        e1?.dateCreated == e2?.dateCreated &&
        e1?.time == e2?.time &&
        e1?.distance == e2?.distance;
  }

  @override
  int hash(ResponsesRecord? e) => const ListEquality().hash([
        e?.userDriver,
        e?.viewed,
        e?.text,
        e?.price,
        e?.dateCreated,
        e?.time,
        e?.distance
      ]);

  @override
  bool isValidKey(Object? o) => o is ResponsesRecord;
}
