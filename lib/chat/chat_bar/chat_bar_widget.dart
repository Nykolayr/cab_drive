import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/bottom/error_popup/error_popup_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'chat_bar_model.dart';
export 'chat_bar_model.dart';

class ChatBarWidget extends StatefulWidget {
  const ChatBarWidget({
    super.key,
    required this.chat,
    required this.user,
  });

  final DocumentReference? chat;
  final DocumentReference? user;

  @override
  State<ChatBarWidget> createState() => _ChatBarWidgetState();
}

class _ChatBarWidgetState extends State<ChatBarWidget> {
  late ChatBarModel _model;

  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatBarModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.textTextController ??= TextEditingController();
    _model.textFocusNode ??= FocusNode();
    _model.textFocusNode!.addListener(() => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
            12.0,
            8.0,
            12.0,
            valueOrDefault<double>(
              (isWeb
                      ? MediaQuery.viewInsetsOf(context).bottom > 0
                      : _isKeyboardVisible)
                  ? 8.0
                  : 50.0,
              50.0,
            )),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 8.0,
              buttonSize: 43.0,
              icon: Icon(
                FFIcons.kcameraPlus,
                color: Color(0xFF969EAB),
                size: 24.0,
              ),
              onPressed: () async {
                final selectedMedia = await selectMedia(
                  maxWidth: 500.00,
                  maxHeight: 500.00,
                  imageQuality: 95,
                  mediaSource: MediaSource.photoGallery,
                  multiImage: true,
                );
                if (selectedMedia != null &&
                    selectedMedia.every(
                        (m) => validateFileFormat(m.storagePath, context))) {
                  safeSetState(
                      () => _model.isDataUploading_uploadDataH1g2 = true);
                  var selectedUploadedFiles = <FFUploadedFile>[];

                  try {
                    selectedUploadedFiles = selectedMedia
                        .map((m) => FFUploadedFile(
                              name: m.storagePath.split('/').last,
                              bytes: m.bytes,
                              height: m.dimensions?.height,
                              width: m.dimensions?.width,
                              blurHash: m.blurHash,
                              originalFilename: m.originalFilename,
                            ))
                        .toList();
                  } finally {
                    _model.isDataUploading_uploadDataH1g2 = false;
                  }
                  if (selectedUploadedFiles.length == selectedMedia.length) {
                    safeSetState(() {
                      _model.uploadedLocalFiles_uploadDataH1g2 =
                          selectedUploadedFiles;
                    });
                  } else {
                    safeSetState(() {});
                    return;
                  }
                }

                if (_model.uploadedLocalFiles_uploadDataH1g2.isNotEmpty) {
                  if (_model.uploadedLocalFiles_uploadDataH1g2.length >
                      (10 - _model.images.length)) {
                    safeSetState(() {
                      _model.isDataUploading_uploadDataH1g2 = false;
                      _model.uploadedLocalFiles_uploadDataH1g2 = [];
                    });

                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return WebViewAware(
                          child: Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: ErrorPopupWidget(
                              title: 'Что-то пошло не так',
                              text: 'Максимальное количество изображений - 10!',
                            ),
                          ),
                        );
                      },
                    ).then((value) => safeSetState(() {}));

