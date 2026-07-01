import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'LOGIN';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 120.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18.0),
                      bottomRight: Radius.circular(18.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (responsiveVisibility(
                        context: context,
                        phone: false,
                      ))
                        FFButtonWidget(
                          onPressed: () async {
                            FFAppState().phone = _model.phone!;
                            safeSetState(() {});
                            GoRouter.of(context).prepareAuthEvent();

                            final user = await authManager.signInWithEmail(
                              context,
                              '${FFAppState().phone}@ydrive.appwave.com',
                              '${FFAppState().phone}@ydrive.appwave.com',
                            );
                            if (user == null) {
                              return;
                            }

                            context.goNamedAuth(
                                LoadWidget.routeName, context.mounted);
                          },
                          text: 'войти',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).tertiary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'SF',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      if (responsiveVisibility(
                        context: context,
                        phone: false,
                      ))
                        FFButtonWidget(
                          onPressed: () async {
                            FFAppState().phone = _model.phone!;
                            safeSetState(() {});
                            GoRouter.of(context).prepareAuthEvent();

                            final user =
                                await authManager.createAccountWithEmail(
                              context,
                              '${FFAppState().phone}@ydrive.appwave.com',
                              '${FFAppState().phone}@ydrive.appwave.com',
                            );
                            if (user == null) {
                              return;
                            }

                            await UsersRecord.collection
                                .doc(user.uid)
                                .update(createUsersRecordData(
                                  phoneNumber: FFAppState().phone,
                                  photoUrl:
                                      'https://firebasestorage.googleapis.com/v0/b/underworking-aq2ijs.appspot.com/o/group_1171274713.webp?alt=media&token=7191e1ad-858e-46dd-baac-19367b969bcf',
                                ));

                            var chatsRecordReference =
                                ChatsRecord.collection.doc();
                            await chatsRecordReference.set({
                              ...createChatsRecordData(
                                dateCreated: getCurrentTimestamp,
                                support: true,
                              ),
                              ...mapToFirestore(
                                {
                                  'users': functions
                                      .combineUsers2(currentUserReference!),
                                },
                              ),
                            });
                            _model.chatWithSupport =
                                ChatsRecord.getDocumentFromData({
                              ...createChatsRecordData(
                                dateCreated: getCurrentTimestamp,
                                support: true,
                              ),
                              ...mapToFirestore(
                                {
                                  'users': functions
                                      .combineUsers2(currentUserReference!),
                                },
                              ),
                            }, chatsRecordReference);

                            await currentUserReference!
                                .update(createUsersRecordData(
                              chatWithSupport:
                                  _model.chatWithSupport?.reference,
                            ));

                            context.goNamedAuth(
                              GeoWidget.routeName,
                              context.mounted,
                              queryParameters: {
                                'home': serializeParam(
                                  2,
                                  ParamType.int,
                                ),
                              }.withoutNulls,
                            );

                            safeSetState(() {});
                          },
                          text: 'Создать акк',
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).tertiary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'SF',
                                  color: FlutterFlowTheme.of(context).primary,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                    ].divide(SizedBox(width: 22.0)),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(8.0, 32.0, 8.0, 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          child: Text(
                            'Войти или создать профиль',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  fontSize: 30.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                  lineHeight: 1.25,
                                ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 24.0, 16.0, 0.0),
                          child: Text(
                            'Введите номер телефона чтобы, войти или зарегестрироваться ',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  color: Color(0xFFA4A6B2),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  lineHeight: 1.467,
                                ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 8.0, 16.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            height: 50.0,
                            child: custom_widgets.PhoneInputWidget(
                              width: double.infinity,
                              height: 50.0,
                              callback: (phone) async {
                                _model.phone = phone;
                                safeSetState(() {});
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 0.0, 0.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              var _shouldSetState = false;
                              if ((_model.phone == '79855098135') ||
                                  (_model.phone == '79097492934')) {
                                FFAppState().phone = _model.phone!;
                                safeSetState(() {});
                                GoRouter.of(context).prepareAuthEvent();

                                final user = await authManager.signInWithEmail(
                                  context,
                                  '${FFAppState().phone}@ydrive.appwave.com',
                                  '${FFAppState().phone}@ydrive.appwave.com',
                                );
                                if (user == null) {
                                  return;
                                }

                                context.goNamedAuth(
                                    LoadWidget.routeName, context.mounted);
                              } else {
                                FFAppState().phone = _model.phone!;
                                FFAppState().OTP = formatNumber(
                                  random_data.randomInteger(1111, 9999),
                                  formatType: FormatType.custom,
                                  format: '0000',
                                  locale: '',
                                );
                                FFAppState().Password = formatNumber(
                                  random_data.randomInteger(000000, 999999),
                                  formatType: FormatType.custom,
                                  format: '000000',
                                  locale: '',
                                );
                                safeSetState(() {});
                                await ApSmsCall.call(
                                  receiver: FFAppState().phone,
                                  msgdata:
                                      'Ваш код подтверждения: ${FFAppState().OTP}',
                                );

                                _model.countUsers = await queryUsersRecordCount(
                                  queryBuilder: (usersRecord) =>
                                      usersRecord.where(
                                    'email',
                                    isEqualTo:
                                        '${FFAppState().phone}@ydrive.appwave.com',
                                  ),
                                );
                                _shouldSetState = true;
                                if (_model.countUsers! > 0) {
                                  context.pushNamedAuth(
                                    OtpLoginWidget.routeName,
                                    context.mounted,
                                    queryParameters: {
                                      'phone': serializeParam(
                                        FFAppState().phone,
                                        ParamType.String,
                                      ),
                                      'otp': serializeParam(
                                        FFAppState().OTP,
                                        ParamType.String,
                                      ),
                                      'password': serializeParam(
                                        FFAppState().Password,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );

                                  if (_shouldSetState) safeSetState(() {});
                                  return;
                                } else {
                                  context.pushNamedAuth(
                                    OtpWidget.routeName,
                                    context.mounted,
                                    queryParameters: {
                                      'phone': serializeParam(
                                        FFAppState().phone,
                                        ParamType.String,
                                      ),
                                      'otp': serializeParam(
                                        FFAppState().OTP,
                                        ParamType.String,
                                      ),
                                      'password': serializeParam(
                                        FFAppState().Password,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                  );

                                  if (_shouldSetState) safeSetState(() {});
                                  return;
                                }
                              }

                              if (_shouldSetState) safeSetState(() {});
                            },
                            text: 'Войти',
                            options: FFButtonOptions(
                              width: double.infinity,
                              height: 56.0,
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).tertiary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'SF',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            showLoadingIndicator: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!(isWeb
                    ? MediaQuery.viewInsetsOf(context).bottom > 0
                    : _isKeyboardVisible))
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await launchURL(getRemoteConfigString('poll'));
                      },
                      child: RichText(
                        textScaler: MediaQuery.of(context).textScaler,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Нажимая кнопку “Войти”, вы принимаете условия ',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'SF',
                                    color: Color(0xFFA4A6B2),
                                    letterSpacing: 0.0,
                                  ),
                            ),
                            TextSpan(
                              text: 'Политики конфиденциальности',
                              style: TextStyle(),
                            )
                          ],
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SF',
                                    letterSpacing: 0.0,
                                  ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ].divide(SizedBox(height: 5.0)),
            ),
          ],
        ),
      ),
    );
  }
}
