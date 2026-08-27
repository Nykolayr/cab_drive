import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/driver/new_card/new_card_widget.dart';
import '/driver/succ/succ_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/chips_card/chips_card_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'sposobviplat_widget.dart' show SposobviplatWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

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
