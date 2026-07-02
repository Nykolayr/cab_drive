import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'create_rewievs_model.dart';
export 'create_rewievs_model.dart';

class CreateRewievsWidget extends StatefulWidget {
  const CreateRewievsWidget({
    super.key,
    required this.user,
    int? rait,
    required this.order,
  }) : rait = rait ?? 5;

  final DocumentReference? user;
  final int rait;
  final DocumentReference? order;

  @override
  State<CreateRewievsWidget> createState() => _CreateRewievsWidgetState();
}

class _CreateRewievsWidgetState extends State<CreateRewievsWidget> {
  late CreateRewievsModel _model;

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
    _model = createModel(context, () => CreateRewievsModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.rait = widget.rait;
      safeSetState(() {});
    });

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
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
    context.watch<FFAppState>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22.0),
          topRight: Radius.circular(22.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 64.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22.0),
                topRight: Radius.circular(22.0),
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FFAppState().driver
                        ? 'Отзыв на заказчика'
                        : 'Отзыв на водителя',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          fontSize: 21.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  FlutterFlowIconButton(
                    borderColor:
                        FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: 54.0,
                    borderWidth: 0.0,
                    buttonSize: 32.0,
                    fillColor: const Color(0xFFF4F5F8),
                    hoverColor: FlutterFlowTheme.of(context).primary,
                    hoverIconColor: FlutterFlowTheme.of(context).primaryText,
                    icon: const Icon(
                      FFIcons.kkrestStroke,
                      color: Color(0xFF21201F),
                      size: 8.0,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
            ),
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(8.0, 35.0, 8.0, 35.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 8.0,
                      buttonSize: 55.0,
                      icon: Icon(
                        FFIcons.kantDesignStarFilled,
                        color: valueOrDefault<Color>(
                          () {
                            if (_model.rait == 1) {
                              return const Color(0xFF850000);
                            } else if (_model.rait == 2) {
                              return const Color(0xFFFF0000);
                            } else if (_model.rait == 3) {
                              return const Color(0xFFFF3D00);
                            } else if (_model.rait == 4) {
                              return const Color(0xFFFF7000);
                            } else if (_model.rait == 5) {
                              return const Color(0xFFFFC600);
                            } else {
                              return const Color(0xFFEEEEEE);
                            }
                          }(),
                          const Color(0xFFEEEEEE),
                        ),
                        size: 40.0,
                      ),
                      onPressed: () async {
                        _model.rait = 1;
                        safeSetState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 8.0,
                      buttonSize: 55.0,
                      icon: Icon(
                        FFIcons.kantDesignStarFilled,
                        color: valueOrDefault<Color>(
                          () {
                            if (_model.rait == 2) {
                              return const Color(0xFFFF0000);
                            } else if (_model.rait == 3) {
                              return const Color(0xFFFF3D00);
                            } else if (_model.rait == 4) {
                              return const Color(0xFFFF7000);
                            } else if (_model.rait == 5) {
                              return const Color(0xFFFFC600);
                            } else {
                              return const Color(0xFFEEEEEE);
                            }
                          }(),
                          const Color(0xFFEEEEEE),
                        ),
                        size: 40.0,
                      ),
                      onPressed: () async {
                        _model.rait = 2;
                        safeSetState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 8.0,
                      buttonSize: 55.0,
                      icon: Icon(
                        FFIcons.kantDesignStarFilled,
                        color: valueOrDefault<Color>(
                          () {
                            if (_model.rait == 3) {
                              return const Color(0xFFFF3D00);
                            } else if (_model.rait == 4) {
                              return const Color(0xFFFF7000);
                            } else if (_model.rait == 5) {
                              return const Color(0xFFFFC600);
                            } else {
                              return const Color(0xFFEEEEEE);
                            }
                          }(),
                          const Color(0xFFEEEEEE),
                        ),
                        size: 40.0,
                      ),
                      onPressed: () async {
                        _model.rait = 3;
                        safeSetState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 8.0,
                      buttonSize: 55.0,
                      icon: Icon(
                        FFIcons.kantDesignStarFilled,
                        color: valueOrDefault<Color>(
                          () {
                            if (_model.rait == 4) {
                              return const Color(0xFFFF7000);
                            } else if (_model.rait == 5) {
                              return const Color(0xFFFFC600);
                            } else {
                              return const Color(0xFFEEEEEE);
                            }
                          }(),
                          const Color(0xFFEEEEEE),
                        ),
                        size: 40.0,
                      ),
                      onPressed: () async {
                        _model.rait = 4;
                        safeSetState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: FlutterFlowIconButton(
                      borderColor: Colors.transparent,
                      borderRadius: 8.0,
                      buttonSize: 55.0,
                      icon: Icon(
                        FFIcons.kantDesignStarFilled,
                        color: valueOrDefault<Color>(
                          _model.rait == 5
                              ? const Color(0xFFFFC600)
                              : const Color(0xFFEEEEEE),
                          const Color(0xFFEEEEEE),
                        ),
                        size: 40.0,
                      ),
                      onPressed: () async {
                        _model.rait = 5;
                        safeSetState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    () {
                      if (_model.rait! <= 3) {
                        return 'Расскажтите, что пошло не так';
                      } else if (_model.rait == 4) {
                        return 'Расскажтите, что могло бы быть лучше';
                      } else {
                        return 'Расскажтите, что понравилось';
                      }
                    }(),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 12.0, 0.0, 0.0),
                    child: TextFormField(
                      controller: _model.textController,
                      focusNode: _model.textFieldFocusNode,
                      autofocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      obscureText: false,
                      decoration: InputDecoration(
                        isDense: false,
                        hintText: FFAppState().driver
                            ? 'Поделитесь вашими впечатлениями о работе с клиентом. Это поможет другим специалистам.'
                            : 'Поделитесь вашими впечатлениями. Это поможет специалисту находить клиентов.',
                        hintStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'SF',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  lineHeight: 0.0,
                                ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFD0CFCE),
                            width: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFD0CFCE),
                            width: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        focusedErrorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 24.0, 0.0, 22.0),
                        hoverColor: Colors.transparent,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF',
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                          ),
                      textAlign: TextAlign.start,
                      maxLines: null,
                      cursorColor: FlutterFlowTheme.of(context).primaryText,
                      validator:
                          _model.textControllerValidator.asValidator(context),
                      inputFormatters: [
                        if (!isAndroid && !isiOS)
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return TextEditingValue(
                              selection: newValue.selection,
                              text: newValue.text.toCapitalization(
                                  TextCapitalization.sentences),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  8.0,
                  8.0,
                  8.0,
                  valueOrDefault<double>(
                    (isWeb
                            ? MediaQuery.viewInsetsOf(context).bottom > 0
                            : _isKeyboardVisible)
                        ? 8.0
                        : 35.0,
                    35.0,
                  )),
              child: FFButtonWidget(
                onPressed: ((_model.rait == null) ||
                        (_model.textController.text == ''))
                    ? null
                    : () async {
                        await ReviewsRecord.collection
                            .doc()
                            .set(createReviewsRecordData(
                              userWhoWasReviewed: widget.user,
                              userWhoWroteTheReview: currentUserReference,
                              text: _model.textController.text,
                              rating: _model.rait,
                              date: getCurrentTimestamp,
                              nameUserWhoWrote:
                                  '${currentUserDisplayName} ${valueOrDefault(currentUserDocument?.surname, '')}',
                            ));
                        if (FFAppState().driver) {
                          await widget.order!.update(createOrderRecordData(
                            customerReviewed: true,
                          ));
                        } else {
                          await widget.order!.update(createOrderRecordData(
                            driverReviewed: true,
                          ));
                        }

                        _model.user =
                            await UsersRecord.getDocumentOnce(widget.user!);
                        unawaited(
                          () async {
                            await widget.user!.update({
                              ...createUsersRecordData(
                                averageRating:
                                    functions.recalculateRatingWithNewReview(
                                        _model.user!.numberOfReviews,
                                        _model.user!.averageRating,
                                        _model.rait!),
                              ),
                              ...mapToFirestore(
                                {
                                  'number_of_reviews': FieldValue.increment(1),
                                },
                              ),
                            });
                          }(),
                        );
                        Navigator.pop(context);

                        safeSetState(() {});
                      },
                text: 'Отправить отзыв',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 56.0,
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).tertiary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'SF',
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        letterSpacing: 0.0,
                      ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(16.0),
                  disabledColor: FlutterFlowTheme.of(context).primary,
                  disabledTextColor: FlutterFlowTheme.of(context).secondaryText,
                ),
                showLoadingIndicator: false,
              ),
            ),
          ),
        ].divide(const SizedBox(height: 5.0)),
      ),
    );
  }
}
