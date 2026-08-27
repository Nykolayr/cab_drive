import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import '/index.dart';
import 'main_user_widget.dart' show MainUserWidget;
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MainUserModel extends FlutterFlowModel<MainUserWidget> {
  ///  Local state fields for this page.

  Car? car = Car.largus;

  ///  State fields for stateful widgets in this page.

  LatLng? mapCenter;
  YandexMapController? yandexMapController;
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
