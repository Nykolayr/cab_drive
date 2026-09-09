import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/pay_order_record_mapper.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/payments_api_config.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/custom_code/services/payment_bank_error.dart';
import '/custom_code/services/payment_init_error.dart';
import '/custom_code/widgets/payment_result_overlay.dart';
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
import 'pay_init_model.dart';
export 'pay_init_model.dart';

class PayInitWidget extends StatefulWidget {
  const PayInitWidget({
    super.key,
    required this.payOrderRef,
    required this.amountRUB,
    required this.currentprice,
    required this.driver,
  });

  final DocumentReference? payOrderRef;
  final int? amountRUB;
  final int? currentprice;
  final DocumentReference? driver;

  @override
  State<PayInitWidget> createState() => _PayInitWidgetState();
}

class _PayInitWidgetState extends State<PayInitWidget> {
  late PayInitModel _model;

  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;
  Timer? _payPollTimer;
  bool _apiPaid = false;
  String? _apiFailStatus;
  String? _apiFailCode;
  String? _apiFailMessage;
  PayOrderRecord? _polledPay;
  bool _queueUpdated = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PayInitModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        // ignore: avoid_print
        print(
          '[Pay.order] start amountRUB=${widget.amountRUB} '
          'payOrder=${widget.payOrderRef?.id} user=${currentUserReference?.id}',
        );
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
        // ignore: avoid_print
        print(
          '[Pay.order] pay_order orderId=${_model.order?.orderId}',
        );
        _model.aposdasdanfa23 = await InitPaymentCall.call(
          amount: (widget!.amountRUB!) * 100,
          description: 'Оплата заказа',
          orderId: _model.order?.orderId,
          customerKey: currentUserReference?.id,
        );

        final response = _model.aposdasdanfa23;
        final ok = response?.succeeded ?? false;
        final paymentUrl = ok
            ? InitPaymentCall.paymentUrl(response?.jsonBody ?? '')
            : null;
        final paymentId = ok
            ? InitPaymentCall.paymentId(response?.jsonBody ?? '')
            : null;

        // ignore: avoid_print
        print(
          '[Pay.order] init ok=$ok paymentId=$paymentId '
          'url=${paymentUrl != null && paymentUrl.isNotEmpty ? paymentUrl.substring(0, paymentUrl.length.clamp(0, 80)) : null}',
        );

