import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'izmenit_famil_widget.dart' show IzmenitFamilWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IzmenitFamilModel extends FlutterFlowModel<IzmenitFamilWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for famil widget.
  FocusNode? familFocusNode;
  TextEditingController? familTextController;
  String? Function(BuildContext, String?)? familTextControllerValidator;
  String? _familTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Обязательно для заполнения';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    familTextControllerValidator = _familTextControllerValidator;
  }

  @override
  void dispose() {
    familFocusNode?.dispose();
    familTextController?.dispose();
  }
}
