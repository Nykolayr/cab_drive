import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'popolnit_balans_widget.dart' show PopolnitBalansWidget;
import 'package:flutter/material.dart';

class PopolnitBalansModel extends FlutterFlowModel<PopolnitBalansWidget> {
  ///  Local state fields for this component.

  double num = 0.0;

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

  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  PayOrderRecord? order;

  @override
  void initState(BuildContext context) {
    budgetInputTextControllerValidator = _budgetInputTextControllerValidator;
  }

  @override
  void dispose() {
    budgetInputFocusNode?.dispose();
    budgetInputTextController?.dispose();
  }
}
