// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FiltersStruct extends FFFirebaseStruct {
  FiltersStruct({
    double? radius,
    int? ott,
    int? doo,
    int? supply,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _radius = radius,
        _ott = ott,
        _doo = doo,
        _supply = supply,
        super(firestoreUtilData);

  // "radius" field.
  double? _radius;
  double get radius => _radius ?? 0.0;
  set radius(double? val) => _radius = val;

  void incrementRadius(double amount) => radius = radius + amount;

  bool hasRadius() => _radius != null;

  // "ott" field.
  int? _ott;
  int get ott => _ott ?? 0;
  set ott(int? val) => _ott = val;

  void incrementOtt(int amount) => ott = ott + amount;

  bool hasOtt() => _ott != null;

  // "doo" field.
  int? _doo;
  int get doo => _doo ?? 0;
  set doo(int? val) => _doo = val;

  void incrementDoo(int amount) => doo = doo + amount;

  bool hasDoo() => _doo != null;

  // "supply" field.
  int? _supply;
  int get supply => _supply ?? 0;
  set supply(int? val) => _supply = val;

  void incrementSupply(int amount) => supply = supply + amount;

  bool hasSupply() => _supply != null;

  static FiltersStruct fromMap(Map<String, dynamic> data) => FiltersStruct(
        radius: castToType<double>(data['radius']),
        ott: castToType<int>(data['ott']),
        doo: castToType<int>(data['doo']),
        supply: castToType<int>(data['supply']),
      );

  static FiltersStruct? maybeFromMap(dynamic data) =>
      data is Map ? FiltersStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'radius': _radius,
        'ott': _ott,
        'doo': _doo,
        'supply': _supply,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'radius': serializeParam(
          _radius,
          ParamType.double,
        ),
        'ott': serializeParam(
          _ott,
          ParamType.int,
        ),
        'doo': serializeParam(
          _doo,
          ParamType.int,
        ),
        'supply': serializeParam(
          _supply,
          ParamType.int,
        ),
      }.withoutNulls;

  static FiltersStruct fromSerializableMap(Map<String, dynamic> data) =>
      FiltersStruct(
        radius: deserializeParam(
          data['radius'],
          ParamType.double,
          false,
        ),
        ott: deserializeParam(
          data['ott'],
          ParamType.int,
          false,
        ),
        doo: deserializeParam(
          data['doo'],
          ParamType.int,
          false,
        ),
        supply: deserializeParam(
          data['supply'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'FiltersStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is FiltersStruct &&
        radius == other.radius &&
        ott == other.ott &&
        doo == other.doo &&
        supply == other.supply;
  }

  @override
  int get hashCode => const ListEquality().hash([radius, ott, doo, supply]);
}

FiltersStruct createFiltersStruct({
  double? radius,
  int? ott,
  int? doo,
  int? supply,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    FiltersStruct(
      radius: radius,
      ott: ott,
      doo: doo,
      supply: supply,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

FiltersStruct? updateFiltersStruct(
  FiltersStruct? filters, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    filters
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addFiltersStructData(
  Map<String, dynamic> firestoreData,
  FiltersStruct? filters,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (filters == null) {
    return;
  }
  if (filters.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && filters.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final filtersData = getFiltersFirestoreData(filters, forFieldValue);
  final nestedData = filtersData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = filters.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getFiltersFirestoreData(
  FiltersStruct? filters, [
  bool forFieldValue = false,
]) {
  if (filters == null) {
    return {};
  }
  final firestoreData = mapToFirestore(filters.toMap());

  // Add any Firestore field values
  mapToFirestore(filters.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getFiltersListFirestoreData(
  List<FiltersStruct>? filterss,
) =>
    filterss?.map((e) => getFiltersFirestoreData(e, true)).toList() ?? [];
