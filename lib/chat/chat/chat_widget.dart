import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/chat/chat_bar/chat_bar_widget.dart';
import '/chat/message_card/message_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_model.dart';
export 'chat_model.dart';

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

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                text: widget!.name!,
              ),
            ),
            Expanded(
              child: StreamBuilder<ChatsRecord>(
                stream: ChatsRecord.getDocument(widget!.chat!),
                builder: (context, snapshot) {
                  // Customize what your widget looks like when it's loading.
                  if (!snapshot.hasData) {
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

                  final containerChatsRecord = snapshot.data!;

                  return Container(
                    decoration: BoxDecoration(),
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
                              child: StreamBuilder<List<MessagesRecord>>(
                                stream: queryMessagesRecord(
                                  queryBuilder: (messagesRecord) =>
                                      messagesRecord
                                          .where(
                                            'chatRef',
                                            isEqualTo: widget!.chat,
                                          )
                                          .orderBy('date_created',
                                              descending: true),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  List<MessagesRecord>
                                      listViewMessagesRecordList =
                                      snapshot.data!;
                                  if (listViewMessagesRecordList.isEmpty) {
                                    return Center(
                                      child: Image.asset(
                                        'assets/images/freepik--Character--inject-2.png',
                                        width: 100.0,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  }

                                  return ListView.separated(
                                    padding: EdgeInsets.fromLTRB(
                                      0,
                                      18.0,
                                      0,
                                      18.0,
                                    ),
                                    reverse: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        listViewMessagesRecordList.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 12.0),
                                    itemBuilder: (context, listViewIndex) {
                                      final listViewMessagesRecord =
                                          listViewMessagesRecordList[
                                              listViewIndex];
                                      return wrapWithModel(
                                        model:
                                            _model.messageCardModels.getModel(
                                          listViewMessagesRecord.reference.id,
                                          listViewIndex,
                                        ),
                                        updateCallback: () =>
                                            safeSetState(() {}),
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
                              ),
                            ),
                          ),
                        ),
                        wrapWithModel(
                          model: _model.chatBarModel,
                          updateCallback: () => safeSetState(() {}),
                          child: ChatBarWidget(
                            chat: widget!.chat!,
                            user: containerChatsRecord.users
                                .where((e) => e.id != currentUserReference?.id)
                                .toList()
                                .firstOrNull!,
                          ),
                        ),
                      ].divide(SizedBox(height: 5.0)),
                    ),
                  );
                },
              ),
            ),
          ].divide(SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
