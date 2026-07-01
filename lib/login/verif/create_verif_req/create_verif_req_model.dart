import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'create_verif_req_widget.dart' show CreateVerifReqWidget;
import 'package:flutter/material.dart';

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
