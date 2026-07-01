import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import 'vkl_geo_widget.dart' show VklGeoWidget;
import 'package:flutter/material.dart';

class VklGeoModel extends FlutterFlowModel<VklGeoWidget> {
  ///  State fields for stateful widgets in this component.

  InstantTimer? instantTimer;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }
}
