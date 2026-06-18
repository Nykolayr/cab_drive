import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/customer/pay_add_card/pay_add_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/chips_card/chips_card_widget.dart';
import 'dart:async';
import 'dart:ui';
import 'sposob_oplaty_widget.dart' show SposobOplatyWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class SposobOplatyModel extends FlutterFlowModel<SposobOplatyWidget> {
  ///  Local state fields for this component.

  String select = 'Наличные';

  PayMethod? type;

  SavedCardsRecord? card;

  ///  State fields for stateful widgets in this component.

  // Model for chips_card component.
  late ChipsCardModel chipsCardModel1;
  // Model for chips_card component.
  late ChipsCardModel chipsCardModel2;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  PayOrderRecord? order;

  @override
  void initState(BuildContext context) {
    chipsCardModel1 = createModel(context, () => ChipsCardModel());
    chipsCardModel2 = createModel(context, () => ChipsCardModel());
  }

  @override
  void dispose() {
    chipsCardModel1.dispose();
    chipsCardModel2.dispose();
  }
}
