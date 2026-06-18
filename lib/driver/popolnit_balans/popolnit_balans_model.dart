import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/driver/pay_balance/pay_balance_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'popolnit_balans_widget.dart' show PopolnitBalansWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

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
