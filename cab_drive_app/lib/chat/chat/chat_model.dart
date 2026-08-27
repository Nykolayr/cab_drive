import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/chat/chat_bar/chat_bar_widget.dart';
import '/chat/message_card/message_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import 'dart:ui';
import 'chat_widget.dart' show ChatWidget;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
