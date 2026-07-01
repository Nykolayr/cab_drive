import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'responsed_detail_widget.dart' show ResponsedDetailWidget;
import 'package:flutter/material.dart';

class ResponsedDetailModel extends FlutterFlowModel<ResponsedDetailWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<ChatsRecord>? mychats;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ChatsRecord? newchat;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  PayOrderRecord? order;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
