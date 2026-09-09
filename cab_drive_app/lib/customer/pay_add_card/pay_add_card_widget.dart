import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/pay_order_record_mapper.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/custom_code/services/payment_init_error.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_web_view.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'pay_add_card_model.dart';
export 'pay_add_card_model.dart';

class PayAddCardWidget extends StatefulWidget {
  const PayAddCardWidget({
    super.key,
    required this.payOrderRef,
    required this.amountCop,
  });

  final DocumentReference? payOrderRef;
  final int? amountCop;

  @override
  State<PayAddCardWidget> createState() => _PayAddCardWidgetState();
}

class _PayAddCardWidgetState extends State<PayAddCardWidget> {
  late PayAddCardModel _model;

  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;
  Timer? _payPollTimer;
  PayOrderRecord? _polledPay;
  bool _apiPaid = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  void _startPayPoll() {
    _payPollTimer?.cancel();
    final payId = widget.payOrderRef?.id;
    if (payId == null || payId.isEmpty) return;
    _payPollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final pay = await AppMeApi.getPayment(payId);
      if (pay == null || !mounted) return;
      _polledPay = PayOrderRecordMapper.fromApi(pay, payId);
      if (PayOrderRecordMapper.isPaid(pay)) {
        _apiPaid = true;
        _payPollTimer?.cancel();
      }
      if (mounted) safeSetState(() {});
    });
  }

  Stream<PayOrderRecord> _payStream() {
    if (_polledPay != null) {
      return Stream<PayOrderRecord>.value(_polledPay!);
    }
    return const Stream.empty();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PayAddCardModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        final payId = widget.payOrderRef?.id ?? '';
        final apiPay = payId.isNotEmpty ? await AppMeApi.getPayment(payId) : null;
        if (apiPay != null) {
          _polledPay = PayOrderRecordMapper.fromApi(apiPay, payId);
          _model.order = _polledPay;
        } else {
          _model.urlIsSet = false;
          _model.paymentFailed = true;
          _model.paymentErrorMessage =
              'Не удалось загрузить платёж. Попробуйте ещё раз.';
          if (mounted) safeSetState(() {});
          return;
        }
        _model.aposdasdanfa23 = await InitRecurrentPaymentCall.call(
          amount: 100,
          description: 'Добавление карты',
          orderId: _model.order?.orderId,
          customerKey: currentUserReference?.id,
        );

        final response = _model.aposdasdanfa23;
        final ok = response?.succeeded ?? false;
        final paymentUrl = ok
            ? InitRecurrentPaymentCall.paymentUrl(response?.jsonBody ?? '')
            : null;

        if (ok && paymentUrl != null && paymentUrl.isNotEmpty) {
          unawaited(
            () async {
              final pid = InitRecurrentPaymentCall.paymentId(
                (response?.jsonBody ?? ''),
              );
              final id = widget!.payOrderRef!.id;
              final patched = await AppMeApi.patchPayment(id, {
                'paymentId': pid,
                'payment_id': pid,
              });
              if (!patched) {
                // ignore: avoid_print
                print('[Pay.add_card] patchPayment failed paymentId=$pid');
              }
            }(),
          );
          _model.urlIsSet = true;
          _model.paymentFailed = false;
          _model.paymentErrorMessage = '';
          _startPayPoll();
        } else {
          _model.urlIsSet = false;
          _model.paymentFailed = true;
          _model.paymentErrorMessage =
              PaymentInitError.messageFromCall(response);
        }
      } catch (e) {
        _model.urlIsSet = false;
        _model.paymentFailed = true;
        _model.paymentErrorMessage =
            'Не удалось открыть оплату. ${PaymentInitError.supportHint}';
      }
      if (mounted) {
        safeSetState(() {});
      }
    });

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
    _payPollTimer?.cancel();
    _model.maybeDispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(22.0),
            topRight: Radius.circular(22.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 64.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                  topLeft: Radius.circular(22.0),
                  topRight: Radius.circular(22.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Добавление карты',
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
                      fillColor: Color(0xFFF4F5F8),
                      hoverColor: FlutterFlowTheme.of(context).primary,
                      hoverIconColor: FlutterFlowTheme.of(context).primaryText,
                      icon: Icon(
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
            Expanded(
              child: StreamBuilder<PayOrderRecord>(
                stream: _payStream(),
                builder: (context, snapshot) {
                  // Customize what your widget looks like when it's loading.
                  if (!snapshot.hasData && !_apiPaid) {
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

                  final containerPayOrderRecord =
                      snapshot.data ?? _polledPay;
                  final paid = _apiPaid ||
                      (containerPayOrderRecord?.isPaid ?? false);

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Builder(
                        builder: (context) {
                          if (paid) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/_2.png',
                                          width: double.infinity,
                                          height: 336.3,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            24.0, 32.0, 24.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 16.0),
                                              child: Text(
                                                'Карта привязана!',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          font:
                                                              GoogleFonts.inter(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 26.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                          lineHeight: 1.25,
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
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
                                                  ? MediaQuery.viewInsetsOf(
                                                              context)
                                                          .bottom >
                                                      0
                                                  : _isKeyboardVisible)
                                              ? 8.0
                                              : 35.0,
                                          35.0,
                                        )),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        FFButtonWidget(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          text: 'Закрыть',
                                          options: FFButtonOptions(
                                            width: double.infinity,
                                            height: 56.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      fontFamily: 'SF',
                                                      color: FlutterFlowTheme
                                                              .of(context)
                                                          .primaryBackground,
                                                      letterSpacing: 0.0,
                                                    ),
                                            elevation: 0.0,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          showLoadingIndicator: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 5.0)),
                            );
                          } else if (_model.paymentFailed) {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 24.0, 24.0, 24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _model.paymentErrorMessage.isNotEmpty
                                          ? _model.paymentErrorMessage
                                          : PaymentInitError.messageFromCall(
                                              null),
                                      textAlign: TextAlign.center,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'SF',
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    const SizedBox(height: 24.0),
                                    FFButtonWidget(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                      },
                                      text: 'Закрыть',
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 56.0,
                                        padding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        iconPadding:
                                            const EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .tertiary,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'SF',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryBackground,
                                              letterSpacing: 0.0,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      showLoadingIndicator: false,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (_model.urlIsSet) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: FlutterFlowWebView(
                                  content: InitRecurrentPaymentCall.paymentUrl(
                                    (_model.aposdasdanfa23?.jsonBody ?? ''),
                                  )!,
                                  bypass: false,
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.8,
                                  verticalScroll: false,
                                  horizontalScroll: false,
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Lottie.asset(
                                  'assets/jsons/QxDtZdOkBw.json',
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.contain,
                                  animate: true,
                                ),
                              ),
                            );
                          }
                        },
                      ),
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
