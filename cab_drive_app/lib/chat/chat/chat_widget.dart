import 'dart:async';

import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_chat_ws.dart';
import '/backend/api/app_me_api.dart';
import '/backend/backend.dart';
import '/chat/chat_bar/chat_bar_widget.dart';
import '/chat/message_card/message_card_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import 'chat_model.dart';
export 'chat_model.dart';

const _kSupportUid = 'MEkzqxquE2OqdVEZi4NrxZ9K8F03';

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
    required this.chat,
    required this.name,
  });

  final DocumentReference? chat;
  final String? name;

  static String routeName = 'Chat';
  static String routePath = '/chat';

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late ChatModel _model;
  late ChatsRecord _chatMeta;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatModel());
    _chatMeta = _syntheticChat();
    unawaited(_hydrateChatMeta());
  }

  bool get _isSupport => widget.name == 'Поддержка';

  ChatsRecord _syntheticChat({List<DocumentReference>? users}) {
    final me = currentUserReference;
    final List<DocumentReference> resolved;
    if (users != null) {
      resolved = users;
    } else if (me != null && _isSupport) {
      resolved = functions.listusers(me);
    } else if (me != null) {
      resolved = [me];
    } else {
      resolved = const [];
    }
    return ChatsRecord.getDocumentFromData(
      {
        ...createChatsRecordData(
          support: _isSupport,
          dateCreated: getCurrentTimestamp,
        ),
        'users': resolved,
      },
      widget.chat!,
    );
  }

  ChatsRecord _chatFromApi(Map<String, dynamic> m) {
    final id = m['id']?.toString() ?? widget.chat!.id;
    final users = (m['users'] is List)
        ? (m['users'] as List)
            .map((e) => UsersRecord.collection.doc(e.toString()))
            .toList()
        : <DocumentReference>[];
    final created = DateTime.tryParse(m['date_created']?.toString() ?? '') ??
        getCurrentTimestamp;
    return ChatsRecord.getDocumentFromData(
      {
        ...createChatsRecordData(
          lastMessage: m['last_message']?.toString() ?? '',
          dateCreated: created,
          support: m['support'] == true || _isSupport,
        ),
        'users': users.isNotEmpty
            ? users
            : (_chatMeta.users.isNotEmpty
                ? _chatMeta.users
                : (currentUserReference != null
                    ? functions.listusers(currentUserReference!)
                    : <DocumentReference>[])),
      },
      ChatsRecord.collection.doc(id),
    );
  }

  Future<void> _hydrateChatMeta() async {
    final chatId = widget.chat?.id;
    if (chatId == null || chatId.isEmpty) return;
    try {
      for (final support in <bool?>[null, true, false]) {
        final rows = await AppMeApi.listChats(support: support);
        Map<String, dynamic>? match;
        for (final e in rows) {
          if (e['id']?.toString() == chatId) {
            match = e;
            break;
          }
        }
        final found = match;
        if (found != null && mounted) {
          setState(() => _chatMeta = _chatFromApi(found));
          return;
        }
      }
    } catch (_) {}
  }

  DocumentReference? get _peerRef {
    final meId = currentUserReference?.id;
    final peers = _chatMeta.users.where((e) => e.id != meId).toList();
    if (peers.isNotEmpty) return peers.first;
    if (_isSupport) {
      return UsersRecord.collection.doc(_kSupportUid);
    }
    return null;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _messagesBody(ChatsRecord containerChatsRecord) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: AppChatWs.instance.watchMessages(widget.chat!.id),
      builder: (context, wsSnapshot) {
        final ready = AppChatWs.instance.historyReady(widget.chat!.id);
        if (!ready && !wsSnapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }

        final apiMsgs = wsSnapshot.data ?? const <Map<String, dynamic>>[];
        if (apiMsgs.isEmpty) {
          return Center(
            child: Image.asset(
              'assets/images/freepik--Character--inject-2.png',
              width: 100.0,
              fit: BoxFit.contain,
            ),
          );
        }

        final listViewMessagesRecordList = apiMsgs.map((m) {
          final id = m['id']?.toString() ?? '';
          final senderId = m['sender_id']?.toString() ?? '';
          final created =
              DateTime.tryParse(m['date_created']?.toString() ?? '') ??
                  getCurrentTimestamp;
          final imgs = (m['list_images'] is List)
              ? (m['list_images'] as List).map((e) => e.toString()).toList()
              : <String>[];
          return MessagesRecord.getDocumentFromData(
            {
              ...createMessagesRecordData(
                text: m['text']?.toString() ?? '',
                sender: UsersRecord.collection.doc(senderId),
                dateCreated: created,
                read: m['read'] == true,
                chatRef: widget.chat,
              ),
              'list_images': imgs,
            },
            MessagesRecord.collection.doc(id),
          );
        }).toList();

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(0, 18.0, 0, 18.0),
          reverse: true,
          scrollDirection: Axis.vertical,
          itemCount: listViewMessagesRecordList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12.0),
          itemBuilder: (context, listViewIndex) {
            final listViewMessagesRecord =
                listViewMessagesRecordList[listViewIndex];
            return wrapWithModel(
              model: _model.messageCardModels.getModel(
                listViewMessagesRecord.reference.id,
                listViewIndex,
              ),
              updateCallback: () => safeSetState(() {}),
              child: MessageCardWidget(
                key: Key(
                  'Keyt1h_${listViewMessagesRecord.reference.id}',
                ),
                messageDoc: listViewMessagesRecord,
                chat: containerChatsRecord,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final peer = _peerRef;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            wrapWithModel(
              model: _model.appBarModel,
              updateCallback: () => safeSetState(() {}),
              child: AppBarWidget(
                text: widget.name!,
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18.0),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          child: _messagesBody(_chatMeta),
                        ),
                      ),
                    ),
                    if (peer != null)
                      wrapWithModel(
                        model: _model.chatBarModel,
                        updateCallback: () => safeSetState(() {}),
                        child: ChatBarWidget(
                          chat: widget.chat!,
                          user: peer,
                        ),
                      ),
                  ].divide(const SizedBox(height: 5.0)),
                ),
              ),
            ),
          ].divide(const SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
