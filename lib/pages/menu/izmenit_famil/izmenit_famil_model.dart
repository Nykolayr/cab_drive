import '/flutter_flow/flutter_flow_util.dart';
import 'izmenit_famil_widget.dart' show IzmenitFamilWidget;
import 'package:flutter/material.dart';

class IzmenitFamilModel extends FlutterFlowModel<IzmenitFamilWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for famil widget.
  FocusNode? familFocusNode;
  TextEditingController? familTextController;
  String? Function(BuildContext, String?)? familTextControllerValidator;
  String? _familTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Обязательно для заполнения';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    familTextControllerValidator = _familTextControllerValidator;
  }

  @override
  void dispose() {
    familFocusNode?.dispose();
    familTextController?.dispose();
  }
}
