import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import 'vkl_geo_copy_widget.dart' show VklGeoCopyWidget;
import 'package:flutter/material.dart';

class VklGeoCopyModel extends FlutterFlowModel<VklGeoCopyWidget> {
  ///  State fields for stateful widgets in this component.

  InstantTimer? instantTimer;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }
}
