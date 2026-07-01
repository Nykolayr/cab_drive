import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'karta_widget.dart' show KartaWidget;
import 'package:flutter/material.dart';

class KartaModel extends FlutterFlowModel<KartaWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for point widget.
  FocusNode? pointFocusNode;
  TextEditingController? pointTextController;
  String? Function(BuildContext, String?)? pointTextControllerValidator;
  // Stores action output result for [Backend Call - API (autocomplete)] action in point widget.
  ApiCallResponse? apiResult1ve;
  // Stores action output result for [Backend Call - API (geocode Place ID)] action in Container widget.
  ApiCallResponse? geocode;
  // Stores action output result for [Backend Call - API (DistanceMatrix)] action in Container widget.
  ApiCallResponse? adsd2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    pointFocusNode?.dispose();
    pointTextController?.dispose();
  }
}
