import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/bottom/error_popup/error_popup_widget.dart';
import 'dart:ui';
import 'photo_vu_copy_widget.dart' show PhotoVuCopyWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class PhotoVuCopyModel extends FlutterFlowModel<PhotoVuCopyWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataG2013 = false;
  FFUploadedFile uploadedLocalFile_uploadDataG2013 =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataG2013 = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
