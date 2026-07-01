// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SenderStruct extends FFFirebaseStruct {
  SenderStruct({
    String? name,
    String? phone,
    bool? itsMe,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        _phone = phone,
        _itsMe = itsMe,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  set phone(String? val) => _phone = val;

  bool hasPhone() => _phone != null;

  // "itsMe" field.
  bool? _itsMe;
  bool get itsMe => _itsMe ?? false;
  set itsMe(bool? val) => _itsMe = val;

  bool hasItsMe() => _itsMe != null;

  static SenderStruct fromMap(Map<String, dynamic> data) => SenderStruct(
        name: data['name'] as String?,
        phone: data['phone'] as String?,
        itsMe: data['itsMe'] as bool?,
      );

  static SenderStruct? maybeFromMap(dynamic data) =>
      data is Map ? SenderStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
        'phone': _phone,
        'itsMe': _itsMe,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'phone': serializeParam(
          _phone,
          ParamType.String,
        ),
        'itsMe': serializeParam(
          _itsMe,
          ParamType.bool,
        ),
      }.withoutNulls;

  static SenderStruct fromSerializableMap(Map<String, dynamic> data) =>
      SenderStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        phone: deserializeParam(
          data['phone'],
          ParamType.String,
          false,
        ),
        itsMe: deserializeParam(
          data['itsMe'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'SenderStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SenderStruct &&
        name == other.name &&
        phone == other.phone &&
        itsMe == other.itsMe;
  }

  @override
  int get hashCode => const ListEquality().hash([name, phone, itsMe]);
}

SenderStruct createSenderStruct({
  String? name,
  String? phone,
  bool? itsMe,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SenderStruct(
      name: name,
      phone: phone,
      itsMe: itsMe,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SenderStruct? updateSenderStruct(
  SenderStruct? sender, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    sender
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSenderStructData(
  Map<String, dynamic> firestoreData,
  SenderStruct? sender,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (sender == null) {
    return;
  }
  if (sender.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && sender.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final senderData = getSenderFirestoreData(sender, forFieldValue);
  final nestedData = senderData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = sender.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSenderFirestoreData(
  SenderStruct? sender, [
  bool forFieldValue = false,
]) {
  if (sender == null) {
    return {};
  }
  final firestoreData = mapToFirestore(sender.toMap());

  // Add any Firestore field values
  mapToFirestore(sender.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSenderListFirestoreData(
  List<SenderStruct>? senders,
) =>
    senders?.map((e) => getSenderFirestoreData(e, true)).toList() ?? [];
