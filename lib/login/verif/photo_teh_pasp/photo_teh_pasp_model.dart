import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/bottom/error_popup/error_popup_widget.dart';
import 'dart:ui';
import 'photo_teh_pasp_widget.dart' show PhotoTehPaspWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class PhotoTehPaspModel extends FlutterFlowModel<PhotoTehPaspWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataG20114 = false;
  FFUploadedFile uploadedLocalFile_uploadDataG20114 =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataG20114 = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
