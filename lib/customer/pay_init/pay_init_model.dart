import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_web_view.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'pay_init_widget.dart' show PayInitWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

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
