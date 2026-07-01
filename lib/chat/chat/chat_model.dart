import '/chat/chat_bar/chat_bar_widget.dart';
import '/chat/message_card/message_card_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import 'chat_widget.dart' show ChatWidget;
import 'package:flutter/material.dart';

class ChatModel extends FlutterFlowModel<ChatWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for app_bar component.
  late AppBarModel appBarModel;
  // Models for message_card dynamic component.
  late FlutterFlowDynamicModels<MessageCardModel> messageCardModels;
  // Model for chat_bar component.
  late ChatBarModel chatBarModel;

  @override
  void initState(BuildContext context) {
    appBarModel = createModel(context, () => AppBarModel());
    messageCardModels = FlutterFlowDynamicModels(() => MessageCardModel());
    chatBarModel = createModel(context, () => ChatBarModel());
  }

  @override
  void dispose() {
    appBarModel.dispose();
    messageCardModels.dispose();
    chatBarModel.dispose();
  }
}
