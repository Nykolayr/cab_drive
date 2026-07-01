import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'login_widget.dart' show LoginWidget;
import 'package:flutter/material.dart';

class LoginModel extends FlutterFlowModel<LoginWidget> {
  ///  Local state fields for this page.

  String? phone;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ChatsRecord? chatWithSupport;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  int? countUsers;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
