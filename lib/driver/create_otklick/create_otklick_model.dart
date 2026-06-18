import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/structs/index.dart';
import '/driver/za_chto_plata/za_chto_plata_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'create_otklick_widget.dart' show CreateOtklickWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

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
