import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'create_otklick_widget.dart' show CreateOtklickWidget;
import 'package:flutter/material.dart';

class CreateOtklickModel extends FlutterFlowModel<CreateOtklickWidget> {
  final formKey = GlobalKey<FormState>();

  // Comment input (optional).
  FocusNode? commentBFocusNode;
  TextEditingController? commentBTextController;
  String? Function(BuildContext, String?)? commentBTextControllerValidator;

  // Custom price input (visible when priceMode == 2).
  FocusNode? customPriceFocusNode;
  TextEditingController? customPriceTextController;

  // ETA preset selection: 0 = none, 1..3 = preset buttons, 4 = "Более" (комментарий).
  int etaMode = 0;

  // Price mode: 0 = none, 1 = customer's price, 2 = custom.
  int priceMode = 0;

  // Stores action output for DistanceMatrix call.
  ApiCallResponse? adsd3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    commentBFocusNode?.dispose();
    commentBTextController?.dispose();
    customPriceFocusNode?.dispose();
    customPriceTextController?.dispose();
  }
}
