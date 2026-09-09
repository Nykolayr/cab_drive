import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/file_storage_service.dart';
import '/backend/api/users_record_api.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'sms_chat_model.dart';
export 'sms_chat_model.dart';

class SmsChatWidget extends StatefulWidget {
  const SmsChatWidget({
    super.key,
    required this.chat,
  });

  final ChatsRecord? chat;

  @override
  State<SmsChatWidget> createState() => _SmsChatWidgetState();
}

class _SmsChatWidgetState extends State<SmsChatWidget> {
  late SmsChatModel _model;
  late final Future<UsersRecord?> _peerFuture;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SmsChatModel());
    _peerFuture = _loadPeer();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  DocumentReference? get _peerRef {
    final me = currentUserReference;
    final users = widget.chat?.users ?? const <DocumentReference>[];
    for (final u in users) {
      if (me == null || u.id != me.id) return u;
    }
    return null;
  }

  Future<UsersRecord?> _loadPeer() async {
    final peer = _peerRef;
    if (peer == null) return null;
    return UsersRecordApi.getOnce(peer);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UsersRecord?>(
      future: _peerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
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

        final peer = snapshot.data;
        final title = peer == null
            ? 'Чат'
            : '${peer.displayName} ${peer.surname}'.trim();
        final photoUrl = peer?.photoUrl ?? '';

        return InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.pushNamed(
              ChatWidget.routeName,
              queryParameters: {
                'chat': serializeParam(
                  widget.chat?.reference,
                  ParamType.DocumentReference,
                ),
                'name': serializeParam(title, ParamType.String),
              }.withoutNulls,
            );
          },
          child: Container(
            height: 108.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondary,
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 12.0, 0.0, 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: const Color(0x26A4A6B2),
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: photoUrl.isEmpty
                                ? Container(
                                    width: 60.0,
                                    height: 80.0,
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    child: Icon(
                                      Icons.person,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    fadeInDuration:
                                        const Duration(milliseconds: 5),
                                    fadeOutDuration:
                                        const Duration(milliseconds: 5),
                                    imageUrl:
                                        FileStorageService.getImageUrl(photoUrl),
                                    width: 60.0,
                                    height: 80.0,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                14.0, 0.0, 0.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'SF',
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    if (widget.chat?.dateCreated != null)
                                      Text(
                                        dateTimeFormat(
                                          'Hm',
                                          widget.chat!.dateCreated!,
                                          locale: FFLocalizations.of(context)
                                              .languageCode,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'SF',
                                              color: const Color(0xFFA4A6B2),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                  ],
                                ),
                                Text(
                                  widget.chat?.lastMessage ?? '',
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: const Color(0xFFA4A6B2),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ].divide(const SizedBox(height: 6.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
