import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/customer/net_zakazov_klient/net_zakazov_klient_widget.dart';
import '/customer/order_card_customer/order_card_customer_widget.dart';
import '/driver/net_zakazov_vodila/net_zakazov_vodila_widget.dart';
import '/driver/order_card_driver/order_card_driver_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'my_orders_widget.dart' show MyOrdersWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
