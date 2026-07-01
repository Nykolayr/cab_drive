import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SavedCardsRecord extends FirestoreRecord {
  SavedCardsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "RebillId" field.
  String? _rebillId;
  String get rebillId => _rebillId ?? '';
  bool hasRebillId() => _rebillId != null;

  // "pan" field.
  String? _pan;
  String get pan => _pan ?? '';
  bool hasPan() => _pan != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _rebillId = snapshotData['RebillId'] as String?;
    _pan = snapshotData['pan'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('saved_cards')
          : FirebaseFirestore.instance.collectionGroup('saved_cards');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('saved_cards').doc(id);

  static Stream<SavedCardsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SavedCardsRecord.fromSnapshot(s));

  static Future<SavedCardsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SavedCardsRecord.fromSnapshot(s));

  static SavedCardsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SavedCardsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SavedCardsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SavedCardsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SavedCardsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SavedCardsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSavedCardsRecordData({
  String? rebillId,
  String? pan,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'RebillId': rebillId,
      'pan': pan,
    }.withoutNulls,
  );

  return firestoreData;
}

class SavedCardsRecordDocumentEquality implements Equality<SavedCardsRecord> {
  const SavedCardsRecordDocumentEquality();

  @override
  bool equals(SavedCardsRecord? e1, SavedCardsRecord? e2) {
    return e1?.rebillId == e2?.rebillId && e1?.pan == e2?.pan;
  }

  @override
  int hash(SavedCardsRecord? e) =>
      const ListEquality().hash([e?.rebillId, e?.pan]);

  @override
  bool isValidKey(Object? o) => o is SavedCardsRecord;
}
