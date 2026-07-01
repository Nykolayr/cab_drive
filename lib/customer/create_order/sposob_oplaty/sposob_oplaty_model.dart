import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/chips_card/chips_card_widget.dart';
import 'sposob_oplaty_widget.dart' show SposobOplatyWidget;
import 'package:flutter/material.dart';

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
