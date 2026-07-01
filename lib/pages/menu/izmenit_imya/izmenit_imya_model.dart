import '/flutter_flow/flutter_flow_util.dart';
import 'izmenit_imya_widget.dart' show IzmenitImyaWidget;
import 'package:flutter/material.dart';

class IzmenitImyaModel extends FlutterFlowModel<IzmenitImyaWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for NameInput widget.
  FocusNode? nameInputFocusNode;
  TextEditingController? nameInputTextController;
  String? Function(BuildContext, String?)? nameInputTextControllerValidator;
  String? _nameInputTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Обязательно для заполнения';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    nameInputTextControllerValidator = _nameInputTextControllerValidator;
  }

  @override
  void dispose() {
    nameInputFocusNode?.dispose();
    nameInputTextController?.dispose();
  }
}
