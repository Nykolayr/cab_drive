import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/enums/enums.dart';
import '/customer/pay_init/pay_init_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/ratting/ratting_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'responsed_detail_widget.dart' show ResponsedDetailWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class ResponsedDetailModel extends FlutterFlowModel<ResponsedDetailWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Switch widget — customer's agreement to increase budget.
  bool agreedToIncreaseBudget = false;

  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<ChatsRecord>? mychats;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ChatsRecord? newchat;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  PayOrderRecord? order;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
