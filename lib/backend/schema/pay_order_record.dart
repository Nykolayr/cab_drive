import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PayOrderRecord extends FirestoreRecord {
  PayOrderRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "order_id" field.
  String? _orderId;
  String get orderId => _orderId ?? '';
  bool hasOrderId() => _orderId != null;

  // "amount_in_cop" field.
  int? _amountInCop;
  int get amountInCop => _amountInCop ?? 0;
  bool hasAmountInCop() => _amountInCop != null;

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "is_paid" field.
  bool? _isPaid;
  bool get isPaid => _isPaid ?? false;
  bool hasIsPaid() => _isPaid != null;

  // "paymentId" field.
  String? _paymentId;
  String get paymentId => _paymentId ?? '';
  bool hasPaymentId() => _paymentId != null;

  // "current_order_doc_ref" field.
  DocumentReference? _currentOrderDocRef;
  DocumentReference? get currentOrderDocRef => _currentOrderDocRef;
  bool hasCurrentOrderDocRef() => _currentOrderDocRef != null;

  // "paymentType" field.
  PaymentType? _paymentType;
  PaymentType? get paymentType => _paymentType;
  bool hasPaymentType() => _paymentType != null;

  // "driver" field.
  DocumentReference? _driver;
  DocumentReference? get driver => _driver;
  bool hasDriver() => _driver != null;

  // "list_users_upd_ballance" field.
  List<DocumentReference>? _listUsersUpdBallance;
  List<DocumentReference> get listUsersUpdBallance =>
      _listUsersUpdBallance ?? const [];
  bool hasListUsersUpdBallance() => _listUsersUpdBallance != null;

  // "summ_upd_ballance" field.
  double? _summUpdBallance;
  double get summUpdBallance => _summUpdBallance ?? 0.0;
  bool hasSummUpdBallance() => _summUpdBallance != null;

  void _initializeFields() {
    _orderId = snapshotData['order_id'] as String?;
    _amountInCop = castToType<int>(snapshotData['amount_in_cop']);
    _user = snapshotData['user'] as DocumentReference?;
    _isPaid = snapshotData['is_paid'] as bool?;
    _paymentId = snapshotData['paymentId'] as String?;
    _currentOrderDocRef =
        snapshotData['current_order_doc_ref'] as DocumentReference?;
    _paymentType = snapshotData['paymentType'] is PaymentType
        ? snapshotData['paymentType']
        : deserializeEnum<PaymentType>(snapshotData['paymentType']);
    _driver = snapshotData['driver'] as DocumentReference?;
    _listUsersUpdBallance =
        getDataList(snapshotData['list_users_upd_ballance']);
    _summUpdBallance = castToType<double>(snapshotData['summ_upd_ballance']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('pay_order');

  static Stream<PayOrderRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PayOrderRecord.fromSnapshot(s));

  static Future<PayOrderRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PayOrderRecord.fromSnapshot(s));

  static PayOrderRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PayOrderRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PayOrderRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PayOrderRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PayOrderRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PayOrderRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPayOrderRecordData({
  String? orderId,
  int? amountInCop,
  DocumentReference? user,
  bool? isPaid,
  String? paymentId,
  DocumentReference? currentOrderDocRef,
  PaymentType? paymentType,
  DocumentReference? driver,
  double? summUpdBallance,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'order_id': orderId,
      'amount_in_cop': amountInCop,
      'user': user,
      'is_paid': isPaid,
      'paymentId': paymentId,
      'current_order_doc_ref': currentOrderDocRef,
      'paymentType': paymentType,
      'driver': driver,
      'summ_upd_ballance': summUpdBallance,
    }.withoutNulls,
  );

  return firestoreData;
}

class PayOrderRecordDocumentEquality implements Equality<PayOrderRecord> {
  const PayOrderRecordDocumentEquality();

  @override
  bool equals(PayOrderRecord? e1, PayOrderRecord? e2) {
    const listEquality = ListEquality();
    return e1?.orderId == e2?.orderId &&
        e1?.amountInCop == e2?.amountInCop &&
        e1?.user == e2?.user &&
        e1?.isPaid == e2?.isPaid &&
        e1?.paymentId == e2?.paymentId &&
        e1?.currentOrderDocRef == e2?.currentOrderDocRef &&
        e1?.paymentType == e2?.paymentType &&
        e1?.driver == e2?.driver &&
        listEquality.equals(
            e1?.listUsersUpdBallance, e2?.listUsersUpdBallance) &&
        e1?.summUpdBallance == e2?.summUpdBallance;
  }

  @override
  int hash(PayOrderRecord? e) => const ListEquality().hash([
        e?.orderId,
        e?.amountInCop,
        e?.user,
        e?.isPaid,
        e?.paymentId,
        e?.currentOrderDocRef,
        e?.paymentType,
        e?.driver,
        e?.listUsersUpdBallance,
        e?.summUpdBallance
      ]);

  @override
  bool isValidKey(Object? o) => o is PayOrderRecord;
}
