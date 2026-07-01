// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PointStruct extends FFFirebaseStruct {
  PointStruct({
    LatLng? latlng,
    String? placeID,
    String? address,
    String? fullAddress,
    int? entrance,
    int? floor,
    String? flat,
    String? intercom,
    String? comment,
    SenderStruct? sender,
    String? city,
    String? region,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _latlng = latlng,
        _placeID = placeID,
        _address = address,
        _fullAddress = fullAddress,
        _entrance = entrance,
        _floor = floor,
        _flat = flat,
        _intercom = intercom,
        _comment = comment,
        _sender = sender,
        _city = city,
        _region = region,
        super(firestoreUtilData);

  // "latlng" field.
  LatLng? _latlng;
  LatLng? get latlng => _latlng;
  set latlng(LatLng? val) => _latlng = val;

  bool hasLatlng() => _latlng != null;

  // "place_ID" field.
  String? _placeID;
  String get placeID => _placeID ?? '';
  set placeID(String? val) => _placeID = val;

  bool hasPlaceID() => _placeID != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  set address(String? val) => _address = val;

  bool hasAddress() => _address != null;

  // "fullAddress" field.
  String? _fullAddress;
  String get fullAddress => _fullAddress ?? '';
  set fullAddress(String? val) => _fullAddress = val;

  bool hasFullAddress() => _fullAddress != null;

  // "entrance" field.
  int? _entrance;
  int get entrance => _entrance ?? 0;
  set entrance(int? val) => _entrance = val;

  void incrementEntrance(int amount) => entrance = entrance + amount;

  bool hasEntrance() => _entrance != null;

  // "Floor" field.
  int? _floor;
  int get floor => _floor ?? 0;
  set floor(int? val) => _floor = val;

  void incrementFloor(int amount) => floor = floor + amount;

  bool hasFloor() => _floor != null;

  // "flat" field.
  String? _flat;
  String get flat => _flat ?? '';
  set flat(String? val) => _flat = val;

  bool hasFlat() => _flat != null;

  // "Intercom" field.
  String? _intercom;
  String get intercom => _intercom ?? '';
  set intercom(String? val) => _intercom = val;

  bool hasIntercom() => _intercom != null;

  // "comment" field.
  String? _comment;
  String get comment => _comment ?? '';
  set comment(String? val) => _comment = val;

  bool hasComment() => _comment != null;

  // "sender" field.
  SenderStruct? _sender;
  SenderStruct get sender => _sender ?? SenderStruct();
  set sender(SenderStruct? val) => _sender = val;

  void updateSender(Function(SenderStruct) updateFn) {
    updateFn(_sender ??= SenderStruct());
  }

  bool hasSender() => _sender != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  set city(String? val) => _city = val;

  bool hasCity() => _city != null;

  // "region" field.
  String? _region;
  String get region => _region ?? '';
  set region(String? val) => _region = val;

  bool hasRegion() => _region != null;

  static PointStruct fromMap(Map<String, dynamic> data) => PointStruct(
        latlng: data['latlng'] as LatLng?,
        placeID: data['place_ID'] as String?,
        address: data['address'] as String?,
        fullAddress: data['fullAddress'] as String?,
        entrance: castToType<int>(data['entrance']),
        floor: castToType<int>(data['Floor']),
        flat: data['flat'] as String?,
        intercom: data['Intercom'] as String?,
        comment: data['comment'] as String?,
        sender: data['sender'] is SenderStruct
            ? data['sender']
            : SenderStruct.maybeFromMap(data['sender']),
        city: data['city'] as String?,
        region: data['region'] as String?,
      );

  static PointStruct? maybeFromMap(dynamic data) =>
      data is Map ? PointStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'latlng': _latlng,
        'place_ID': _placeID,
        'address': _address,
        'fullAddress': _fullAddress,
        'entrance': _entrance,
        'Floor': _floor,
        'flat': _flat,
        'Intercom': _intercom,
        'comment': _comment,
        'sender': _sender?.toMap(),
        'city': _city,
        'region': _region,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'latlng': serializeParam(
          _latlng,
          ParamType.LatLng,
        ),
        'place_ID': serializeParam(
          _placeID,
          ParamType.String,
        ),
        'address': serializeParam(
          _address,
          ParamType.String,
        ),
        'fullAddress': serializeParam(
          _fullAddress,
          ParamType.String,
        ),
        'entrance': serializeParam(
          _entrance,
          ParamType.int,
        ),
        'Floor': serializeParam(
          _floor,
          ParamType.int,
        ),
        'flat': serializeParam(
          _flat,
          ParamType.String,
        ),
        'Intercom': serializeParam(
          _intercom,
          ParamType.String,
        ),
        'comment': serializeParam(
          _comment,
          ParamType.String,
        ),
        'sender': serializeParam(
          _sender,
          ParamType.DataStruct,
        ),
        'city': serializeParam(
          _city,
          ParamType.String,
        ),
        'region': serializeParam(
          _region,
          ParamType.String,
        ),
      }.withoutNulls;

  static PointStruct fromSerializableMap(Map<String, dynamic> data) =>
      PointStruct(
        latlng: deserializeParam(
          data['latlng'],
          ParamType.LatLng,
          false,
        ),
        placeID: deserializeParam(
          data['place_ID'],
          ParamType.String,
          false,
        ),
        address: deserializeParam(
          data['address'],
          ParamType.String,
          false,
        ),
        fullAddress: deserializeParam(
          data['fullAddress'],
          ParamType.String,
          false,
        ),
        entrance: deserializeParam(
          data['entrance'],
          ParamType.int,
          false,
        ),
        floor: deserializeParam(
          data['Floor'],
          ParamType.int,
          false,
        ),
        flat: deserializeParam(
          data['flat'],
          ParamType.String,
          false,
        ),
        intercom: deserializeParam(
          data['Intercom'],
          ParamType.String,
          false,
        ),
        comment: deserializeParam(
          data['comment'],
          ParamType.String,
          false,
        ),
        sender: deserializeStructParam(
          data['sender'],
          ParamType.DataStruct,
          false,
          structBuilder: SenderStruct.fromSerializableMap,
        ),
        city: deserializeParam(
          data['city'],
          ParamType.String,
          false,
        ),
        region: deserializeParam(
          data['region'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'PointStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PointStruct &&
        latlng == other.latlng &&
        placeID == other.placeID &&
        address == other.address &&
        fullAddress == other.fullAddress &&
        entrance == other.entrance &&
        floor == other.floor &&
        flat == other.flat &&
        intercom == other.intercom &&
        comment == other.comment &&
        sender == other.sender &&
        city == other.city &&
        region == other.region;
  }

  @override
  int get hashCode => const ListEquality().hash([
        latlng,
        placeID,
        address,
        fullAddress,
        entrance,
        floor,
        flat,
        intercom,
        comment,
        sender,
        city,
        region
      ]);
}

PointStruct createPointStruct({
  LatLng? latlng,
  String? placeID,
  String? address,
  String? fullAddress,
  int? entrance,
  int? floor,
  String? flat,
  String? intercom,
  String? comment,
  SenderStruct? sender,
  String? city,
  String? region,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    PointStruct(
      latlng: latlng,
      placeID: placeID,
      address: address,
      fullAddress: fullAddress,
      entrance: entrance,
      floor: floor,
      flat: flat,
      intercom: intercom,
      comment: comment,
      sender: sender ?? (clearUnsetFields ? SenderStruct() : null),
      city: city,
      region: region,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

PointStruct? updatePointStruct(
  PointStruct? point, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    point
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addPointStructData(
  Map<String, dynamic> firestoreData,
  PointStruct? point,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (point == null) {
    return;
  }
  if (point.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && point.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final pointData = getPointFirestoreData(point, forFieldValue);
  final nestedData = pointData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = point.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getPointFirestoreData(
  PointStruct? point, [
  bool forFieldValue = false,
]) {
  if (point == null) {
    return {};
  }
  final firestoreData = mapToFirestore(point.toMap());

  // Handle nested data for "sender" field.
  addSenderStructData(
    firestoreData,
    point.hasSender() ? point.sender : null,
    'sender',
    forFieldValue,
  );

  // Add any Firestore field values
  mapToFirestore(point.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPointListFirestoreData(
  List<PointStruct>? points,
) =>
    points?.map((e) => getPointFirestoreData(e, true)).toList() ?? [];