        if (ok && paymentUrl != null && paymentUrl.isNotEmpty) {
          unawaited(
            () async {
              final payId = widget!.payOrderRef!.id;
              final patched = await AppMeApi.patchPayment(payId, {
                'paymentId': paymentId,
                'payment_id': paymentId,
              });
              if (!patched) {
                // ignore: avoid_print
                print('[Pay.order] patchPayment failed paymentId=$paymentId');
              }
              // ignore: avoid_print
              print('[Pay.order] pay_order.paymentId saved=$paymentId api=$patched');
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
          // ignore: avoid_print
          print(
            '[Pay.order] FAIL status=${response?.statusCode} '
            'body=${response?.jsonBody} msg=${_model.paymentErrorMessage}',
          );
        }
      } catch (e, st) {
        _model.urlIsSet = false;
        _model.paymentFailed = true;
        _model.paymentErrorMessage =
            'Не удалось открыть оплату. ${PaymentInitError.supportHint}';
        // ignore: avoid_print
        print('[Pay.order] EXCEPTION $e\n$st');
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

  void _onPayNavigate(String url) {
    // ignore: avoid_print
    print('[Pay.order] navigate $url');
    if (PaymentBankError.isFailUrl(url)) {
      _model.bankFailOverlay = true;
      _model.bankFailMessage = PaymentBankError.message(
        status: 'REJECTED',
        mode: PaymentsApiConfig.mode,
      );
      // ignore: avoid_print
      print('[Pay.order] FailURL → overlay');
      if (mounted) safeSetState(() {});
    } else if (PaymentBankError.isSuccessUrl(url)) {
      // ignore: avoid_print
      print('[Pay.order] SuccessURL (ждём is_paid из webhook)');
    }
  }

  void _applyBankFailFromPayOrder(PayOrderRecord payOrder) {
    if (payOrder.isPaid) return;
    final status = payOrder.tinkoffStatus.toUpperCase();
    const fails = {
      'REJECTED',
      'CANCELED',
      'DEADLINE_EXPIRED',
      'AUTH_FAIL',
      'REVERSED',
    };
    if (!fails.contains(status)) return;
    _model.bankFailOverlay = true;
    _model.bankFailMessage = PaymentBankError.message(
      errorCode: payOrder.tinkoffErrorCode,
      status: status,
      bankMessage: payOrder.tinkoffMessage,
      mode: PaymentsApiConfig.mode,
    );
  }

  Future<void> _ensureDriverQueueUpdated(PayOrderRecord payOrder) async {
    if (_queueUpdated) return;
    final driverRef = payOrder.driver ?? widget.driver;
    final orderRef = payOrder.currentOrderDocRef;
    if (driverRef == null || orderRef == null) return;
    _queueUpdated = true;
    try {
      final ok = await AppMeApi.acceptBid(
        orderRef.id,
        driverUid: driverRef.id,
        price: widget.currentprice ??
            (payOrder.amountInCop > 0
                ? (payOrder.amountInCop / 100).round()
                : null),
        commissionPercent: null,
      );
      if (!ok) {
        print('[pay_init.queue] acceptBid failed order=${orderRef.id}');
      } else {
        print('[pay_init.queue] acceptBid ok order=${orderRef.id}');
      }
    } catch (e) {
      _queueUpdated = false;
      print('[pay_init.queue] ERROR $e');
    }
  }

  void _startPayPoll() {
    _payPollTimer?.cancel();
    final payId = widget.payOrderRef?.id;
    if (payId == null || payId.isEmpty) return;
    _payPollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final pay = await AppMeApi.getPayment(payId);
      if (pay == null || !mounted) return;
      _polledPay = PayOrderRecordMapper.fromApi(pay, payId);
      final paid = PayOrderRecordMapper.isPaid(pay);
      if (paid) {
        _apiPaid = true;
        final orderId = pay['current_order_id']?.toString() ??
            payOrderCurrentOrderId(pay);
        final driverId =
            pay['driver_id']?.toString() ?? widget.driver?.id;
        if (orderId != null &&
            orderId.isNotEmpty &&
            driverId != null &&
            driverId.isNotEmpty &&
            !_queueUpdated) {
          _queueUpdated = true;
          final price = widget.currentprice ??
              (() {
                final cop = pay['amount_in_cop'];
                if (cop is num && cop > 0) return (cop / 100).round();
                return null;
              })();
          final commission = pay['commission_percent'] ?? pay['commissionPercent'];
          final ok = await AppMeApi.acceptBid(
            orderId,
            driverUid: driverId,
            price: price,
            commissionPercent: commission is num ? commission : null,
          );
          if (!ok) _queueUpdated = false;
        }
        _payPollTimer?.cancel();
        if (mounted) safeSetState(() {});
        return;
      }
      final status = PayOrderRecordMapper.tinkoffStatus(pay);
      if (PayOrderRecordMapper.failStatuses.contains(status)) {
        _apiFailStatus = status;
        _apiFailCode = pay['tinkoff_error_code']?.toString();
        _apiFailMessage = pay['tinkoff_message']?.toString();
        _model.bankFailOverlay = true;
        _model.bankFailMessage = PaymentBankError.message(
          errorCode: _apiFailCode,
          status: status,
          bankMessage: _apiFailMessage,
          mode: PaymentsApiConfig.mode,
        );
        _payPollTimer?.cancel();
        if (mounted) safeSetState(() {});
      } else if (mounted) {
        safeSetState(() {});
      }
    });
  }

  Stream<PayOrderRecord> _payStream() {
    if (_polledPay != null) {
      return Stream<PayOrderRecord>.value(_polledPay!);
    }
    return const Stream.empty();
  }

  String? payOrderCurrentOrderId(Map<String, dynamic> pay) {
    final ref = pay['current_order_doc_ref'];
    if (ref is Map && ref['_ref'] != null) {
      return ref['_ref'].toString().split('/').last;
    }
    if (ref is String && ref.isNotEmpty) {
      return ref.contains('/') ? ref.split('/').last : ref;
    }
    return null;
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
                      'Оплата заказа',
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
                  if (paid && containerPayOrderRecord != null) {
                    // idempotent — добавит ref только один раз благодаря _queueUpdated
                    _ensureDriverQueueUpdated(containerPayOrderRecord);
                  } else if (containerPayOrderRecord != null) {
                    _applyBankFailFromPayOrder(containerPayOrderRecord);
                  }

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
                                                'Поздравляем, ваш заказ оплачен!',
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
                            return Stack(
                              children: [
                                ClipRRect(
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
                                      content: InitPaymentCall.paymentUrl(
                                        (_model.aposdasdanfa23?.jsonBody ??
                                            ''),
                                      )!,
                                      bypass: false,
                                      height: MediaQuery.sizeOf(context)
                                              .height *
                                          0.8,
                                      verticalScroll: false,
                                      horizontalScroll: false,
                                      onNavigate: _onPayNavigate,
                                    ),
                                  ),
                                ),
                                if (_model.bankFailOverlay)
                                  Positioned.fill(
                                    child: PaymentResultOverlay(
                                      message: _model.bankFailMessage.isNotEmpty
                                          ? _model.bankFailMessage
                                          : PaymentBankError.message(
                                              mode: PaymentsApiConfig.mode,
                                            ),
                                      onClose: () {
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ),
                              ],
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
