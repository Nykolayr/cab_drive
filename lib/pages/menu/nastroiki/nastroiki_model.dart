import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import 'nastroiki_widget.dart' show NastroikiWidget;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NastroikiModel extends FlutterFlowModel<NastroikiWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for app_bar component.
  late AppBarModel appBarModel;
  bool isDataUploading_uploadData2pb22 = false;
  FFUploadedFile uploadedLocalFile_uploadData2pb22 =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
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
