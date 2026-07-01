import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'pay_balance_widget.dart' show PayBalanceWidget;
import 'package:flutter/material.dart';

class PayBalanceModel extends FlutterFlowModel<PayBalanceWidget> {
  ///  Local state fields for this component.

  bool urlIsSet = false;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Read Document] action in pay_balance widget.
  PayOrderRecord? order;
  // Stores action output result for [Backend Call - API (Init Payment)] action in pay_balance widget.
  ApiCallResponse? apiResultjrtURL;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
