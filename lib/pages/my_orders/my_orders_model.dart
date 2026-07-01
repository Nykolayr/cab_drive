import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import '/index.dart';
import 'my_orders_widget.dart' show MyOrdersWidget;
import 'package:flutter/material.dart';

class MyOrdersModel extends FlutterFlowModel<MyOrdersWidget> {
  ///  Local state fields for this page.

  int index = 1;

  ///  State fields for stateful widgets in this page.

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
}
