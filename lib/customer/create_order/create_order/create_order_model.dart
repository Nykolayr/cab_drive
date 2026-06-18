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
import 'create_order_widget.dart' show CreateOrderWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CreateOrderModel extends FlutterFlowModel<CreateOrderWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadDataGw5 = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataGw5 = [];
  List<String> uploadedFileUrls_uploadDataGw5 = [];

  // Stores action output result for [Backend Call - Create Document] action in CREATE_ORDER widget.
  OrderRecord? neworderImage;
  // Stores action output result for [Firestore Query - Query a collection] action in CREATE_ORDER widget.
  List<UsersRecord>? listU;
  // Stores action output result for [Backend Call - Create Document] action in CREATE_ORDER widget.
  OrderRecord? neworder;
  // Stores action output result for [Firestore Query - Query a collection] action in CREATE_ORDER widget.
  List<UsersRecord>? listU2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
