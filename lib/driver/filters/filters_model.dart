import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'filters_widget.dart' show FiltersWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

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
