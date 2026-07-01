import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import 'dart:async';
import '/index.dart';
import 'main_driver_widget.dart' show MainDriverWidget;
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';

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
