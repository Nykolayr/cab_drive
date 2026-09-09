import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/backend.dart';
import '/chat/chat/chat_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Открыть чат с поддержкой (PG ensure).
Future<void> openSupportChat(BuildContext context) async {
  DocumentReference? chatRef;
  final apiId = await AppMeApi.ensureSupportChat();
  if (apiId != null && apiId.isNotEmpty) {
    chatRef = ChatsRecord.collection.doc(apiId);
    currentUserDocument?.chatWithSupport = chatRef;
  } else if (currentUserDocument?.chatWithSupport != null) {
    chatRef = currentUserDocument!.chatWithSupport;
  }

  if (!context.mounted || chatRef == null) return;
  context.pushNamed(
    ChatWidget.routeName,
    queryParameters: {
      'chat': serializeParam(chatRef, ParamType.DocumentReference),
      'name': serializeParam('Поддержка', ParamType.String),
    }.withoutNulls,
  );
}

/// Открыть peer-чат с водителем/клиентом.
Future<void> openPeerChat(
  BuildContext context, {
  required String peerUid,
  required String name,
}) async {
  final apiId = await AppMeApi.ensurePeerChat(peerUid);
  if (apiId == null || apiId.isEmpty) return;
  final chatRef = ChatsRecord.collection.doc(apiId);

  if (!context.mounted) return;
  context.pushNamed(
    ChatWidget.routeName,
    queryParameters: {
      'chat': serializeParam(chatRef, ParamType.DocumentReference),
      'name': serializeParam(name, ParamType.String),
    }.withoutNulls,
  );
}
