import '/backend/api_requests/api_calls.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'karta_widget.dart' show KartaWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
