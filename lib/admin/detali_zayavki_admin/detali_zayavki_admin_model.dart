import '/admin/orklonit/orklonit_widget.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import '/pages/bottom/image_view/image_view_widget.dart';
import '/pages/bottom/text_info/text_info_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'detali_zayavki_admin_widget.dart' show DetaliZayavkiAdminWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octo_image/octo_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class DetaliZayavkiAdminModel
    extends FlutterFlowModel<DetaliZayavkiAdminWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for app_bar component.
  late AppBarModel appBarModel;
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
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  ChatsRecord? chat;

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
    textInfoModel1 = createModel(context, () => TextInfoModel());
    textInfoModel2 = createModel(context, () => TextInfoModel());
    textInfoModel3 = createModel(context, () => TextInfoModel());
    textInfoModel4 = createModel(context, () => TextInfoModel());
    textInfoModel5 = createModel(context, () => TextInfoModel());
  }

  @override
  void dispose() {
    appBarModel.dispose();
    textInfoModel1.dispose();
    textInfoModel2.dispose();
    textInfoModel3.dispose();
    textInfoModel4.dispose();
    textInfoModel5.dispose();
  }
}
