import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/chips_card/chips_card_widget.dart';
import 'dart:async';
import 'dart:ui';
import 'otmena_zakaza_widget.dart' show OtmenaZakazaWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OtmenaZakazaModel extends FlutterFlowModel<OtmenaZakazaWidget> {
  ///  Local state fields for this component.

  String? reason;

  ///  State fields for stateful widgets in this component.

  // Model for chips_card component.
  late ChipsCardModel chipsCardModel1;
  // Model for chips_card component.
  late ChipsCardModel chipsCardModel2;
  // Model for chips_card component.
  late ChipsCardModel chipsCardModel3;
  // Model for chips_card component.
  late ChipsCardModel chipsCardModel4;
  // Model for chips_card component.
  late ChipsCardModel chipsCardModel5;

  @override
  void initState(BuildContext context) {
    chipsCardModel1 = createModel(context, () => ChipsCardModel());
    chipsCardModel2 = createModel(context, () => ChipsCardModel());
    chipsCardModel3 = createModel(context, () => ChipsCardModel());
    chipsCardModel4 = createModel(context, () => ChipsCardModel());
    chipsCardModel5 = createModel(context, () => ChipsCardModel());
  }

  @override
  void dispose() {
    chipsCardModel1.dispose();
    chipsCardModel2.dispose();
    chipsCardModel3.dispose();
    chipsCardModel4.dispose();
    chipsCardModel5.dispose();
  }
}
