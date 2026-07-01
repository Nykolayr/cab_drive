import '/flutter_flow/flutter_flow_util.dart';
import 'text_info_widget.dart' show TextInfoWidget;
import 'package:flutter/material.dart';

class TextInfoModel extends FlutterFlowModel<TextInfoWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for input widget.
  FocusNode? inputFocusNode;
  TextEditingController? inputTextController;
  String? Function(BuildContext, String?)? inputTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    inputFocusNode?.dispose();
    inputTextController?.dispose();
  }
}