                    return;
                  } else {
                    if (_model.images.length == 0) {
                      _model.images = _model.uploadedLocalFiles_uploadDataH1g2
                          .toList()
                          .cast<FFUploadedFile>();
                      safeSetState(() {});
                      return;
                    } else {
                      _model.images = functions
                          .myCustomFileFunction(_model.images.toList(),
                              _model.uploadedLocalFiles_uploadDataH1g2.toList())
                          .toList()
                          .cast<FFUploadedFile>();
                      safeSetState(() {});
                      return;
                    }
                  }
                } else {
                  return;
                }
              },
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_model.images.isNotEmpty)
                        Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 8.0, 0.0, 0.0),
                            child: Builder(
                              builder: (context) {
                                final im = _model.images.toList();

                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children:
                                        List.generate(im.length, (imIndex) {
                                      final imItem = im[imIndex];
                                      return Stack(
                                        alignment:
                                            AlignmentDirectional(1.0, -1.0),
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            child: Image.memory(
                                              imItem.bytes ??
                                                  Uint8List.fromList([]),
                                              width: 60.0,
                                              height: 80.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          FlutterFlowIconButton(
                                            borderColor: Colors.transparent,
                                            borderRadius: 12.0,
                                            buttonSize: 50.0,
                                            fillColor: Color(0x69161616),
                                            icon: Icon(
                                              FFIcons.kkrestStroke,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              size: 14.0,
                                            ),
                                            onPressed: () async {
                                              _model.removeFromImages(imItem);
                                              safeSetState(() {});
                                            },
                                          ),
                                        ],
                                      );
                                    })
                                            .divide(SizedBox(width: 8.0))
                                            .addToStart(SizedBox(width: 20.0))
                                            .addToEnd(SizedBox(width: 20.0)),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _model.textTextController,
                                  focusNode: _model.textFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.textTextController',
                                    Duration(milliseconds: 0),
                                    () => safeSetState(() {}),
                                  ),
                                  autofocus: false,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.go,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Написать сообщение...',
                                    hintStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                          color: Color(0xFF969EAB),
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding:
                                        EdgeInsetsDirectional.fromSTEB(
                                            20.0, 16.0, 0.0, 16.0),
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  maxLines: 7,
                                  minLines: 1,
                                  cursorColor:
                                      FlutterFlowTheme.of(context).primaryText,
                                  validator: _model.textTextControllerValidator
                                      .asValidator(context),
                                  inputFormatters: [
                                    if (!isAndroid && !isiOS)
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        return TextEditingValue(
                                          selection: newValue.selection,
                                          text: newValue.text.toCapitalization(
                                              TextCapitalization.sentences),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                            if ((_model.images.isNotEmpty) ||
                                (_model.textTextController.text != null &&
                                    _model.textTextController.text != ''))
                              FlutterFlowIconButton(
                                borderColor: Colors.transparent,
                                borderRadius: 12.0,
                                buttonSize: 43.0,
                                fillColor:
                                    FlutterFlowTheme.of(context).tertiary,
                                icon: Icon(
                                  Icons.arrow_upward,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  size: 18.0,
                                ),
                                onPressed: () async {
                                  if (_model.images.isNotEmpty) {
                                    {
                                      safeSetState(() =>
                                          _model.isDataUploading_uploadDataLms =
                                              true);
                                      var selectedUploadedFiles =
                                          <FFUploadedFile>[];
                                      var selectedMedia = <SelectedFile>[];
                                      var downloadUrls = <String>[];
                                      try {
                                        selectedUploadedFiles = _model.images;
                                        selectedMedia =
                                            selectedFilesFromUploadedFiles(
                                          selectedUploadedFiles,
                                          isMultiData: true,
                                        );
                                        downloadUrls = (await Future.wait(
                                          selectedMedia.map(
                                            (m) async => await uploadData(
                                                m.storagePath, m.bytes),
                                          ),
                                        ))
                                            .where((u) => u != null)
                                            .map((u) => u!)
                                            .toList();
                                      } finally {
                                        _model.isDataUploading_uploadDataLms =
                                            false;
                                      }
                                      if (selectedUploadedFiles.length ==
                                              selectedMedia.length &&
                                          downloadUrls.length ==
                                              selectedMedia.length) {
                                        safeSetState(() {
                                          _model.uploadedLocalFiles_uploadDataLms =
                                              selectedUploadedFiles;
                                          _model.uploadedFileUrls_uploadDataLms =
                                              downloadUrls;
                                        });
                                      } else {
                                        safeSetState(() {});
                                        return;
                                      }
                                    }

                                    var messagesRecordReference1 =
                                        MessagesRecord.collection.doc();
                                    await messagesRecordReference1.set({
                                      ...createMessagesRecordData(
                                        text: _model.textTextController.text,
                                        sender: currentUserReference,
                                        dateCreated: getCurrentTimestamp,
                                        read: false,
                                        chatRef: widget!.chat,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'list_images': _model
                                              .uploadedFileUrls_uploadDataLms,
                                        },
                                      ),
                                    });
                                    _model.newmess2 =
                                        MessagesRecord.getDocumentFromData({
                                      ...createMessagesRecordData(
                                        text: _model.textTextController.text,
                                        sender: currentUserReference,
                                        dateCreated: getCurrentTimestamp,
                                        read: false,
                                        chatRef: widget!.chat,
                                      ),
                                      ...mapToFirestore(
                                        {
                                          'list_images': _model
                                              .uploadedFileUrls_uploadDataLms,
                                        },
                                      ),
                                    }, messagesRecordReference1);
                                    unawaited(
                                      () async {
                                        await widget!.chat!
                                            .update(createChatsRecordData(
                                          lastMessage: _model.newmess2?.text !=
                                                      null &&
                                                  _model.newmess2?.text != ''
                                              ? _model.newmess2?.text
                                              : (_model.newmess2!.listImages
                                                          .length >
                                                      1
                                                  ? '${_model.newmess2?.listImages?.length?.toString()} фото'
                                                  : 'Фотография'),
                                          dateCreated: getCurrentTimestamp,
                                        ));
                                      }(),
                                    );
                                    safeSetState(() {
                                      _model.textTextController?.clear();
                                    });
                                    triggerPushNotification(
                                      notificationTitle:
                                          '${currentUserDisplayName} ${valueOrDefault(currentUserDocument?.surname, '')}',
                                      notificationText: _model.newmess2?.text !=
                                                  null &&
                                              _model.newmess2?.text != ''
                                          ? _model.newmess2!.text
                                          : (_model.newmess2!.listImages
                                                      .length >
                                                  1
                                              ? '${_model.newmess2?.listImages?.length?.toString()} фото'
                                              : 'Фотография'),
                                      notificationImageUrl: currentUserPhoto,
                                      notificationSound: 'default',
                                      userRefs: [widget!.user!],
                                      initialPageName: 'Chat',
                                      parameterData: {
                                        'chat': widget!.chat,
                                        'name':
                                            '${currentUserDisplayName} ${valueOrDefault(currentUserDocument?.surname, '')}',
                                      },
                                    );
                                    _model.images = [];
                                    safeSetState(() {});
                                    safeSetState(() {
                                      _model.isDataUploading_uploadDataLms =
                                          false;
                                      _model.uploadedLocalFiles_uploadDataLms =
                                          [];
                                      _model.uploadedFileUrls_uploadDataLms =
                                          [];
                                    });

                                    safeSetState(() {
                                      _model.isDataUploading_uploadDataH1g2 =
                                          false;
                                      _model.uploadedLocalFiles_uploadDataH1g2 =
                                          [];
                                    });
                                  } else {
                                    var messagesRecordReference2 =
                                        MessagesRecord.collection.doc();
                                    await messagesRecordReference2
                                        .set(createMessagesRecordData(
                                      text: _model.textTextController.text,
                                      sender: currentUserReference,
                                      dateCreated: getCurrentTimestamp,
                                      read: false,
                                      chatRef: widget!.chat,
                                    ));
                                    _model.newmess =
                                        MessagesRecord.getDocumentFromData(
                                            createMessagesRecordData(
                                              text: _model
                                                  .textTextController.text,
                                              sender: currentUserReference,
                                              dateCreated: getCurrentTimestamp,
                                              read: false,
                                              chatRef: widget!.chat,
                                            ),
                                            messagesRecordReference2);
                                    unawaited(
                                      () async {
                                        await widget!.chat!
                                            .update(createChatsRecordData(
                                          lastMessage: _model.newmess?.text,
                                          dateCreated:
                                              _model.newmess?.dateCreated,
                                        ));
                                      }(),
                                    );
                                    safeSetState(() {
                                      _model.textTextController?.clear();
                                    });
                                    triggerPushNotification(
                                      notificationTitle:
                                          '${currentUserDisplayName} ${valueOrDefault(currentUserDocument?.surname, '')}',
                                      notificationText: _model.newmess!.text,
                                      notificationImageUrl: currentUserPhoto,
                                      notificationSound: 'default',
                                      userRefs: [widget!.user!],
                                      initialPageName: 'Chat',
                                      parameterData: {
                                        'chat': widget!.chat,
                                        'name':
                                            '${currentUserDisplayName} ${valueOrDefault(currentUserDocument?.surname, '')}',
                                      },
                                    );
                                  }

                                  safeSetState(() {});
                                },
                              ),
                          ].divide(SizedBox(width: 12.0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
