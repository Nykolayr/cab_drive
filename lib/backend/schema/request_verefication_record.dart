import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RequestVereficationRecord extends FirestoreRecord {
  RequestVereficationRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "photo_doc" field.
  List<String>? _photoDoc;
  List<String> get photoDoc => _photoDoc ?? const [];
  bool hasPhotoDoc() => _photoDoc != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  bool hasCity() => _city != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "surname" field.
  String? _surname;
  String get surname => _surname ?? '';
  bool hasSurname() => _surname != null;

  // "dfb" field.
  DateTime? _dfb;
  DateTime? get dfb => _dfb;
  bool hasDfb() => _dfb != null;

  // "photo_avto" field.
  List<String>? _photoAvto;
  List<String> get photoAvto => _photoAvto ?? const [];
  bool hasPhotoAvto() => _photoAvto != null;

  // "number_avto" field.
  String? _numberAvto;
  String get numberAvto => _numberAvto ?? '';
  bool hasNumberAvto() => _numberAvto != null;

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "status" field.
  StatusVerif? _status;
  StatusVerif? get status => _status;
  bool hasStatus() => _status != null;

  // "dateCreated" field.
  DateTime? _dateCreated;
  DateTime? get dateCreated => _dateCreated;
  bool hasDateCreated() => _dateCreated != null;

  // "number_id" field.
  int? _numberId;
  int get numberId => _numberId ?? 0;
  bool hasNumberId() => _numberId != null;

  // "avatar" field.
  String? _avatar;
  String get avatar => _avatar ?? '';
  bool hasAvatar() => _avatar != null;

  // "marka" field.
  Car? _marka;
  Car? get marka => _marka;
  bool hasMarka() => _marka != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _photoDoc = getDataList(snapshotData['photo_doc']);
    _city = snapshotData['city'] as String?;
    _name = snapshotData['name'] as String?;
    _surname = snapshotData['surname'] as String?;
    _dfb = snapshotData['dfb'] as DateTime?;
    _photoAvto = getDataList(snapshotData['photo_avto']);
    _numberAvto = snapshotData['number_avto'] as String?;
    _user = snapshotData['user'] as DocumentReference?;
    _status = snapshotData['status'] is StatusVerif
        ? snapshotData['status']
        : deserializeEnum<StatusVerif>(snapshotData['status']);
    _dateCreated = snapshotData['dateCreated'] as DateTime?;
    _numberId = castToType<int>(snapshotData['number_id']);
    _avatar = snapshotData['avatar'] as String?;
    _marka = snapshotData['marka'] is Car
        ? snapshotData['marka']
        : deserializeEnum<Car>(snapshotData['marka']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('request_verefication');

  static Stream<RequestVereficationRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RequestVereficationRecord.fromSnapshot(s));

  static Future<RequestVereficationRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => RequestVereficationRecord.fromSnapshot(s));

  static RequestVereficationRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RequestVereficationRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RequestVereficationRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RequestVereficationRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RequestVereficationRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RequestVereficationRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRequestVereficationRecordData({
  String? email,
  String? phoneNumber,
  String? city,
  String? name,
  String? surname,
  DateTime? dfb,
  String? numberAvto,
  DocumentReference? user,
  StatusVerif? status,
  DateTime? dateCreated,
  int? numberId,
  String? avatar,
  Car? marka,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'phone_number': phoneNumber,
      'city': city,
      'name': name,
      'surname': surname,
      'dfb': dfb,
      'number_avto': numberAvto,
      'user': user,
      'status': status,
      'dateCreated': dateCreated,
      'number_id': numberId,
      'avatar': avatar,
      'marka': marka,
    }.withoutNulls,
  );

  return firestoreData;
}

class RequestVereficationRecordDocumentEquality
    implements Equality<RequestVereficationRecord> {
  const RequestVereficationRecordDocumentEquality();

  @override
  bool equals(RequestVereficationRecord? e1, RequestVereficationRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.phoneNumber == e2?.phoneNumber &&
        listEquality.equals(e1?.photoDoc, e2?.photoDoc) &&
        e1?.city == e2?.city &&
        e1?.name == e2?.name &&
        e1?.surname == e2?.surname &&
        e1?.dfb == e2?.dfb &&
        listEquality.equals(e1?.photoAvto, e2?.photoAvto) &&
        e1?.numberAvto == e2?.numberAvto &&
        e1?.user == e2?.user &&
        e1?.status == e2?.status &&
        e1?.dateCreated == e2?.dateCreated &&
        e1?.numberId == e2?.numberId &&
        e1?.avatar == e2?.avatar &&
        e1?.marka == e2?.marka;
  }

  @override
  int hash(RequestVereficationRecord? e) => const ListEquality().hash([
        e?.email,
        e?.phoneNumber,
        e?.photoDoc,
        e?.city,
        e?.name,
        e?.surname,
        e?.dfb,
        e?.photoAvto,
        e?.numberAvto,
        e?.user,
        e?.status,
        e?.dateCreated,
        e?.numberId,
        e?.avatar,
        e?.marka
      ]);

  @override
  bool isValidKey(Object? o) => o is RequestVereficationRecord;
}
