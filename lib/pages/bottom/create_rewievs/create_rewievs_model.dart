import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'create_rewievs_widget.dart' show CreateRewievsWidget;
import 'package:flutter/material.dart';

class CreateRewievsModel extends FlutterFlowModel<CreateRewievsWidget> {
  ///  Local state fields for this component.

  int? rait;

  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - Read Document] action in Button widget.
  UsersRecord? user;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
