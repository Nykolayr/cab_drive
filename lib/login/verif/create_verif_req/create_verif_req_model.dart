import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'create_verif_req_widget.dart' show CreateVerifReqWidget;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CreateVerifReqModel extends FlutterFlowModel<CreateVerifReqWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadData1tw = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadData1tw = [];
  List<String> uploadedFileUrls_uploadData1tw = [];

  // Stores action output result for [Firestore Query - Query a collection] action in Create_verif_req widget.
  int? count;
  // Stores action output result for [Backend Call - Create Document] action in Create_verif_req widget.
  RequestVereficationRecord? verif;
  // Stores action output result for [Firestore Query - Query a collection] action in Create_verif_req widget.
  UsersRecord? admin;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
