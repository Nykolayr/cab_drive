import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import '/pages/bottom/text_info/text_info_widget.dart';
import '/index.dart';
import 'detali_zayavki_admin_widget.dart' show DetaliZayavkiAdminWidget;
import 'package:flutter/material.dart';

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
