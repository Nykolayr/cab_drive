import '/admin/navbar_admin/navbar_admin_widget.dart';
import '/backend/backend.dart';
import '/chat/sms_chat/sms_chat_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'chat_admin_model.dart';
export 'chat_admin_model.dart';

class ChatAdminWidget extends StatefulWidget {
  const ChatAdminWidget({super.key});

  static String routeName = 'Chat_Admin';
  static String routePath = '/chatAdmin';

  @override
  State<ChatAdminWidget> createState() => _ChatAdminWidgetState();
}

class _ChatAdminWidgetState extends State<ChatAdminWidget> {
  late ChatAdminModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatAdminModel());
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
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0, 0.0, 0.0, 18.0),
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
            Expanded(
              child: StreamBuilder<List<ChatsRecord>>(
                stream: queryChatsRecord(
                  queryBuilder: (chatsRecord) => chatsRecord.where(
                    'support',
                    isEqualTo: true,
                  ),
                ),
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
                  List<ChatsRecord> containerChatsRecordList = snapshot.data!;

                  return Container(
                    decoration: const BoxDecoration(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.0),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Builder(
                          builder: (context) {
                            final containerVar = containerChatsRecordList
                                .where((e) => e.lastMessage != '')
                                .toList();

                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                19.0,
                                0,
                                120.0,
                              ),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: containerVar.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 11.0),
                              itemBuilder: (context, containerVarIndex) {
                                final containerVarItem =
                                    containerVar[containerVarIndex];
                                return SmsChatWidget(
                                  key: Key(
                                      'Keyf3t_${containerVarIndex}_of_${containerVar.length}'),
                                  chat: containerVarItem,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            wrapWithModel(
              model: _model.navbarAdminModel,
              updateCallback: () => safeSetState(() {}),
              child: const NavbarAdminWidget(
                index: 1,
              ),
            ),
          ].divide(const SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
