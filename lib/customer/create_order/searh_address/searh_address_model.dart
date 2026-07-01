import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'searh_address_widget.dart' show SearhAddressWidget;
import 'package:flutter/material.dart';

class SearhAddressModel extends FlutterFlowModel<SearhAddressWidget> {
  ///  Local state fields for this component.

  int? currentPoint;

  ///  State fields for stateful widgets in this component.

  // State field(s) for pointA widget.
  FocusNode? pointAFocusNode;
  TextEditingController? pointATextController;
  String? Function(BuildContext, String?)? pointATextControllerValidator;
  // Stores action output result for [Backend Call - API (autocomplete)] action in pointA widget.
  ApiCallResponse? apiResult1veA;
  // State field(s) for pointB widget.
  FocusNode? pointBFocusNode;
  TextEditingController? pointBTextController;
  String? Function(BuildContext, String?)? pointBTextControllerValidator;
  // Stores action output result for [Backend Call - API (autocomplete)] action in pointB widget.
  ApiCallResponse? apiResult1veB;
  // Stores action output result for [Backend Call - API (geocode Place ID)] action in Container widget.
  ApiCallResponse? geocodeAAA;
  // Stores action output result for [Backend Call - API (DistanceMatrix)] action in Container widget.
  ApiCallResponse? adsd2;
  // Stores action output result for [Backend Call - API (geocode Place ID)] action in Container widget.
  ApiCallResponse? geocodeBBB;
  // Stores action output result for [Backend Call - API (DistanceMatrix)] action in Container widget.
  ApiCallResponse? adsd;
  // Stores action output result for [Backend Call - API (DistanceMatrix)] action in Container widget.
  ApiCallResponse? adsd4;
  // Stores action output result for [Backend Call - API (DistanceMatrix)] action in Container widget.
  ApiCallResponse? adsd3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    pointAFocusNode?.dispose();
    pointATextController?.dispose();

    pointBFocusNode?.dispose();
    pointBTextController?.dispose();
  }
}
