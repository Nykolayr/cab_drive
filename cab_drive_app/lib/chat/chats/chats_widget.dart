import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/backend.dart';
import '/chat/net_chatov/net_chatov_widget.dart';
import '/chat/sms_chat/sms_chat_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import 'chats_model.dart';
export 'chats_model.dart';

class ChatsWidget extends StatefulWidget {
  const ChatsWidget({super.key});

  static String routeName = 'Chats';
  static String routePath = '/chats';

  @override
  State<ChatsWidget> createState() => _ChatsWidgetState();
}

class _ChatsWidgetState extends State<ChatsWidget> {
  late ChatsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _poll;
  List<ChatsRecord>? _chats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatsModel());
    unawaited(_reload());
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _reload());
  }

  Future<void> _reload() async {
    final rows = await AppMeApi.listChats(support: false);
    if (!mounted) return;
    final mapped = rows.map(_chatFromApi).toList();
    setState(() {
      _chats = mapped;
      _loading = false;
    });
  }

  ChatsRecord _chatFromApi(Map<String, dynamic> m) {
    final id = m['id']?.toString() ?? '';
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
          support: m['support'] == true,
        ),
        'users': users,
      },
      ChatsRecord.collection.doc(id),
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18.0),
                  bottomRight: Radius.circular(18.0),
                ),
              ),
              child: Align(
                alignment: const AlignmentDirectional(-1.0, 1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 18.0),
                  child: Text(
                    'Чаты',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          fontSize: 28.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: _loading && _chats == null
                      ? Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        )
                      : (_chats == null || _chats!.isEmpty)
                          ? NetChatovWidget()
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _chats!.length,
                              itemBuilder: (context, index) {
                                final chat = _chats![index];
                                return SmsChatWidget(
                                  key: Key('Keyed9_${index}_${chat.reference.id}'),
                                  chat: chat,
                                );
                              },
                            ),
                ),
              ),
            ),
            wrapWithModel(
              model: _model.navbarModel,
              updateCallback: () => safeSetState(() {}),
              child: const NavbarWidget(index: 1),
            ),
          ].divide(const SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
