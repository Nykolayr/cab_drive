import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/chat_open.dart';
import '/backend/api/file_storage_service.dart';
import '/backend/api/saved_cards_record_mapper.dart';
import '/backend/api/users_record_api.dart';
import '/backend/backend.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/enums/enums.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/driver/order_page_driver/widgets/countdown_or_expired.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/create_rewievs/create_rewievs_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'order_card_customer_model.dart';
export 'order_card_customer_model.dart';

class OrderCardCustomerWidget extends StatefulWidget {
  const OrderCardCustomerWidget({
    super.key,
    required this.order,
    this.onPriceCommitted,
  });

  final OrderRecord? order;
  final VoidCallback? onPriceCommitted;

  @override
  State<OrderCardCustomerWidget> createState() =>
      _OrderCardCustomerWidgetState();
}

class _OrderCardCustomerWidgetState extends State<OrderCardCustomerWidget> {
  late OrderCardCustomerModel _model;

  final TextEditingController _priceController = TextEditingController();
  final FocusNode _priceFocus = FocusNode();
  bool _priceInitialized = false;
  bool _isSaving = false;
  int? _pendingPrice;

  int get _basePrice {
    final cp = widget.order?.currentPrice ?? 0;
    if (cp > 0) return cp;
    return widget.order?.budget ?? 0;
  }

