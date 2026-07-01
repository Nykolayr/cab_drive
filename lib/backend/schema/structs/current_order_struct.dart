// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CurrentOrderStruct extends FFFirebaseStruct {
  CurrentOrderStruct({
    DocumentReference? orderDocRef,
    LatLng? pointB,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _orderDocRef = orderDocRef,
        _pointB = pointB,
        super(firestoreUtilData);

  // "Order_DocRef" field.
  DocumentReference? _orderDocRef;
  DocumentReference? get orderDocRef => _orderDocRef;
  set orderDocRef(DocumentReference? val) => _orderDocRef = val;

  bool hasOrderDocRef() => _orderDocRef != null;

  // "pointB" field.
  LatLng? _pointB;
  LatLng? get pointB => _pointB;
  set pointB(LatLng? val) => _pointB = val;

  bool hasPointB() => _pointB != null;

  static CurrentOrderStruct fromMap(Map<String, dynamic> data) =>
      CurrentOrderStruct(
        orderDocRef: data['Order_DocRef'] as DocumentReference?,
        pointB: data['pointB'] as LatLng?,
      );

  static CurrentOrderStruct? maybeFromMap(dynamic data) => data is Map
      ? CurrentOrderStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'Order_DocRef': _orderDocRef,
        'pointB': _pointB,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'Order_DocRef': serializeParam(
          _orderDocRef,
          ParamType.DocumentReference,
        ),
        'pointB': serializeParam(
          _pointB,
          ParamType.LatLng,
        ),
      }.withoutNulls;

  static CurrentOrderStruct fromSerializableMap(Map<String, dynamic> data) =>
      CurrentOrderStruct(
        orderDocRef: deserializeParam(
          data['Order_DocRef'],
          ParamType.DocumentReference,
          false,
          collectionNamePath: ['order'],
        ),
        pointB: deserializeParam(
          data['pointB'],
          ParamType.LatLng,
          false,
        ),
      );

  @override
  String toString() => 'CurrentOrderStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CurrentOrderStruct &&
        orderDocRef == other.orderDocRef &&
        pointB == other.pointB;
  }

  @override
  int get hashCode => const ListEquality().hash([orderDocRef, pointB]);
}

CurrentOrderStruct createCurrentOrderStruct({
  DocumentReference? orderDocRef,
  LatLng? pointB,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CurrentOrderStruct(
      orderDocRef: orderDocRef,
      pointB: pointB,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CurrentOrderStruct? updateCurrentOrderStruct(
  CurrentOrderStruct? currentOrder, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    currentOrder
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCurrentOrderStructData(
  Map<String, dynamic> firestoreData,
  CurrentOrderStruct? currentOrder,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (currentOrder == null) {
    return;
  }
  if (currentOrder.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && currentOrder.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final currentOrderData =
      getCurrentOrderFirestoreData(currentOrder, forFieldValue);
  final nestedData =
      currentOrderData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = currentOrder.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCurrentOrderFirestoreData(
  CurrentOrderStruct? currentOrder, [
  bool forFieldValue = false,
]) {
  if (currentOrder == null) {
    return {};
  }
  final firestoreData = mapToFirestore(currentOrder.toMap());

  // Add any Firestore field values
  mapToFirestore(currentOrder.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCurrentOrderListFirestoreData(
  List<CurrentOrderStruct>? currentOrders,
) =>
    currentOrders?.map((e) => getCurrentOrderFirestoreData(e, true)).toList() ??
    [];
