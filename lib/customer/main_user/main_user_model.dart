import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import '/index.dart';
import 'main_user_widget.dart' show MainUserWidget;
import 'package:flutter/material.dart';

class MainUserModel extends FlutterFlowModel<MainUserWidget> {
  ///  Local state fields for this page.

  Car? car = Car.largus;

  ///  State fields for stateful widgets in this page.

  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();
  // Model for navbar component.
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel.dispose();
  }

  /// Action blocks.
  Future searchAddress(BuildContext context) async {}
}
