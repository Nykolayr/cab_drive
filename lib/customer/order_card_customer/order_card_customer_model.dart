import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'order_card_customer_widget.dart' show OrderCardCustomerWidget;
import 'package:flutter/material.dart';

class OrderCardCustomerModel extends FlutterFlowModel<OrderCardCustomerWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<ChatsRecord>? mychats;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  ChatsRecord? newchat;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
