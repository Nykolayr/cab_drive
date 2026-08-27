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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget_ extends StatefulWidget {
  const LoginWidget_({super.key});

  static String routeName = 'LOGIN';
  static String routePath = '/login';

  @override
  State<LoginWidget_> createState() => _LoginWidget_State();
}

class _LoginWidget_State extends State<LoginWidget_> {
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
        setState(() {
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
                      topLeft: Radius.circular(0.0),
                      topRight: Radius.circular(0.0),
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
                            try {
                              setState(() {});
                              final user = await authManager.signInWithEmail(
                                context,
                                _model.email!,
                                _model.password!,
                              );
                              if (user == null) {
                                return;
                              }

                              context.goNamedAuth(
                                  LoadWidget.routeName, context.mounted);
                            } catch(_) {
                              rethrow;
                            }
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
                            setState(() {});

                            final user =
                                await authManager.createAccountWithEmail(
                              context,
                              _model.email!,
                              _model.password!,
                            );
                            if (user == null) {
                              return;
                            }

                            await UsersRecord.collection
                                .doc(user.uid)
                                .update(createUsersRecordData(
                                  email: _model.email,
                                  // другие данные
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

                            setState(() {});
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

                SizedBox(height: 8,),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        color: Colors.white
                    ),
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.0, 8.0, 16.0, 0.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 16.0, 0.0),
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
                              0.0, 24.0, 16.0, 0.0),
                          child: Text(
                            'Введите email чтобы, войти или зарегестрироваться ',
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
                        Container(

                          width: double.infinity,
                          child: Column(
                            children: [
                              TextField(
                                onChanged: (value) {
                                  _model.email = value;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                ),
                              ),
                              TextField(
                                onChanged: (value) {
                                  _model.password = value;
                                },
                                obscureText: true,

                                decoration: InputDecoration(
                                  labelText: 'Пароль',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Остальная часть кода
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 0.0, 0.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              // Логика для входа по email и паролю
                              try {
                                setState(() {

                                });

                                final user = await authManager.signInWithEmail(
                                  context,
                                  _model.email!,
                                  _model.password!,
                                );
                                print(user);
                                if (user == null) {
                                  return;
                                }

                                context.goNamedAuth(
                                    LoadWidget.routeName, context.mounted);
                              } catch(_) {
                                rethrow;
                              }
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
                // Остальная часть кода остаётся без изменений

              ],
            ),
          ],
        ),
      ),
    );
  }
}