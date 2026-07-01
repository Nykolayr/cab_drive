import '/flutter_flow/flutter_flow_util.dart';
import 'izmenit_pochtu_widget.dart' show IzmenitPochtuWidget;
import 'package:flutter/material.dart';

class IzmenitPochtuModel extends FlutterFlowModel<IzmenitPochtuWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for pochta widget.
  FocusNode? pochtaFocusNode;
  TextEditingController? pochtaTextController;
  String? Function(BuildContext, String?)? pochtaTextControllerValidator;
  String? _pochtaTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Обязательно для заполнения';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Обязательно для заполнения';
    }
    return null;
  }

  @override
  void initState(BuildContext context) {
    pochtaTextControllerValidator = _pochtaTextControllerValidator;
  }

  @override
  void dispose() {
    pochtaFocusNode?.dispose();
    pochtaTextController?.dispose();
  }
}
