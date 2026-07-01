import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'create_otklick_widget.dart' show CreateOtklickWidget;
import 'package:flutter/material.dart';

class CreateOtklickModel extends FlutterFlowModel<CreateOtklickWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for budgetInput widget.
  FocusNode? budgetInputFocusNode;
  TextEditingController? budgetInputTextController;
  String? Function(BuildContext, String?)? budgetInputTextControllerValidator;
  String? _budgetInputTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Введите сумму';
    }

    if (!RegExp('^\\d+\$').hasMatch(val)) {
      return 'Введите сумму';
    }
    return null;
  }

  // State field(s) for comment_B widget.
  FocusNode? commentBFocusNode;
  TextEditingController? commentBTextController;
  String? Function(BuildContext, String?)? commentBTextControllerValidator;
  String? _commentBTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Напишите хотя бы пару слов';
    }

    if (val.length < 3) {
      return 'Напишите хотя бы пару слов';
    }

    return null;
  }

  // Stores action output result for [Backend Call - API (DistanceMatrix)] action in Button widget.
  ApiCallResponse? adsd3;

  @override
  void initState(BuildContext context) {
    budgetInputTextControllerValidator = _budgetInputTextControllerValidator;
    commentBTextControllerValidator = _commentBTextControllerValidator;
  }

  @override
  void dispose() {
    budgetInputFocusNode?.dispose();
    budgetInputTextController?.dispose();

    commentBFocusNode?.dispose();
    commentBTextController?.dispose();
  }
}