  int? get _enteredPrice {
    final text = _priceController.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  bool get _canCommit {
    if (_isSaving || _pendingPrice != null) return false;
    final v = _enteredPrice;
    if (v == null || v < _basePrice) return false;
    return v != _basePrice;
  }

  void _ensurePriceInitialized() {
    if (_priceInitialized) return;
    _priceInitialized = true;
    _priceController.text = _basePrice.toString();
  }

  Future<void> _commitPrice() async {
    if (!_canCommit || widget.order == null) return;
    final newPrice = _enteredPrice!;
    setState(() {
      _isSaving = true;
      _pendingPrice = newPrice;
    });
    try {
      final ok = await AppMeApi.patchOrder(
        widget.order!.reference.id,
        {
          'currentPrice': newPrice,
          // UI «Ожидаемая» на старых экранах читает budget — синхронизируем
          'budget': newPrice,
        },
      );
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось изменить цену')),
          );
        }
        return;
      }
      // Уведомляем откликнувшихся водителей об изменении цены заказа.
      final respondedDrivers = widget.order!.userWhoResponced;
      if (respondedDrivers.isNotEmpty) {
        triggerPushNotification(
          notificationTitle: 'Цена заказа изменилась',
          notificationText: 'Заказчик изменил цену до $newPrice ₽',
          notificationSound: 'default',
          userRefs: respondedDrivers,
          initialPageName: 'order_Page_Driver',
          parameterData: {
            'order': widget.order!.reference,
          },
        );
      }
      if (!mounted) return;
      _priceFocus.unfocus();
      setState(() {
        _isSaving = false;
        _pendingPrice = null;
        _priceController.text = newPrice.toString();
      });
      widget.onPriceCommitted?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _pendingPrice = null;
      });
    }
  }

  void _openOrderPage() {
    context.pushNamed(
      OrderPageCustomerWidget.routeName,
      queryParameters: {
        'index': serializeParam(2, ParamType.int),
        'order':
            serializeParam(widget.order?.reference, ParamType.DocumentReference),
      }.withoutNulls,
    );
  }


  Widget _responseBadge(OrderRecord order) {
    final count = order.countResp;
    if (count == 0) return const SizedBox.shrink();
    return Container(
      width: 28.0,
      height: 28.0,
      decoration: const BoxDecoration(
        color: Color(0xFFE01935),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF',
              color: FlutterFlowTheme.of(context).secondaryBackground,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildSearchingCard(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final order = widget.order!;
    _ensurePriceInitialized();

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: _openOrderPage,
              child: Row(
                children: [
                  Container(
                    height: 32.0,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.tertiary),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Поиск водителя',
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF',
                        color: theme.tertiary,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  if (order.countResp != 0) _responseBadge(order),
                  const Spacer(),
                  Flexible(
                    child: CountdownOrExpired(
                      dateUpd: order.dateTimeCreated,
                      durationMinutes: FFAppState().minutesForDeleteOrder,
                      label: 'Архив через',
                      expiredText: 'Архивируется…',
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF',
                        color: _kMutedText,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                      ),
                      expiredStyle: theme.bodyMedium.override(
                        fontFamily: 'SF',
                        color: _kMutedText,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                      ),
                      descriptionTextStyle: theme.bodyMedium.override(
                        fontFamily: 'SF',
                        color: _kMutedText,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 56.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F8),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Row(
                children: [
                  Text(
                    'До',
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF',
                      color: theme.secondaryText,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      focusNode: _priceFocus,
                      enabled: _pendingPrice == null && !_isSaving,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(7),
                      ],
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF',
                        color: theme.tertiary,
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    '₽',
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF',
                      color: theme.tertiary,
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            InkWell(
              onTap: _canCommit ? _commitPrice : null,
              borderRadius: BorderRadius.circular(14.0),
              child: Container(
                width: double.infinity,
                height: 44.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F8),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                alignment: Alignment.center,
                child: _isSaving
                    ? const SizedBox(
                        width: 22.0,
                        height: 22.0,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : Text(
                        'Изменить цену',
                        style: theme.bodyMedium.override(
                          fontFamily: 'SF',
                          color: _canCommit
                              ? theme.tertiary
                              : const Color(0xFFA4A6B2),
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16.0),
            _polylineMapPreview(height: 165.0),
            const SizedBox(height: 16.0),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Откуда',
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF',
                      color: theme.secondaryText,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                  Text(
                    'Куда',
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF',
                      color: theme.secondaryText,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.pointA.address
                        .maybeHandleOverflow(maxChars: 22, replacement: '…'),
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF',
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.3,
                          color: theme.secondaryText,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(FFIcons.kcar01,
                            color: theme.secondaryText, size: 18.0),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.3,
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    order.pointB.address
                        .maybeHandleOverflow(maxChars: 22, replacement: '…'),
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF',
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderCardCustomerModel());
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceFocus.dispose();
    _model.maybeDispose();

    super.dispose();
  }

  bool _isDelivered() {
    final o = widget!.order;
    final s = o?.status;
    if (s == StatusOrder.completed) return true;
    if (s == StatusOrder.hidden) {
      // Свежие авто-архивированные заказы помечены status_do_hidden=completed.
      if (o?.statusDoHidden == StatusOrder.completed) return true;
      // Легаси: backend раньше выставлял только status='hidden' без
      // status_do_hidden. Распознаём по completion_date_by_the_driver.
      if (o?.completionDateByTheDriver != null) return true;
    }
    return false;
  }

  bool _repeatInFlight = false;

  Future<void> _repeatOrder() async {
    if (_repeatInFlight) return;
    _repeatInFlight = true;
    try {
      final src = widget!.order!;
      final id = OrderRecord.collection.doc().id;
      final api = await AppMeApi.createOrder({
        'id': id,
        'user_customer_id': currentUserUid,
        'supply': src.supply,
        'dateTime': src.dateTime?.toUtc().toIso8601String(),
        'pointA': pointToApiMap(src.pointA),
        'pointB': pointToApiMap(src.pointB),
        if (src.hasPointC()) 'pointC': pointToApiMap(src.pointC),
        'movers': src.movers,
        'description': src.description,
        'budget': src.budget,
        'currentPrice': src.currentPrice > 0 ? src.currentPrice : src.budget,
        'dateTime_created': functions.toUtc().toIso8601String(),
        'status': 'newOrder',
        'distance': src.distance,
        'time': src.time,
        'car': src.car?.serialize(),
        'payMethod': src.payMethod?.serialize(),
        'images': src.images,
      });
      if (api == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось повторить заказ')),
          );
        }
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заказ был создан'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось повторить заказ: $e')),
        );
      }
    } finally {
      _repeatInFlight = false;
    }
  }

  // --- Figma-точные карточки для "Доставлен" ---
  // 3002:2839 (Активные → completed): шапка с таймером архивации, миникарта,
  // адреса, "Заказ доставлен", блок отзыва.
  // 3002:2942 (Архив → hidden c прежним completed): то же без таймера и без
  // блока отзыва, вместо него кнопка "Повторить заказ".

  static const _kPageBg = Color(0xFFF4F5F8);
  static const _kDeliveredGreen = Color(0xFF2EB518);
  static const _kIosBlue = Color(0xFF007AFF);
  static const _kMutedText = Color(0xFFA4A6B2);
  static const _kStarGrey = Color(0xFFEEEEEE);

  Widget _deliveredHeader({required bool withTimer}) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 26.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: _kDeliveredGreen),
            ),
            padding: EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 13.0, 0.0),
            alignment: Alignment.center,
            child: Text(
              'Доставлен',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    color: _kDeliveredGreen,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                    lineHeight: 1.25,
                  ),
            ),
          ),
          if (withTimer)
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                child: CountdownOrExpired(
                  dateUpd: widget!.order?.dateUpd,
                  durationMinutes: FFAppState().deadlineMinutes,
                  label: 'Архивируется через',
                  expiredText: 'Архивируется…',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        color: _kMutedText,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                  expiredStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        color: _kMutedText,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                  descriptionTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        color: _kMutedText,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            )
          else
            Spacer(),
          Text(
            widget!.order?.currentPrice != 0
                ? '${widget!.order?.currentPrice?.toString()} ₽'
                : '${widget!.order?.budget?.toString()} ₽',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF',
                  color: _kIosBlue,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  // Чистая обёртка над YandexOrderMap (без внешнего padding) — переиспользуется
  // во всех типах карточки. Каждый caller добавляет свои отступы по контексту.
  Widget _polylineMapPreview({double height = 165.0}) {
    final a = widget!.order?.pointA.latlng;
    final b = widget!.order?.pointB.latlng;
    if (a == null || b == null) return SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: custom_widgets.YandexOrderMap(
          width: double.infinity,
          height: height,
          startLatLng: a,
          endLatLng: b,
          isStatic: true,
        ),
      ),
    );
  }

  Widget _deliveredMap() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
      child: _polylineMapPreview(),
    );
  }

  Widget _deliveredAddresses() {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Откуда',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          color: _kMutedText,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        )),
                Text('Куда',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          color: _kMutedText,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        )),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget!.order!.pointA.address
                      .maybeHandleOverflow(maxChars: 25, replacement: '…'),
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          height: 0.3,
                          color: _kMutedText),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
                      child: Icon(FFIcons.kcar01, color: _kMutedText, size: 18.0),
                    ),
                    Expanded(
                      child: Container(
                          height: 0.3,
                          color: _kMutedText),
                    ),
                  ].divide(SizedBox(width: 4.0)),
                ),
              ),
              Expanded(
                child: Text(
                  widget!.order!.pointB.address
                      .maybeHandleOverflow(maxChars: 25, replacement: '…'),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ].divide(SizedBox(width: 7.0)),
          ),
        ],
      ),
    );
  }

  Widget _ratingCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
              blurRadius: 15.0,
              color: Color(0x14181818),
              offset: Offset(0, 0)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Оставить отзыв',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                return FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 8.0,
                  buttonSize: 55.0,
                  hoverColor: Colors.transparent,
                  icon: Icon(
                    FFIcons.kantDesignStarFilled,
                    color: _kStarGrey,
                    size: 40.0,
                  ),
                  onPressed: () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return WebViewAware(
                          child: Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: CreateRewievsWidget(
                              user: widget!.order!.selectedDriver!,
                              order: widget!.order!.reference,
                              rait: i + 1,
                            ),
                          ),
                        );
                      },
                    ).then((value) => safeSetState(() {}));
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveredCard(BuildContext context) {
    // Per Figma 3002:2839: одна большая белая карточка (radius 24) содержит
    // ВСЁ — шапку, карту, адреса, текст "Заказ доставлен" и внутреннюю карточку
    // "Оставить отзыв" (она белая с тенью, поэтому видна как приподнятый блок
    // на том же белом фоне).
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top tappable area — переход в детали заказа
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(
                OrderPageCustomerWidget.routeName,
                queryParameters: {
                  'index': serializeParam(2, ParamType.int),
                  'order': serializeParam(
                      widget!.order?.reference, ParamType.DocumentReference),
                }.withoutNulls,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _deliveredHeader(withTimer: true),
                _deliveredMap(),
                _deliveredAddresses(),
              ],
            ),
          ),
          if (!widget!.order!.driverReviewed) ...[
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 12.0),
              child: Text(
                'Заказ доставлен',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 16.0),
              child: _ratingCard(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArchivedRepeatCard(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        context.pushNamed(
          OrderPageCustomerWidget.routeName,
          queryParameters: {
            'index': serializeParam(2, ParamType.int),
            'order': serializeParam(
                widget!.order?.reference, ParamType.DocumentReference),
          }.withoutNulls,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _deliveredHeader(withTimer: false),
            _deliveredMap(),
            _deliveredAddresses(),
            // Figma 3002:2976 — серый дивайдер между точками и кнопкой
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
              child: Container(
                height: 1.0,
                color: _kPageBg,
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
              child: Material(
                color: _kPageBg,
                borderRadius: BorderRadius.circular(16.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  onTap: _repeatOrder,
                  child: Container(
                    height: 45.0,
                    alignment: Alignment.center,
                    child: Text(
                      'Повторить заказ',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF',
                            color: _kIosBlue,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order?.status == StatusOrder.newOrder) {
      return _buildSearchingCard(context);
    }
    if (widget.order?.status == StatusOrder.completed) {
      return _buildDeliveredCard(context);
    }
    if (widget.order?.status == StatusOrder.hidden && _isDelivered()) {
      return _buildArchivedRepeatCard(context);
    }
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(
                  OrderPageCustomerWidget.routeName,
                  queryParameters: {
                    'index': serializeParam(
                      2,
                      ParamType.int,
                    ),
                    'order': serializeParam(
                      widget!.order?.reference,
                      ParamType.DocumentReference,
                    ),
                  }.withoutNulls,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 7.0, 0.0),
                          child: Container(
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: _isDelivered()
                                    ? Color(0xFF2EB518)
                                    : FlutterFlowTheme.of(context).tertiary,
                              ),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    15.0, 0.0, 15.0, 0.0),
                                child: Text(
                                  valueOrDefault<String>(
                                    () {
                                      if (widget!.order?.status ==
                                          StatusOrder.newOrder) {
                                        return 'Поиск водителя';
                                      } else if (widget!.order?.status ==
                                          StatusOrder.spec_set) {
                                        return 'Ожидает доставки';
                                      } else if (widget!.order?.status ==
                                          StatusOrder.at_work) {
                                        return 'В работе';
                                      } else if (widget!.order?.status ==
                                          StatusOrder.completed) {
                                        return 'Доставлен';
                                      } else if (widget!.order?.status ==
                                          StatusOrder.hidden) {
                                        return _isDelivered()
                                            ? 'Доставлен'
                                            : 'Заказ скрыт';
                                      } else if (widget!.order?.status ==
                                          StatusOrder.cancelled) {
                                        return 'Заказ отменен';
                                      } else if (widget!.order?.status ==
                                          StatusOrder.on_confirmation) {
                                        return 'На подтверждении';
                                      } else {
                                        return 'В работе';
                                      }
                                    }(),
                                    'В работе',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: _isDelivered()
                                            ? Color(0xFF2EB518)
                                            : FlutterFlowTheme.of(context)
                                                .tertiary,
                                        letterSpacing: 0.0,
                                        lineHeight: 1.2,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget!.order?.status == StatusOrder.completed)
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: CountdownOrExpired(
                              dateUpd: widget!.order?.dateUpd,
                              durationMinutes:
                                  FFAppState().deadlineMinutes,
                              label: 'Архивируется через',
                              expiredText: 'Архивируется…',
                              hideWhenExpired: false,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'SF',
                                    color: Color(0xFFA4A6B2),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                              expiredStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'SF',
                                    color: Color(0xFFA4A6B2),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                  ),
                              descriptionTextStyle:
                                  FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: Color(0xFFA4A6B2),
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                      ),
                            ),
                          ),
                        if (widget!.order?.countResp != 0)
                          Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFE01935),
                              shape: BoxShape.circle,
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Text(
                                '${widget!.order?.countResp}',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'SF',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            widget!.order?.currentPrice != 0
                                ? '${widget!.order?.currentPrice?.toString()} ₽'
                                : '${widget!.order?.budget?.toString()} ₽',
                            textAlign: TextAlign.end,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 12.0),
                    child: _polylineMapPreview(),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Откуда',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'SF',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              Text(
                                'Куда',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'SF',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 14.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget!.order!.pointA.address
                                      .maybeHandleOverflow(
                                    maxChars: 25,
                                    replacement: '…',
                                  ),
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
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
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: 49.0,
                                        height: 0.3,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          4.0, 0.0, 4.0, 0.0),
                                      child: Icon(
                                        FFIcons.kcar01,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        size: 18.0,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        width: 49.0,
                                        height: 0.3,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 4.0)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget!.order!.pointB.address
                                      .maybeHandleOverflow(
                                    maxChars: 25,
                                    replacement: '…',
                                  ),
                                  textAlign: TextAlign.end,
                                  maxLines: 2,
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
                            ].divide(SizedBox(width: 7.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          height: 0.3,
                          thickness: 0.3,
                          color: Color(0xFFD0CFCE),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 19.0, 8.0, 0.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FFIcons.kmarkerPin05,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 20.0,
                              ),
                              Flexible(
                                child: Text(
                                  'В пути - ${widget!.order?.distanceStr}, ${widget!.order?.time}',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ),
                            ].divide(SizedBox(width: 8.0)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 16.0, 8.0, 16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                FFIcons.kclock,
                                color: FlutterFlowTheme.of(context).primaryText,
                                size: 18.0,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    6.0, 0.0, 0.0, 0.0),
                                child: Text(
                                  widget!.order?.supply == 1
                                      ? 'В ближайшее время'
                                      : dateTimeFormat(
                                          "d MMM (E) hh:mm",
                                          widget!.order!.dateTime!,
                                          locale: FFLocalizations.of(context)
                                              .languageCode,
                                        ),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if ((widget!.order?.status == StatusOrder.spec_set) ||
                (widget!.order?.status == StatusOrder.completed) ||
                (widget!.order?.status == StatusOrder.at_work))
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    height: 0.3,
                    thickness: 0.3,
                    color: Color(0xFFD0CFCE),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 10.0),
                    child: Text(
                      () {
                        if (widget!.order?.status == StatusOrder.spec_set) {
                          return 'Заказ выполнит';
                        } else if (widget!.order?.status ==
                            StatusOrder.completed) {
                          return 'Заказ выполнил';
                        } else if (widget!.order?.status ==
                            StatusOrder.at_work) {
                          return 'Заказ доставляет';
                        } else {
                          return 'В работе';
                        }
                      }(),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF',
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  FutureBuilder<UsersRecord>(
                    future: UsersRecordApi.getOnce(
                        widget!.order!.selectedDriver!),
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

                      final containerUsersRecord = snapshot.data!;

                      return Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 14.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 11.0, 0.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: Color(0x27A4A6B2),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          FileStorageService.getImageUrl(containerUsersRecord.photoUrl),
                                          width: 37.0,
                                          height: 48.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          containerUsersRecord.displayName,
                                          maxLines: 1,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'SF',
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        Text(
                                          '${containerUsersRecord.car.mark?.name} - ${containerUsersRecord.car.nomer}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'SF',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 2.0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 0.0, 8.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        await openPeerChat(
                                          context,
                                          peerUid:
                                              containerUsersRecord.reference.id,
                                          name:
                                              '${containerUsersRecord.displayName} ${containerUsersRecord.surname}',
                                        );
                                      },
                                      text: 'Написать',
                                      options: FFButtonOptions(
                                        height: 45.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'SF',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              fontSize: 15.0,
                                              letterSpacing: 0.0,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      showLoadingIndicator: false,
                                    ),
                                  ),
                                  Expanded(
                                    child: FFButtonWidget(
                                      onPressed: () async {
                                        await launchUrl(Uri(
                                          scheme: 'tel',
                                          path:
                                              containerUsersRecord.phoneNumber,
                                        ));
                                      },
                                      text: 'Позвонить',
                                      options: FFButtonOptions(
                                        height: 45.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'SF',
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              fontSize: 15.0,
                                              letterSpacing: 0.0,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      showLoadingIndicator: false,
                                    ),
                                  ),
                                ].divide(SizedBox(width: 7.0)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if ((widget!.order?.status == StatusOrder.completed) &&
                      !widget!.order!.driverReviewed)
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(8.0, 24.0, 8.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(
                                0.0,
                                2.0,
                              ),
                            )
                          ],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 8.0,
                                    buttonSize: 55.0,
                                    hoverColor: Colors.transparent,
                                    icon: Icon(
                                      FFIcons.kantDesignStarFilled,
                                      color: Color(0xFFEEEEEE),
                                      size: 40.0,
                                    ),
                                    onPressed: () async {
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) {
                                          return WebViewAware(
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: CreateRewievsWidget(
                                                user: widget!
                                                    .order!.selectedDriver!,
                                                order: widget!.order!.reference,
                                                rait: 1,
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                  ),
                                  FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 8.0,
                                    buttonSize: 55.0,
                                    hoverColor: Colors.transparent,
                                    icon: Icon(
                                      FFIcons.kantDesignStarFilled,
                                      color: Color(0xFFEEEEEE),
                                      size: 40.0,
                                    ),
                                    onPressed: () async {
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) {
                                          return WebViewAware(
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: CreateRewievsWidget(
                                                user: widget!
                                                    .order!.selectedDriver!,
                                                order: widget!.order!.reference,
                                                rait: 2,
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                  ),
                                  FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 8.0,
                                    buttonSize: 55.0,
                                    hoverColor: Colors.transparent,
                                    icon: Icon(
                                      FFIcons.kantDesignStarFilled,
                                      color: Color(0xFFEEEEEE),
                                      size: 40.0,
                                    ),
                                    onPressed: () async {
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) {
                                          return WebViewAware(
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: CreateRewievsWidget(
                                                user: widget!
                                                    .order!.selectedDriver!,
                                                order: widget!.order!.reference,
                                                rait: 3,
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                  ),
                                  FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 8.0,
                                    buttonSize: 55.0,
                                    hoverColor: Colors.transparent,
                                    icon: Icon(
                                      FFIcons.kantDesignStarFilled,
                                      color: Color(0xFFEEEEEE),
                                      size: 40.0,
                                    ),
                                    onPressed: () async {
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) {
                                          return WebViewAware(
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: CreateRewievsWidget(
                                                user: widget!
                                                    .order!.selectedDriver!,
                                                order: widget!.order!.reference,
                                                rait: 4,
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                  ),
                                  FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 8.0,
                                    buttonSize: 55.0,
                                    hoverColor: Colors.transparent,
                                    icon: Icon(
                                      FFIcons.kantDesignStarFilled,
                                      color: Color(0xFFEEEEEE),
                                      size: 40.0,
                                    ),
                                    onPressed: () async {
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (context) {
                                          return WebViewAware(
                                            child: Padding(
                                              padding: MediaQuery.viewInsetsOf(
                                                  context),
                                              child: CreateRewievsWidget(
                                                user: widget!
                                                    .order!.selectedDriver!,
                                                order: widget!.order!.reference,
                                                rait: 5,
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget!.order?.status == StatusOrder.hidden)
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 8.0, 16.0, 16.0),
                      child: Material(
                        color: Color(0xFFF4F5F8),
                        borderRadius: BorderRadius.circular(16.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.0),
                          onTap: _repeatOrder,
                          child: Container(
                            height: 45.0,
                            alignment: Alignment.center,
                            child: Text(
                              'Повторить заказ',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'SF',
                                    color: Color(0xFF007AFF),
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
