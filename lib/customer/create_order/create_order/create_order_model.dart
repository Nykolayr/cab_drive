import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'create_order_widget.dart' show CreateOrderWidget;
import 'package:flutter/material.dart';

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
