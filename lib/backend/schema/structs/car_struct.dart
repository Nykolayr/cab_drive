// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CarStruct extends FFFirebaseStruct {
  CarStruct({
    String? nomer,
    List<String>? images,
    Car? mark,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _nomer = nomer,
        _images = images,
        _mark = mark,
        super(firestoreUtilData);

  // "nomer" field.
  String? _nomer;
  String get nomer => _nomer ?? '';
  set nomer(String? val) => _nomer = val;

  bool hasNomer() => _nomer != null;

  // "images" field.
  List<String>? _images;
  List<String> get images => _images ?? const [];
  set images(List<String>? val) => _images = val;

  void updateImages(Function(List<String>) updateFn) {
    updateFn(_images ??= []);
  }

  bool hasImages() => _images != null;

  // "mark" field.
  Car? _mark;
  Car? get mark => _mark;
  set mark(Car? val) => _mark = val;

  bool hasMark() => _mark != null;

  static CarStruct fromMap(Map<String, dynamic> data) => CarStruct(
        nomer: data['nomer'] as String?,
        images: getDataList(data['images']),
        mark: data['mark'] is Car
            ? data['mark']
            : deserializeEnum<Car>(data['mark']),
      );

  static CarStruct? maybeFromMap(dynamic data) =>
      data is Map ? CarStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'nomer': _nomer,
        'images': _images,
        'mark': _mark?.serialize(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'nomer': serializeParam(
          _nomer,
          ParamType.String,
        ),
        'images': serializeParam(
          _images,
          ParamType.String,
          isList: true,
        ),
        'mark': serializeParam(
          _mark,
          ParamType.Enum,
        ),
      }.withoutNulls;

  static CarStruct fromSerializableMap(Map<String, dynamic> data) => CarStruct(
        nomer: deserializeParam(
          data['nomer'],
          ParamType.String,
          false,
        ),
        images: deserializeParam<String>(
          data['images'],
          ParamType.String,
          true,
        ),
        mark: deserializeParam<Car>(
          data['mark'],
          ParamType.Enum,
          false,
        ),
      );

  @override
  String toString() => 'CarStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is CarStruct &&
        nomer == other.nomer &&
        listEquality.equals(images, other.images) &&
        mark == other.mark;
  }

  @override
  int get hashCode => const ListEquality().hash([nomer, images, mark]);
}

CarStruct createCarStruct({
  String? nomer,
  Car? mark,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CarStruct(
      nomer: nomer,
      mark: mark,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CarStruct? updateCarStruct(
  CarStruct? car, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    car
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCarStructData(
  Map<String, dynamic> firestoreData,
  CarStruct? car,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (car == null) {
    return;
  }
  if (car.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields = !forFieldValue && car.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final carData = getCarFirestoreData(car, forFieldValue);
  final nestedData = carData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = car.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCarFirestoreData(
  CarStruct? car, [
  bool forFieldValue = false,
]) {
  if (car == null) {
    return {};
  }
  final firestoreData = mapToFirestore(car.toMap());

  // Add any Firestore field values
  mapToFirestore(car.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCarListFirestoreData(
  List<CarStruct>? cars,
) =>
    cars?.map((e) => getCarFirestoreData(e, true)).toList() ?? [];
