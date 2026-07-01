import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'pay_init_widget.dart' show PayInitWidget;
import 'package:flutter/material.dart';

class PayInitModel extends FlutterFlowModel<PayInitWidget> {
  ///  Local state fields for this component.

  bool urlIsSet = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Read Document] action in pay_init widget.
  PayOrderRecord? order;
  // Stores action output result for [Backend Call - API (Init Payment)] action in pay_init widget.
  ApiCallResponse? aposdasdanfa23;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
