// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Legacy: раньше писал balance в Firestore.
/// Баланс = Postgres SoT (webhook Tinkoff / серверные ops). FS write отключён.
Future usersBall(
  List<DocumentReference>? users,
  double summ,
) async {
  print(
    '[usersBall] SKIP Firestore write users=${users?.length ?? 0} summ=$summ '
    '(SoT=Postgres)',
  );
  return;
}
