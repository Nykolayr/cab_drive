import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/driver/filters/filters_widget.dart';
import '/driver/net_poiska/net_poiska_widget.dart';
import '/driver/order_card_driver/order_card_driver_widget.dart';
import '/driver/vkl_geo_copy/vkl_geo_copy_widget.dart';
import '/driver/za_chto_plata_copy/za_chto_plata_copy_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/error_popup/error_popup_widget.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import 'main_driver_widget.dart' show MainDriverWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class MainDriverModel extends FlutterFlowModel<MainDriverWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Timer widget.
  final timerInitialTimeMs = 0;
  int timerMilliseconds = 0;
  String timerValue = StopWatchTimer.getDisplayTime(0, milliSecond: false);
  FlutterFlowTimerController timerController =
      FlutterFlowTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  // Model for navbar component.
  late NavbarModel navbarModel1;
  // Model for navbar component.
  late NavbarModel navbarModel2;

  @override
  void initState(BuildContext context) {
    navbarModel1 = createModel(context, () => NavbarModel());
    navbarModel2 = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    timerController.dispose();
    navbarModel1.dispose();
    navbarModel2.dispose();
  }

  /// Action blocks.
  Future searchAddress(BuildContext context) async {}
}
