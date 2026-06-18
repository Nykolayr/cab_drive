import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/customer/order_menu_p_o_p_u_p/order_menu_p_o_p_u_p_widget.dart';
import '/customer/response/response_widget.dart';
import '/customer/responsed_detail/responsed_detail_widget.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/create_rewievs/create_rewievs_widget.dart';
import '/pages/bottom/image_view/image_view_widget.dart';
import '/pages/bottom/ratting/ratting_widget.dart';
import '/pages/bottom/text_info/text_info_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'order_page_customer_widget.dart' show OrderPageCustomerWidget;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class OrderPageCustomerModel extends FlutterFlowModel<OrderPageCustomerWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<ChatsRecord>? mychats;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ChatsRecord? newchat;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<ChatsRecord>? mychats2;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ChatsRecord? newchat2;
  // Model for text_info component.
  late TextInfoModel textInfoModel1;
  // Model for text_info component.
  late TextInfoModel textInfoModel2;
  // Model for text_info component.
  late TextInfoModel textInfoModel3;
  // Model for text_info component.
  late TextInfoModel textInfoModel4;
  // Model for text_info component.
  late TextInfoModel textInfoModel5;
  // Model for text_info component.
  late TextInfoModel textInfoModel6;
  // Model for text_info component.
  late TextInfoModel textInfoModel7;
  // Model for text_info component.
  late TextInfoModel textInfoModel8;
  // Model for text_info component.
  late TextInfoModel textInfoModel9;
  // Model for text_info component.
  late TextInfoModel textInfoModel10;
  // Model for text_info component.
  late TextInfoModel textInfoModel11;
  // Model for text_info component.
  late TextInfoModel textInfoModel12;
  // Model for text_info component.
  late TextInfoModel textInfoModel13;
  // Model for text_info component.
  late TextInfoModel textInfoModel14;
  // Model for text_info component.
  late TextInfoModel textInfoModel15;
  // Model for text_info component.
  late TextInfoModel textInfoModel16;
  // Model for text_info component.
  late TextInfoModel textInfoModel17;
  // Model for text_info component.
  late TextInfoModel textInfoModel18;
  // Model for text_info component.
  late TextInfoModel textInfoModel19;
  // Model for text_info component.
  late TextInfoModel textInfoModel20;
  // Model for text_info component.
  late TextInfoModel textInfoModel21;
  // Model for text_info component.
  late TextInfoModel textInfoModel22;

  @override
  void initState(BuildContext context) {
    textInfoModel1 = createModel(context, () => TextInfoModel());
    textInfoModel2 = createModel(context, () => TextInfoModel());
    textInfoModel3 = createModel(context, () => TextInfoModel());
    textInfoModel4 = createModel(context, () => TextInfoModel());
    textInfoModel5 = createModel(context, () => TextInfoModel());
    textInfoModel6 = createModel(context, () => TextInfoModel());
    textInfoModel7 = createModel(context, () => TextInfoModel());
    textInfoModel8 = createModel(context, () => TextInfoModel());
    textInfoModel9 = createModel(context, () => TextInfoModel());
    textInfoModel10 = createModel(context, () => TextInfoModel());
    textInfoModel11 = createModel(context, () => TextInfoModel());
    textInfoModel12 = createModel(context, () => TextInfoModel());
    textInfoModel13 = createModel(context, () => TextInfoModel());
    textInfoModel14 = createModel(context, () => TextInfoModel());
    textInfoModel15 = createModel(context, () => TextInfoModel());
    textInfoModel16 = createModel(context, () => TextInfoModel());
    textInfoModel17 = createModel(context, () => TextInfoModel());
    textInfoModel18 = createModel(context, () => TextInfoModel());
    textInfoModel19 = createModel(context, () => TextInfoModel());
    textInfoModel20 = createModel(context, () => TextInfoModel());
    textInfoModel21 = createModel(context, () => TextInfoModel());
    textInfoModel22 = createModel(context, () => TextInfoModel());
  }

  @override
  void dispose() {
    textInfoModel1.dispose();
    textInfoModel2.dispose();
    textInfoModel3.dispose();
    textInfoModel4.dispose();
    textInfoModel5.dispose();
    textInfoModel6.dispose();
    textInfoModel7.dispose();
    textInfoModel8.dispose();
    textInfoModel9.dispose();
    textInfoModel10.dispose();
    textInfoModel11.dispose();
    textInfoModel12.dispose();
    textInfoModel13.dispose();
    textInfoModel14.dispose();
    textInfoModel15.dispose();
    textInfoModel16.dispose();
    textInfoModel17.dispose();
    textInfoModel18.dispose();
    textInfoModel19.dispose();
    textInfoModel20.dispose();
    textInfoModel21.dispose();
    textInfoModel22.dispose();
  }
}
