import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/login/delete1/delete1_widget.dart';
import '/login/exit/exit_widget.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import '/pages/menu/izmenit_famil/izmenit_famil_widget.dart';
import '/pages/menu/izmenit_imya/izmenit_imya_widget.dart';
import '/pages/menu/izmenit_pochtu/izmenit_pochtu_widget.dart';
import 'dart:async';
import 'dart:ui';
import 'nastroiki_widget.dart' show NastroikiWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class NastroikiModel extends FlutterFlowModel<NastroikiWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for app_bar component.
  late AppBarModel appBarModel;
  bool isDataUploading_uploadData2pb22 = false;
  FFUploadedFile uploadedLocalFile_uploadData2pb22 =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadData2pb22 = '';

  // Stores action output result for [Bottom Sheet - izmenit_imya] action in Stack widget.
  String? newName;
  // State field(s) for nameInput2 widget.
  FocusNode? nameInput2FocusNode;
  TextEditingController? nameInput2TextController;
  String? Function(BuildContext, String?)? nameInput2TextControllerValidator;
  // State field(s) for nameInput widget.
  FocusNode? nameInputFocusNode;
  TextEditingController? nameInputTextController;
  String? Function(BuildContext, String?)? nameInputTextControllerValidator;
  DateTime? datePicked;
  // State field(s) for dtbInput widget.
  FocusNode? dtbInputFocusNode;
  TextEditingController? dtbInputTextController;
  String? Function(BuildContext, String?)? dtbInputTextControllerValidator;
  // State field(s) for emailInput widget.
  FocusNode? emailInputFocusNode;
  TextEditingController? emailInputTextController;
  String? Function(BuildContext, String?)? emailInputTextControllerValidator;

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
  }

  @override
  void dispose() {
    appBarModel.dispose();
    nameInput2FocusNode?.dispose();
    nameInput2TextController?.dispose();

    nameInputFocusNode?.dispose();
    nameInputTextController?.dispose();

    dtbInputFocusNode?.dispose();
    dtbInputTextController?.dispose();

    emailInputFocusNode?.dispose();
    emailInputTextController?.dispose();
  }
}
