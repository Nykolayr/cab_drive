import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/chips_card/chips_card_widget.dart';
import 'rate_app_widget.dart' show RateAppWidget;
import 'package:flutter/material.dart';

class RateAppModel extends FlutterFlowModel<RateAppWidget> {
  ///  Local state fields for this component.

  String? chips;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
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
  // State field(s) for nameInput widget.
  FocusNode? nameInputFocusNode;
  TextEditingController? nameInputTextController;
  String? Function(BuildContext, String?)? nameInputTextControllerValidator;
  String? _nameInputTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Напишите хотя бы пару слов';
    }

    if (val.length < 3) {
      return 'Напишите хотя бы пару слов';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    chipsCardModel1 = createModel(context, () => ChipsCardModel());
    chipsCardModel2 = createModel(context, () => ChipsCardModel());
    chipsCardModel3 = createModel(context, () => ChipsCardModel());
    chipsCardModel4 = createModel(context, () => ChipsCardModel());
    chipsCardModel5 = createModel(context, () => ChipsCardModel());
    nameInputTextControllerValidator = _nameInputTextControllerValidator;
  }

  @override
  void dispose() {
    chipsCardModel1.dispose();
    chipsCardModel2.dispose();
    chipsCardModel3.dispose();
    chipsCardModel4.dispose();
    chipsCardModel5.dispose();
    nameInputFocusNode?.dispose();
    nameInputTextController?.dispose();
  }
}
