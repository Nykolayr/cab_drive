import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'create_otklick_widget.dart' show CreateOtklickWidget;
import 'package:flutter/material.dart';

class CreateOtklickModel extends FlutterFlowModel<CreateOtklickWidget> {
  final formKey = GlobalKey<FormState>();

  // Comment input.
  FocusNode? commentBFocusNode;
  TextEditingController? commentBTextController;
  String? Function(BuildContext, String?)? commentBTextControllerValidator;
  String? _commentBTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.trim().length < 3) {
      return 'Напишите хотя бы пару слов';
    }
    return null;
  }

  // Custom price input (visible when priceMode == 2).
  FocusNode? customPriceFocusNode;
  TextEditingController? customPriceTextController;

  // ETA input (optional).
  FocusNode? etaFocusNode;
  TextEditingController? etaTextController;

  // Price mode: 0 = none, 1 = customer's price, 2 = custom.
  int priceMode = 0;

  // Stores action output for DistanceMatrix call.
  ApiCallResponse? adsd3;

  @override
  void initState(BuildContext context) {
    commentBTextControllerValidator = _commentBTextControllerValidator;
  }

  @override
  void dispose() {
    commentBFocusNode?.dispose();
    commentBTextController?.dispose();
    customPriceFocusNode?.dispose();
    customPriceTextController?.dispose();
    etaFocusNode?.dispose();
    etaTextController?.dispose();
  }
}
