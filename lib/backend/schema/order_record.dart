import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class OrderRecord extends FirestoreRecord {
  OrderRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "selected_driver" field.
  DocumentReference? _selectedDriver;
  DocumentReference? get selectedDriver => _selectedDriver;
  bool hasSelectedDriver() => _selectedDriver != null;

  // "user_customer" field.
  DocumentReference? _userCustomer;
  DocumentReference? get userCustomer => _userCustomer;
  bool hasUserCustomer() => _userCustomer != null;

  // "supply" field.
  int? _supply;
  int get supply => _supply ?? 0;
  bool hasSupply() => _supply != null;

  // "dateTime" field.
  DateTime? _dateTime;
  DateTime? get dateTime => _dateTime;
  bool hasDateTime() => _dateTime != null;

  // "pointA" field.
  PointStruct? _pointA;
  PointStruct get pointA => _pointA ?? PointStruct();
  bool hasPointA() => _pointA != null;

  // "pointB" field.
  PointStruct? _pointB;
  PointStruct get pointB => _pointB ?? PointStruct();
  bool hasPointB() => _pointB != null;

  // "images" field.
  List<String>? _images;
  List<String> get images => _images ?? const [];
  bool hasImages() => _images != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "budget" field.
  int? _budget;
  int get budget => _budget ?? 0;
  bool hasBudget() => _budget != null;

  // "dateTime_created" field.
  DateTime? _dateTimeCreated;
  DateTime? get dateTimeCreated => _dateTimeCreated;
  bool hasDateTimeCreated() => _dateTimeCreated != null;

  // "status" field.
  StatusOrder? _status;
  StatusOrder? get status => _status;
  bool hasStatus() => _status != null;

  // "driver_reviewed" field.
  bool? _driverReviewed;
  bool get driverReviewed => _driverReviewed ?? false;
  bool hasDriverReviewed() => _driverReviewed != null;

  // "customer_reviewed" field.
  bool? _customerReviewed;
  bool get customerReviewed => _customerReviewed ?? false;
  bool hasCustomerReviewed() => _customerReviewed != null;

  // "status_do_hidden" field.
  StatusOrder? _statusDoHidden;
  StatusOrder? get statusDoHidden => _statusDoHidden;
  bool hasStatusDoHidden() => _statusDoHidden != null;

  // "count_resp" field.
  int? _countResp;
  int get countResp => _countResp ?? 0;
  bool hasCountResp() => _countResp != null;

  // "date_upd" field.
  DateTime? _dateUpd;
  DateTime? get dateUpd => _dateUpd;
  bool hasDateUpd() => _dateUpd != null;

  // "user_who_responced" field.
  List<DocumentReference>? _userWhoResponced;
  List<DocumentReference> get userWhoResponced => _userWhoResponced ?? const [];
  bool hasUserWhoResponced() => _userWhoResponced != null;

  // "distance" field.
  String? _distance;
  String get distance => _distance ?? '';
  bool hasDistance() => _distance != null;

  // "time" field.
  String? _time;
  String get time => _time ?? '';
  bool hasTime() => _time != null;

  // "driver_location" field.
  LatLng? _driverLocation;
  LatLng? get driverLocation => _driverLocation;
  bool hasDriverLocation() => _driverLocation != null;

  // "car" field.
  Car? _car;
  Car? get car => _car;
  bool hasCar() => _car != null;

  // "movers" field.
  int? _movers;
  int get movers => _movers ?? 0;
  bool hasMovers() => _movers != null;

  // "currentPrice" field.
  int? _currentPrice;
  int get currentPrice => _currentPrice ?? 0;
  bool hasCurrentPrice() => _currentPrice != null;

  // "paymentId" field.
  String? _paymentId;
  String get paymentId => _paymentId ?? '';
  bool hasPaymentId() => _paymentId != null;

  // "payMethod" field.
  PayMethod? _payMethod;
  PayMethod? get payMethod => _payMethod;
  bool hasPayMethod() => _payMethod != null;

  // "is_paid" field.
  bool? _isPaid;
  bool get isPaid => _isPaid ?? false;
  bool hasIsPaid() => _isPaid != null;

  // "image_compl" field.
  String? _imageCompl;
  String get imageCompl => _imageCompl ?? '';
  bool hasImageCompl() => _imageCompl != null;

  // "completion_date_by_the_driver" field.
  DateTime? _completionDateByTheDriver;
  DateTime? get completionDateByTheDriver => _completionDateByTheDriver;
  bool hasCompletionDateByTheDriver() => _completionDateByTheDriver != null;

  void _initializeFields() {
    _selectedDriver = snapshotData['selected_driver'] as DocumentReference?;
    _userCustomer = snapshotData['user_customer'] as DocumentReference?;
    _supply = castToType<int>(snapshotData['supply']);
    _dateTime = snapshotData['dateTime'] as DateTime?;
    _pointA = snapshotData['pointA'] is PointStruct
        ? snapshotData['pointA']
        : PointStruct.maybeFromMap(snapshotData['pointA']);
    _pointB = snapshotData['pointB'] is PointStruct
        ? snapshotData['pointB']
        : PointStruct.maybeFromMap(snapshotData['pointB']);
    _images = getDataList(snapshotData['images']);
    _description = snapshotData['description'] as String?;
    _budget = castToType<int>(snapshotData['budget']);
    _dateTimeCreated = snapshotData['dateTime_created'] as DateTime?;
    _status = snapshotData['status'] is StatusOrder
        ? snapshotData['status']
        : deserializeEnum<StatusOrder>(snapshotData['status']);
    _driverReviewed = snapshotData['driver_reviewed'] as bool?;
    _customerReviewed = snapshotData['customer_reviewed'] as bool?;
    _statusDoHidden = snapshotData['status_do_hidden'] is StatusOrder
        ? snapshotData['status_do_hidden']
        : deserializeEnum<StatusOrder>(snapshotData['status_do_hidden']);
    _countResp = castToType<int>(snapshotData['count_resp']);
    _dateUpd = snapshotData['date_upd'] as DateTime?;
    _userWhoResponced = getDataList(snapshotData['user_who_responced']);
    _distance = snapshotData['distance'] as String?;
    _time = snapshotData['time'] as String?;
    _driverLocation = snapshotData['driver_location'] as LatLng?;
    _car = snapshotData['car'] is Car
        ? snapshotData['car']
        : deserializeEnum<Car>(snapshotData['car']);
    _movers = castToType<int>(snapshotData['movers']);
    _currentPrice = castToType<int>(snapshotData['currentPrice']);
    _paymentId = snapshotData['paymentId'] as String?;
    _payMethod = snapshotData['payMethod'] is PayMethod
        ? snapshotData['payMethod']
        : deserializeEnum<PayMethod>(snapshotData['payMethod']);
    _isPaid = snapshotData['is_paid'] as bool?;
    _imageCompl = snapshotData['image_compl'] as String?;
    _completionDateByTheDriver =
        snapshotData['completion_date_by_the_driver'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('order');

  static Stream<OrderRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OrderRecord.fromSnapshot(s));

  static Future<OrderRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => OrderRecord.fromSnapshot(s));

  static OrderRecord fromSnapshot(DocumentSnapshot snapshot) => OrderRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OrderRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OrderRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OrderRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OrderRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOrderRecordData({
  DocumentReference? selectedDriver,
  DocumentReference? userCustomer,
  int? supply,
  DateTime? dateTime,
  PointStruct? pointA,
  PointStruct? pointB,
  String? description,
  int? budget,
  DateTime? dateTimeCreated,
  StatusOrder? status,
  bool? driverReviewed,
  bool? customerReviewed,
  StatusOrder? statusDoHidden,
  int? countResp,
  DateTime? dateUpd,
  String? distance,
  String? time,
  LatLng? driverLocation,
  Car? car,
  int? movers,
  int? currentPrice,
  String? paymentId,
  PayMethod? payMethod,
  bool? isPaid,
  String? imageCompl,
  DateTime? completionDateByTheDriver,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'selected_driver': selectedDriver,
      'user_customer': userCustomer,
      'supply': supply,
      'dateTime': dateTime,
      'pointA': PointStruct().toMap(),
      'pointB': PointStruct().toMap(),
      'description': description,
      'budget': budget,
      'dateTime_created': dateTimeCreated,
      'status': status,
      'driver_reviewed': driverReviewed,
      'customer_reviewed': customerReviewed,
      'status_do_hidden': statusDoHidden,
      'count_resp': countResp,
      'date_upd': dateUpd,
      'distance': distance,
      'time': time,
      'driver_location': driverLocation,
      'car': car,
      'movers': movers,
      'currentPrice': currentPrice,
      'paymentId': paymentId,
      'payMethod': payMethod,
      'is_paid': isPaid,
      'image_compl': imageCompl,
      'completion_date_by_the_driver': completionDateByTheDriver,
    }.withoutNulls,
  );

  // Handle nested data for "pointA" field.
  addPointStructData(firestoreData, pointA, 'pointA');

  // Handle nested data for "pointB" field.
  addPointStructData(firestoreData, pointB, 'pointB');

  return firestoreData;
}

