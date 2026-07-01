import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'sposobviplat_widget.dart' show SposobviplatWidget;
import 'package:flutter/material.dart';

class SposobviplatModel extends FlutterFlowModel<SposobviplatWidget> {
  ///  Local state fields for this component.

  String? select = '';

  SavedCardsRecord? card;

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - API (Payout)] action in Button widget.
  ApiCallResponse? apiResultlwg;
  // Stores action output result for [Backend Call - API (Create Client And Payout)] action in Button widget.
  ApiCallResponse? apiResultabi;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
