import '/flutter_flow/flutter_flow_util.dart';
import 'filters_widget.dart' show FiltersWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class FiltersModel extends FlutterFlowModel<FiltersWidget> {
  ///  Local state fields for this component.

  int supply = 0;

  ///  State fields for stateful widgets in this component.

  // State field(s) for ott widget.
  FocusNode? ottFocusNode;
  TextEditingController? ottTextController;
  late MaskTextInputFormatter ottMask;
  String? Function(BuildContext, String?)? ottTextControllerValidator;
  // State field(s) for doo widget.
  FocusNode? dooFocusNode;
  TextEditingController? dooTextController;
  late MaskTextInputFormatter dooMask;
  String? Function(BuildContext, String?)? dooTextControllerValidator;
  // State field(s) for Slider widget.
  double? sliderValue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    ottFocusNode?.dispose();
    ottTextController?.dispose();

    dooFocusNode?.dispose();
    dooTextController?.dispose();
  }
}