class OrderRecordDocumentEquality implements Equality<OrderRecord> {
  const OrderRecordDocumentEquality();

  @override
  bool equals(OrderRecord? e1, OrderRecord? e2) {
    const listEquality = ListEquality();
    return e1?.selectedDriver == e2?.selectedDriver &&
        e1?.userCustomer == e2?.userCustomer &&
        e1?.supply == e2?.supply &&
        e1?.dateTime == e2?.dateTime &&
        e1?.pointA == e2?.pointA &&
        e1?.pointB == e2?.pointB &&
        listEquality.equals(e1?.images, e2?.images) &&
        e1?.description == e2?.description &&
        e1?.budget == e2?.budget &&
        e1?.dateTimeCreated == e2?.dateTimeCreated &&
        e1?.status == e2?.status &&
        e1?.driverReviewed == e2?.driverReviewed &&
        e1?.customerReviewed == e2?.customerReviewed &&
        e1?.statusDoHidden == e2?.statusDoHidden &&
        e1?.countResp == e2?.countResp &&
        e1?.dateUpd == e2?.dateUpd &&
        listEquality.equals(e1?.userWhoResponced, e2?.userWhoResponced) &&
        e1?.distance == e2?.distance &&
        e1?.time == e2?.time &&
        e1?.driverLocation == e2?.driverLocation &&
        e1?.car == e2?.car &&
        e1?.movers == e2?.movers &&
        e1?.currentPrice == e2?.currentPrice &&
        e1?.paymentId == e2?.paymentId &&
        e1?.payMethod == e2?.payMethod &&
        e1?.isPaid == e2?.isPaid &&
        e1?.imageCompl == e2?.imageCompl &&
        e1?.completionDateByTheDriver == e2?.completionDateByTheDriver;
  }

  @override
  int hash(OrderRecord? e) => const ListEquality().hash([
        e?.selectedDriver,
        e?.userCustomer,
        e?.supply,
        e?.dateTime,
        e?.pointA,
        e?.pointB,
        e?.images,
        e?.description,
        e?.budget,
        e?.dateTimeCreated,
        e?.status,
        e?.driverReviewed,
        e?.customerReviewed,
        e?.statusDoHidden,
        e?.countResp,
        e?.dateUpd,
        e?.userWhoResponced,
        e?.distance,
        e?.time,
        e?.driverLocation,
        e?.car,
        e?.movers,
        e?.currentPrice,
        e?.paymentId,
        e?.payMethod,
        e?.isPaid,
        e?.imageCompl,
        e?.completionDateByTheDriver
      ]);

  @override
  bool isValidKey(Object? o) => o is OrderRecord;
}
