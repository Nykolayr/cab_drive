import '/flutter_flow/flutter_flow_util.dart';
import 'new_card_widget.dart' show NewCardWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class NewCardModel extends FlutterFlowModel<NewCardWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for NameInput widget.
  FocusNode? nameInputFocusNode;
  TextEditingController? nameInputTextController;
  late MaskTextInputFormatter nameInputMask;
  String? Function(BuildContext, String?)? nameInputTextControllerValidator;
  String? _nameInputTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Поле должно содержать от 16 символов';
    }

    if (val.length < 19) {
      return 'Поле должно содержать от 16 символов';
    }
    if (val.length > 22) {
      return 'Поле должно содержать до 19 символов';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    nameInputTextControllerValidator = _nameInputTextControllerValidator;
  }

  @override
  void dispose() {
    nameInputFocusNode?.dispose();
    nameInputTextController?.dispose();
  }
}
