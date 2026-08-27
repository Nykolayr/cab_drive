import 'package:cab_drive/customer/create_order/detaliy_sozdanie/widgets/custom_widget.dart';
import 'package:cab_drive/customer/create_order/detaliy_sozdanie/widgets/intermediate_point.dart';

import '../../../backend/api_requests/api_calls.dart';
import '../../create_map_page/domain/entities/entities.dart';
import '../../create_map_page/presentation/bloc/orders_bloc.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/customer/create_order/create_order/create_order_widget.dart';
import '/customer/create_order/karta/karta_widget.dart';
import '/customer/create_order/recipient/recipient_widget.dart';
import '/customer/sender/sender_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import '/pages/bottom/chips_card/chips_card_widget.dart';
import '/pages/bottom/error_popup/error_popup_widget.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'detaliy_sozdanie_model.dart';
export 'detaliy_sozdanie_model.dart';

class DetaliySozdanieWidget extends StatefulWidget {
  const DetaliySozdanieWidget({
    super.key,
    required this.car,
  });

  final Car? car;

  static String routeName = 'Detaliy_sozdanie';
  static String routePath = '/detaliySozdanie';

  @override
  State<DetaliySozdanieWidget> createState() => _DetaliySozdanieWidgetState();
}

class _DetaliySozdanieWidgetState extends State<DetaliySozdanieWidget> {
  late DetaliySozdanieModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;
  bool intermediateOn = false;

  String? _encodedPath;
  String? _pathCacheKey;
  bool _isFetchingPath = false;

  int? _lastAutoBudget;

  void _syncBudgetIfUntouched() {
    final ctl = _model.budgetTextController;
    if (ctl == null) return;
    final auto = _autoBudgetForCar();
    if (_lastAutoBudget == auto) return;
    final current = ctl.text.trim();
    final wasUntouched =
        _lastAutoBudget == null || current == _lastAutoBudget.toString();
    _lastAutoBudget = auto;
    if (wasUntouched && current != auto.toString()) {
      ctl.text = auto.toString();
    }
  }

  Future<void> _fetchRoutePath(LatLng a, LatLng b) async {
    final key = '${a.latitude},${a.longitude}|${b.latitude},${b.longitude}';
    if (_pathCacheKey == key && _encodedPath != null) return;
    if (_isFetchingPath) return;
    _isFetchingPath = true;
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${a.latitude},${a.longitude}'
        '&destination=${b.latitude},${b.longitude}'
        '&key=AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
      );
      final resp = await http.get(url);
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final decoded = json.decode(resp.body);
        if (decoded['status'] == 'OK' &&
            (decoded['routes'] as List).isNotEmpty) {
          final enc = decoded['routes'][0]['overview_polyline']['points']
              as String;
          setState(() {
            _encodedPath = enc;
            _pathCacheKey = key;
          });
        }
      }
    } catch (_) {
      // тихо игнорим — UI откатится на прямую A→B
    } finally {
      _isFetchingPath = false;
    }
  }

  int _autoBudgetForCar() {
    if (widget.car == Car.largus) return FFAppState().priceLargus;
    if (widget.car == Car.largusTermo) return FFAppState().priceTermo;
    return FFAppState().priceFiat;
  }

  bool _canSubmit() {
    if (_model.supply == null) return false;
    if (_model.supply == 2 && _model.datePicked == null) return false;
    if (FFAppState().pointA.address.isEmpty ||
        FFAppState().pointB.address.isEmpty) return false;
    if (_model.isFastOrder) return true;
    bool hasPhone(String? p) => p != null && p.isNotEmpty;
    if (!hasPhone(FFAppState().pointA.sender.phone)) return false;
    if (!hasPhone(FFAppState().pointB.sender.phone)) return false;
    if (intermediateOn &&
        !hasPhone(FFAppState().pointC.sender.phone)) return false;
    final desc = _model.descriptionTextController.text;
    if (desc == null || desc.isEmpty) return false;
    return true;
  }

  void _applyFastOrderDefaults() {
    if (!_model.isFastOrder) return;
    final phone = _userPhone();
    FFAppState().pointA.sender = SenderStruct(phone: phone);
    FFAppState().pointB.sender = SenderStruct(phone: phone);
    if (intermediateOn) {
      FFAppState().pointC.sender = SenderStruct(phone: phone);
    }
    FFAppState().update(() {});
  }

  int _resolvedBudget() {
    final raw = _model.budgetTextController?.text.trim() ?? '';
    final parsed = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
    if (parsed != null && parsed > 0) return parsed;
    return _autoBudgetForCar();
  }

  String _userPhone() => currentUserDocument?.phoneNumber ?? '';

  Widget _segmentedPill({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 36.0,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 5.5,
                      offset: Offset(0, 0),
                    ),
                  ]
                : const [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF',
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                  color: active ? const Color(0xFF181818) : const Color(0xFFA4A6B2),
                ),
          ),
        ),
      ),
    );
  }

  Widget _segmentedBar({required List<Widget> children}) {
    return Container(
      height: 40.0,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(children: children),
    );
  }

  Widget _variantCard(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вариант заказа',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    color: const Color(0xFF181818),
                    fontSize: 21.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12.0),
            _segmentedBar(children: [
              _segmentedPill(
                label: 'Обычный заказ',
                active: !_model.isFastOrder,
                onTap: () => safeSetState(() => _model.isFastOrder = false),
              ),
              _segmentedPill(
                label: 'Быстрый заказ',
                active: _model.isFastOrder,
                onTap: () => safeSetState(() => _model.isFastOrder = true),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _staticMapCard(BuildContext context) {
    final a = FFAppState().pointA.latlng;
    final b = FFAppState().pointB.latlng;

    String? url;
    if (a != null && b != null) {
      final aStr = '${a.latitude},${a.longitude}';
      final bStr = '${b.latitude},${b.longitude}';
      final cacheKey = '$aStr|$bStr';

      if (cacheKey != _pathCacheKey && !_isFetchingPath) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _fetchRoutePath(a, b));
      }

      final hasRealRoute =
          _encodedPath != null && _pathCacheKey == cacheKey;
      final pathParam = hasRealRoute
          ? 'enc:${Uri.encodeQueryComponent(_encodedPath!)}'
          : '$aStr%7C$bStr';

      url = 'https://maps.googleapis.com/maps/api/staticmap'
          '?size=400x180&scale=2&maptype=roadmap'
          '&markers=color:0x4F8AFFFF%7Csize:small%7C$aStr'
          '&markers=color:0x21AB3DFF%7C$bStr'
          '&path=color:0x4F8AFFFF%7Cweight:4%7C$pathParam'
          '&key=AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY';
    }

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      width: double.infinity,
      height: 180.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? const Center(
              child: Icon(
                Icons.map_outlined,
                size: 32.0,
                color: Color(0xFFA4A6B2),
              ),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.map_outlined,
                  size: 32.0,
                  color: Color(0xFFA4A6B2),
                ),
              ),
            ),
    );
  }

  Widget _budgetCard(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Примерный бюджет',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    color: const Color(0xFF181818),
                    fontSize: 21.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: 207.0,
                  child: _segmentedBar(children: [
                    _segmentedPill(
                      label: 'Наличными',
                      active: FFAppState().payMethod == PayMethod.cahs,
                      onTap: () {
                        FFAppState().payMethod = PayMethod.cahs;
                        safeSetState(() {});
                      },
                    ),
                    _segmentedPill(
                      label: 'Картой',
                      active: FFAppState().payMethod == PayMethod.card,
                      onTap: () {
                        FFAppState().payMethod = PayMethod.card;
                        safeSetState(() {});
                      },
                    ),
                  ]),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    controller: _model.budgetTextController,
                    focusNode: _model.budgetFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (_) => safeSetState(() {}),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Сумма',
                      hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF',
                            color: const Color(0xFFA4A6B2),
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                          ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF4F5F8), width: 2.0),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFF4F5F8), width: 2.0),
                      ),
                      contentPadding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 10.0, 0.0, 10.0),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          color: const Color(0xFF181818),
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                    validator: _model.budgetTextControllerValidator
                        ?.asValidator(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _plainCard({required Widget child}) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        child: child,
      ),
    );
  }

  Widget _supplyCard(BuildContext context) {
    return _plainCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Подача',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'SF',
                fontSize: 21.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 12,),
        Divider(
          height: 0.5,
          thickness: 0.5,
          color: Color(0xFFD0CFCE),
        ),
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            _model.supply = 1;
            safeSetState(() {});
            HapticFeedback.mediumImpact();
          },
          child: Container(
            height: 57.0,
            decoration: BoxDecoration(),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(
                      'В ближайшее время',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF',
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                  Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Visibility(
                      visible: _model.supply == 1,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).tertiary,
                            width: 8.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 0.3,
          thickness: 0.3,
          color: Color(0xFFD0CFCE),
        ),
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            HapticFeedback.mediumImpact();
            _model.supply = 2;
            safeSetState(() {});
            unawaited(
              () async {
                await showModalBottomSheet<bool>(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.dateAndTime,
                          minimumDate:
                              (getCurrentTimestamp ?? DateTime(1900)),
                          initialDateTime: ((_model.datePicked != null
                                  ? _model.datePicked
                                  : getCurrentTimestamp) ??
                              DateTime.now()),
                          maximumDate:
                              (functions.datetime24() ?? DateTime(2050)),
                          use24hFormat: false,
                          onDateTimeChanged: (newDateTime) =>
                              safeSetState(() {
                            _model.datePicked = newDateTime;
                          }),
                        ),
                      );
                    });
              }(),
            );
          },
          child: Container(
            constraints: BoxConstraints(
              minHeight: 57.0,
            ),
            decoration: BoxDecoration(),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Заказать ко времени',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'SF',
                                fontSize: 16.0,
                                letterSpacing: 0.0,
                              ),
                        ),
                        if (_model.supply == 2)
                          Text(
                            'Водитель приедет ${dateTimeFormat(
                              "d/M/y",
                              _model.datePicked,
                              locale: FFLocalizations.of(context)
                                  .languageCode,
                            )}, к ${dateTimeFormat(
                              "Hm",
                              _model.datePicked,
                              locale: FFLocalizations.of(context)
                                  .languageCode,
                            )}',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  color: Color(0xFF8F8F8E),
                                  letterSpacing: 0.0,
                                ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: 30.0,
                    height: 30.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Visibility(
                      visible: _model.supply == 2,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).tertiary,
                            width: 8.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 0.3,
          thickness: 0.3,
          color: Color(0xFFD0CFCE),
        ),
        ],
      ),
    );
  }

  Widget _descriptionCard(BuildContext context) {
    final text = (_model.descriptionTextController?.text ?? '').trim();
    final hasText = text.isNotEmpty;
    return _plainCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Описание груза',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF',
                  fontSize: 21.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6.0),
          Text(
            hasText ? text : 'Всё, что важно знать водителю',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'SF',
                  color: const Color(0xFF8F8F8E),
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                ),
            maxLines: hasText ? 6 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12.0),
          InkWell(
            borderRadius: BorderRadius.circular(20.0),
            onTap: () => _openDescriptionEditor(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                hasText ? 'Изменить' : 'Добавить описание',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF',
                      color: const Color(0xFF4F8AFF),
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDescriptionEditor(BuildContext context) async {
    final tempController = TextEditingController(
        text: _model.descriptionTextController?.text ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(sheetCtx),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Описание груза',
                  style: FlutterFlowTheme.of(sheetCtx).bodyMedium.override(
                        fontFamily: 'SF',
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12.0),
                TextField(
                  controller: tempController,
                  autofocus: true,
                  maxLines: 6,
                  minLines: 3,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Всё, что важно знать водителю',
                    hintStyle: TextStyle(
                        color: Color(0xFF8F8F8E), fontSize: 16.0),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD0CFCE)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4F8AFF)),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                FFButtonWidget(
                  text: 'Сохранить',
                  onPressed: () {
                    _model.descriptionTextController?.text =
                        tempController.text;
                    Navigator.of(sheetCtx).pop();
                  },
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 48.0,
                    color: const Color(0xFF4F8AFF),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'SF',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        );
      },
    );
    safeSetState(() {});
  }

  Widget _fastAddressesCard(BuildContext context) {
    final phone = _userPhone();
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fastAddressRow(
              context,
              label: 'Откуда',
              address: FFAppState().pointA.address,
              onTap: () async {
                await showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => WebViewAware(
                    child: Padding(
                      padding: MediaQuery.viewInsetsOf(context),
                      child: const KartaWidget(point: 'A'),
                    ),
                  ),
                ).then((_) => safeSetState(() {}));
              },
            ),
            const Divider(height: 1.0, thickness: 1.0, color: Color(0xFFF4F5F8)),
            _fastAddressRow(
              context,
              label: 'Куда',
              address: FFAppState().pointB.address,
              onTap: () async {
                await showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => WebViewAware(
                    child: Padding(
                      padding: MediaQuery.viewInsetsOf(context),
                      child: const KartaWidget(point: 'B'),
                    ),
                  ),
                ).then((_) => safeSetState(() {}));
              },
            ),
            if (phone.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                child: Text(
                  phone,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        color: const Color(0xFF181818),
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fastAddressRow(
    BuildContext context, {
    required String label,
    required String address,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          color: const Color(0xFFA4A6B2),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    address.isEmpty ? '—' : address,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          color: const Color(0xFF21201F),
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              FFIcons.kiconrightStroke,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetaliySozdanieModel());

    // Синхронизируем FFAppState с визуальным состоянием UI (по умолчанию выбрана карта)
    FFAppState().payMethod = PayMethod.card;

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }


    _lastAutoBudget = _autoBudgetForCar();
    _model.budgetTextController ??= TextEditingController(
      text: _lastAutoBudget.toString(),
    );
    _model.budgetFocusNode ??= FocusNode();

    _model.entranceATextController ??= TextEditingController();
    _model.entranceAFocusNode ??= FocusNode();

    _model.entranceAMask = MaskTextInputFormatter(mask: '###');
    _model.flatATextController ??= TextEditingController();
    _model.flatAFocusNode ??= FocusNode();

    _model.floorATextController ??= TextEditingController();
    _model.floorAFocusNode ??= FocusNode();

    _model.floorAMask = MaskTextInputFormatter(mask: '###');
    _model.intercomATextController ??= TextEditingController();
    _model.intercomAFocusNode ??= FocusNode();

    _model.commentATextController ??= TextEditingController();
    _model.commentAFocusNode ??= FocusNode();

    _model.entranceBTextController ??= TextEditingController();
    _model.entranceBFocusNode ??= FocusNode();

    _model.flatBTextController ??= TextEditingController();
    _model.flatBFocusNode ??= FocusNode();

    _model.floorBTextController ??= TextEditingController();
    _model.floorBFocusNode ??= FocusNode();

    _model.intercomBTextController ??= TextEditingController();
    _model.intercomBFocusNode ??= FocusNode();

    _model.commentBTextController ??= TextEditingController();
    _model.commentBFocusNode ??= FocusNode();

    _model.entranceCTextController ??= TextEditingController();
    _model.entranceCFocusNode ??= FocusNode();

    _model.flatCTextController ??= TextEditingController();
    _model.flatCFocusNode ??= FocusNode();

    _model.floorCTextController ??= TextEditingController();
    _model.floorCFocusNode ??= FocusNode();

    _model.intercomCTextController ??= TextEditingController();
    _model.intercomCFocusNode ??= FocusNode();

    _model.commentCTextController ??= TextEditingController();
    _model.commentCFocusNode ??= FocusNode();

    _model.descriptionTextController ??= TextEditingController();
    _model.descriptionFocusNode ??= FocusNode();
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
    _syncBudgetIfUntouched();

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
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wrapWithModel(
                  model: _model.appBarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: AppBarWidget(
                    text: 'Детали заказа',
                  ),
                ),
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: SingleChildScrollView(
                        primary: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _variantCard(context),
                            _staticMapCard(context),
                            _budgetCard(context),
                            _supplyCard(context),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 6.0, 24.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Кузов – ${() {
                                        if (widget!.car == Car.largus) {
                                          return 'Мини S';
                                        } else if (widget!.car ==
                                            Car.largusTermo) {
                                          return 'Термобудка S-M';
                                        } else {
                                          return 'МиниПлюс M';
                                        }
                                      }()}',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'SF',
                                            fontSize: 21.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (widget!.car == Car.fiat)
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 4.0, 0.0, 0.0),
                                        child: Text(
                                          'Fiat Doblò/Citroën Berlingo/PEUGEOT PARTNER ',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'SF',
                                                color: Color(0xFF8F8F8E),
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                    Stack(
                                      children: [
                                        if (widget!.car == Car.largus)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.asset(
                                              'assets/images/bi6d9_.png',
                                              width: double.infinity,
                                              height: 130.0,
                                              fit: BoxFit.cover,
                                              alignment: Alignment(0.0, 1.0),
                                            ),
                                          ),
                                        if (widget!.car == Car.largusTermo)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.asset(
                                              'assets/images/8q3cb_.png',
                                              width: double.infinity,
                                              height: 130.0,
                                              fit: BoxFit.cover,
                                              alignment: Alignment(0.0, 1.0),
                                            ),
                                          ),
                                        if (widget!.car == Car.fiat)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.asset(
                                              'assets/images/49svh_2.png',
                                              width: double.infinity,
                                              height: 130.0,
                                              fit: BoxFit.cover,
                                              alignment: Alignment(0.0, 1.0),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 10.0),
                                      child: Text(
                                        () {
                                          if (widget!.car == Car.largus) {
                                            return 'Подойдет для нескольких коробок. Максимум 300 кг';
                                          } else if (widget!.car ==
                                              Car.largusTermo) {
                                            return 'Можно перевозить замороженные продукты. Грузоподъёмность 850-1500 кг';
                                          } else {
                                            return 'Максимум 800 кг';
                                          }
                                        }(),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'SF',
                                              color: Color(0xFF8F8F8E),
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ),
                                    Divider(
                                      height: 0.3,
                                      thickness: 0.3,
                                      color: Color(0xFFD0CFCE),
                                    ),
                                    Divider(
                                      height: 0.3,
                                      thickness: 0.3,
                                      color: Color(0xFFD0CFCE),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 4.0, 0.0, 4.0),
                                      child: Container(
                                        height: 57.0,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Грузчики',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  Text(
                                                    valueOrDefault<String>(
                                                      FFAppState().movers != 0
                                                          ? 'Каждая вещь до 30 кг'
                                                          : 'Помощь не нужна',
                                                      'Помощь не нужна',
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          color:
                                                              Color(0xFF8F8F8E),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 41.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        FFAppState().movers = 0;
                                                        safeSetState(() {});
                                                        HapticFeedback
                                                            .mediumImpact();
                                                        context.read<OrdersBloc>().add(
                                                            OrdersEvent.getPrices(
                                                                userLocation: LocationEntity(
                                                                    lat: FFAppState().pointA
                                                                        .latlng!.latitude,
                                                                    lng: FFAppState().pointA
                                                                        .latlng!.longitude),
                                                                destLocation: LocationEntity(
                                                                    lat: FFAppState().pointB
                                                                        .latlng!.latitude,
                                                                    lng: FFAppState().pointB
                                                                        .latlng!.longitude),
                                                                intermediate: FFAppState().pointC.address.isNotEmpty ? LocationEntity(
                                                                    lat: FFAppState().pointC
                                                                        .latlng!.latitude,
                                                                    lng: FFAppState().pointC
                                                                        .latlng!.longitude) : null,
                                                                movers: FFAppState().movers));
                                                      },
                                                      child: Container(
                                                        width: 61.0,
                                                        height: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: valueOrDefault<
                                                              Color>(
                                                            FFAppState().movers ==
                                                                    0
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground
                                                                : Colors
                                                                    .transparent,
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryBackground,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            'Нет',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color:
                                                                      valueOrDefault<
                                                                          Color>(
                                                                    FFAppState().movers ==
                                                                            0
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primaryText
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                  ),
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        FFAppState().movers = 1;
                                                        safeSetState(() {});
                                                        HapticFeedback
                                                            .mediumImpact();

                                                        context.read<OrdersBloc>().add(
                                                            OrdersEvent.getPrices(
                                                                userLocation: LocationEntity(
                                                                    lat: FFAppState().pointA
                                                                        .latlng!.latitude,
                                                                    lng: FFAppState().pointA
                                                                        .latlng!.longitude),
                                                                destLocation: LocationEntity(
                                                                    lat: FFAppState().pointB
                                                                        .latlng!.latitude,
                                                                    lng: FFAppState().pointB
                                                                        .latlng!.longitude),
                                                                intermediate: FFAppState().pointC.address.isNotEmpty ? LocationEntity(
                                                                    lat: FFAppState().pointC
                                                                        .latlng!.latitude,
                                                                    lng: FFAppState().pointC
                                                                        .latlng!.longitude) : null,
                                                                movers: FFAppState().movers));
                                                      },
                                                      child: Container(
                                                        width: 43.0,
                                                        height: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: valueOrDefault<
                                                              Color>(
                                                            FFAppState().movers ==
                                                                    1
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground
                                                                : Colors
                                                                    .transparent,
                                                            Colors.transparent,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            '1',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color:
                                                                      valueOrDefault<
                                                                          Color>(
                                                                    FFAppState().movers ==
                                                                            1
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primaryText
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                  ),
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        FFAppState().movers = 2;
                                                        safeSetState(() {});
                                                        HapticFeedback
                                                            .mediumImpact();
                                                        context.read<OrdersBloc>().add(
                                                            OrdersEvent.getPrices(
                                                                userLocation: LocationEntity(
                                                                    lat: FFAppState().pointA
                                                                        .latlng!.latitude,
                                                                    lng: FFAppState().pointA
                                                                        .latlng!.longitude),
                                                                destLocation: LocationEntity(
                                                                    lat: FFAppState().pointB
                                                                        .latlng!.latitude,
                                                                    lng: FFAppState().pointB
                                                                        .latlng!.longitude),
                                                                intermediate: FFAppState().pointC.address.isNotEmpty ? LocationEntity(
                                                                    lat: FFAppState().pointC
                                                                        .latlng!.latitude,
                                                                    lng: FFAppState().pointC
                                                                        .latlng!.longitude) : null,
                                                                movers: FFAppState().movers));
                                                      },
                                                      child: Container(
                                                        width: 43.0,
                                                        height: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: valueOrDefault<
                                                              Color>(
                                                            FFAppState().movers ==
                                                                    2
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondaryBackground
                                                                : Colors
                                                                    .transparent,
                                                            Colors.transparent,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              AlignmentDirectional(
                                                                  0.0, 0.0),
                                                          child: Text(
                                                            '2',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color:
                                                                      valueOrDefault<
                                                                          Color>(
                                                                    FFAppState().movers ==
                                                                            2
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .primaryText
                                                                        : FlutterFlowTheme.of(context)
                                                                            .secondaryText,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondaryText,
                                                                  ),
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_model.isFastOrder)
                              _fastAddressesCard(context),
                            if (!_model.isFastOrder)
                              Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 6.0, 24.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Откуда',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'SF',
                                            fontSize: 21.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) {
                                            return WebViewAware(
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: KartaWidget(
                                                    point: 'A',
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).then((value) => safeSetState(() {}));
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                          minHeight: 57.0,
                                        ),
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                FFAppState().pointA.address,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ),
                                            Icon(
                                              FFIcons.kiconrightStroke,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 12.0,
                                            ),
                                          ].divide(SizedBox(width: 12.0)),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 0.3,
                                      thickness: 0.3,
                                      color: Color(0xFFD0CFCE),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _model.entranceATextController,
                                            focusNode:
                                                _model.entranceAFocusNode,
                                            onFieldSubmitted: (_) async {
                                              FFAppState().updatePointAStruct(
                                                (e) => e
                                                  ..entrance = int.tryParse(_model
                                                      .entranceATextController
                                                      .text),
                                              );
                                              safeSetState(() {});
                                            },
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              labelText: 'Подъезд',
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            Color(0xFF8F8F8E),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 3.0, 0.0, 3.0),
                                              hoverColor: Colors.transparent,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                            keyboardType: TextInputType.number,
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .entranceATextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              _model.entranceAMask
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _model.flatATextController,
                                            focusNode: _model.flatAFocusNode,
                                            onFieldSubmitted: (_) async {
                                              FFAppState().updatePointAStruct(
                                                (e) => e
                                                  ..flat = _model
                                                      .flatATextController.text,
                                              );
                                              safeSetState(() {});
                                            },
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              labelText: 'Кв./офис',
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            Color(0xFF8F8F8E),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 3.0, 0.0, 3.0),
                                              hoverColor: Colors.transparent,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .flatATextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              if (!isAndroid && !isiOS)
                                                TextInputFormatter.withFunction(
                                                    (oldValue, newValue) {
                                                  return TextEditingValue(
                                                    selection:
                                                        newValue.selection,
                                                    text: newValue.text
                                                        .toCapitalization(
                                                            TextCapitalization
                                                                .sentences),
                                                  );
                                                }),
                                            ],
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _model.floorATextController,
                                            focusNode: _model.floorAFocusNode,
                                            onFieldSubmitted: (_) async {
                                              FFAppState().updatePointAStruct(
                                                (e) => e
                                                  ..floor = int.tryParse(_model
                                                      .floorATextController
                                                      .text),
                                              );
                                              safeSetState(() {});
                                            },
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              labelText: 'Этаж',
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            Color(0xFF8F8F8E),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 3.0, 0.0, 3.0),
                                              hoverColor: Colors.transparent,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                            keyboardType: TextInputType.number,
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .floorATextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              _model.floorAMask
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _model.intercomATextController,
                                            focusNode:
                                                _model.intercomAFocusNode,
                                            onFieldSubmitted: (_) async {
                                              FFAppState().updatePointAStruct(
                                                (e) => e
                                                  ..intercom = _model
                                                      .intercomATextController
                                                      .text,
                                              );
                                              safeSetState(() {});
                                            },
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              labelText: 'Домофон',
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            Color(0xFF8F8F8E),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 3.0, 0.0, 3.0),
                                              hoverColor: Colors.transparent,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .intercomATextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              if (!isAndroid && !isiOS)
                                                TextInputFormatter.withFunction(
                                                    (oldValue, newValue) {
                                                  return TextEditingValue(
                                                    selection:
                                                        newValue.selection,
                                                    text: newValue.text
                                                        .toCapitalization(
                                                            TextCapitalization
                                                                .sentences),
                                                  );
                                                }),
                                            ],
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller:
                                            _model.commentATextController,
                                        focusNode: _model.commentAFocusNode,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.commentATextController',
                                          Duration(milliseconds: 0),
                                          () => safeSetState(() {}),
                                        ),
                                        onFieldSubmitted: (_) async {
                                          FFAppState().updatePointAStruct(
                                            (e) => e
                                              ..comment = _model
                                                  .commentATextController.text,
                                          );
                                          safeSetState(() {});
                                        },
                                        autofocus: false,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: false,
                                          labelText: 'Комментарий водителю',
                                          labelStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily: 'SF',
                                                    color: Color(0xFF8F8F8E),
                                                    fontSize: 16.0,
                                                    letterSpacing: 0.0,
                                                  ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFD0CFCE),
                                              width: 0.3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFD0CFCE),
                                              width: 0.3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 0.3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 0.3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 3.0, 0.0, 3.0),
                                          hoverColor: Colors.transparent,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'SF',
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                            ),
                                        maxLength: 300,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        validator: _model
                                            .commentATextControllerValidator
                                            .asValidator(context),
                                        inputFormatters: [
                                          if (!isAndroid && !isiOS)
                                            TextInputFormatter.withFunction(
                                                (oldValue, newValue) {
                                              return TextEditingValue(
                                                selection: newValue.selection,
                                                text: newValue.text
                                                    .toCapitalization(
                                                        TextCapitalization
                                                            .sentences),
                                              );
                                            }),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) {
                                            return WebViewAware(
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: SenderWidget(),
                                                ),
                                              ),
                                            );
                                          },
                                        ).then((value) => safeSetState(() {}));
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 57.0,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Контакт отправителя*',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          lineHeight: 1.0,
                                                        ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                if (FFAppState()
                                                        .pointA
                                                        .sender !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                8.0, 0.0),
                                                    child: Text(
                                                      valueOrDefault<String>(
                                                        FFAppState()
                                                                    .pointA
                                                                    .sender !=
                                                                null
                                                            ? functions
                                                                .formatPhoneNumber1(
                                                                    FFAppState()
                                                                        .pointA
                                                                        .sender
                                                                        .phone)
                                                            : '  ',
                                                        'Номер телефона',
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'SF',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            fontSize: 14.0,
                                                            letterSpacing: 0.0,
                                                            lineHeight: 1.0,
                                                          ),
                                                    ),
                                                  ),
                                                Icon(
                                                  FFIcons.kiconrightStroke,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 12.0,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),



                            IntermediatePoint(safeSetState: safeSetState, model: _model,isExpanded: (v) {
                              intermediateOn = v;

                              if(!intermediateOn)
                                FFAppState()
                              .pointC = PointStruct();
                            }, onSelectAddress: () {
                              context.read<OrdersBloc>().add(
                                  OrdersEvent.getPrices(
                                      userLocation: LocationEntity(
                                          lat: FFAppState().pointA
                                              .latlng!.latitude,
                                          lng: FFAppState().pointA
                                              .latlng!.longitude),
                                      destLocation: LocationEntity(
                                          lat: FFAppState().pointB
                                              .latlng!.latitude,
                                          lng: FFAppState().pointB
                                              .latlng!.longitude),
                                      intermediate: FFAppState().pointC.address.isNotEmpty ? LocationEntity(
                                          lat: FFAppState().pointC
                                              .latlng!.latitude,
                                          lng: FFAppState().pointC
                                              .latlng!.longitude) : null,
                                      movers: FFAppState().movers));
                            },),

                            if (!_model.isFastOrder)
                              Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 16.0, 24.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Куда',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'SF',
                                            fontSize: 21.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) {
                                            return WebViewAware(
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: KartaWidget(
                                                    point: 'B',
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ).then((value) => safeSetState(() {}));
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                          minHeight: 57.0,
                                        ),
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                FFAppState().pointB.address,
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                              ),
                                            ),
                                            Icon(
                                              FFIcons.kiconrightStroke,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primaryText,
                                              size: 12.0,
                                            ),
                                          ].divide(SizedBox(width: 12.0)),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      height: 0.3,
                                      thickness: 0.3,
                                      color: Color(0xFFD0CFCE),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _model.entranceBTextController,
                                            focusNode:
                                                _model.entranceBFocusNode,
                                            onFieldSubmitted: (_) async {
                                              FFAppState().updatePointBStruct(
                                                (e) => e
                                                  ..entrance = int.tryParse(_model
                                                      .entranceBTextController
                                                      .text),
                                              );
                                              safeSetState(() {});
                                            },
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              labelText: 'Подъезд',
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            Color(0xFF8F8F8E),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 3.0, 0.0, 3.0),
                                              hoverColor: Colors.transparent,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .entranceBTextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              if (!isAndroid && !isiOS)
                                                TextInputFormatter.withFunction(
                                                    (oldValue, newValue) {
                                                  return TextEditingValue(
                                                    selection:
                                                        newValue.selection,
                                                    text: newValue.text
                                                        .toCapitalization(
                                                            TextCapitalization
                                                                .sentences),
                                                  );
                                                }),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _model.flatBTextController,
                                            focusNode: _model.flatBFocusNode,
                                            onFieldSubmitted: (_) async {
                                              FFAppState().updatePointBStruct(
                                                (e) => e
                                                  ..flat = _model
                                                      .flatBTextController.text,
                                              );
                                              safeSetState(() {});
                                            },
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              labelText: 'Кв./офис',
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            Color(0xFF8F8F8E),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 3.0, 0.0, 3.0),
                                              hoverColor: Colors.transparent,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .flatBTextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              if (!isAndroid && !isiOS)
                                                TextInputFormatter.withFunction(
                                                    (oldValue, newValue) {
                                                  return TextEditingValue(
                                                    selection:
                                                        newValue.selection,
                                                    text: newValue.text
                                                        .toCapitalization(
                                                            TextCapitalization
                                                                .sentences),
                                                  );
                                                }),
                                            ],
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _model.floorBTextController,
                                            focusNode: _model.floorBFocusNode,
                                            onFieldSubmitted: (_) async {
                                              FFAppState().updatePointBStruct(
                                                (e) => e
                                                  ..floor = int.tryParse(_model
                                                      .floorBTextController
                                                      .text),
                                              );
                                              safeSetState(() {});
                                            },
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              labelText: 'Этаж',
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            Color(0xFF8F8F8E),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 3.0, 0.0, 3.0),
                                              hoverColor: Colors.transparent,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .floorBTextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              if (!isAndroid && !isiOS)
                                                TextInputFormatter.withFunction(
                                                    (oldValue, newValue) {
                                                  return TextEditingValue(
                                                    selection:
                                                        newValue.selection,
                                                    text: newValue.text
                                                        .toCapitalization(
                                                            TextCapitalization
                                                                .sentences),
                                                  );
                                                }),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                _model.intercomBTextController,
                                            focusNode:
                                                _model.intercomBFocusNode,
                                            onFieldSubmitted: (_) async {
                                              FFAppState().updatePointBStruct(
                                                (e) => e
                                                  ..intercom = _model
                                                      .intercomBTextController
                                                      .text,
                                              );
                                              safeSetState(() {});
                                            },
                                            autofocus: false,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            textInputAction:
                                                TextInputAction.next,
                                            obscureText: false,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              labelText: 'Домофон',
                                              labelStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            Color(0xFF8F8F8E),
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0xFFD0CFCE),
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              errorBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              focusedErrorBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .error,
                                                  width: 0.3,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                              contentPadding:
                                                  EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 3.0, 0.0, 3.0),
                                              hoverColor: Colors.transparent,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                            cursorColor:
                                                FlutterFlowTheme.of(context)
                                                    .primaryText,
                                            validator: _model
                                                .intercomBTextControllerValidator
                                                .asValidator(context),
                                            inputFormatters: [
                                              if (!isAndroid && !isiOS)
                                                TextInputFormatter.withFunction(
                                                    (oldValue, newValue) {
                                                  return TextEditingValue(
                                                    selection:
                                                        newValue.selection,
                                                    text: newValue.text
                                                        .toCapitalization(
                                                            TextCapitalization
                                                                .sentences),
                                                  );
                                                }),
                                            ],
                                          ),
                                        ),
                                      ].divide(SizedBox(width: 16.0)),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller:
                                            _model.commentBTextController,
                                        focusNode: _model.commentBFocusNode,
                                        onChanged: (_) => EasyDebounce.debounce(
                                          '_model.commentBTextController',
                                          Duration(milliseconds: 0),
                                          () => safeSetState(() {}),
                                        ),
                                        onFieldSubmitted: (_) async {
                                          FFAppState().updatePointBStruct(
                                            (e) => e
                                              ..comment = _model
                                                  .commentBTextController.text,
                                          );
                                          safeSetState(() {});
                                        },
                                        autofocus: false,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          isDense: false,
                                          labelText: 'Комментарий водителю',
                                          labelStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .override(
                                                    fontFamily: 'SF',
                                                    color: Color(0xFF8F8F8E),
                                                    fontSize: 16.0,
                                                    letterSpacing: 0.0,
                                                  ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFD0CFCE),
                                              width: 0.3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFD0CFCE),
                                              width: 0.3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          errorBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 0.3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          focusedErrorBorder:
                                              UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .error,
                                              width: 0.3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                          contentPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 3.0, 0.0, 3.0),
                                          hoverColor: Colors.transparent,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'SF',
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                            ),
                                        maxLength: 300,
                                        cursorColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        validator: _model
                                            .commentBTextControllerValidator
                                            .asValidator(context),
                                        inputFormatters: [
                                          if (!isAndroid && !isiOS)
                                            TextInputFormatter.withFunction(
                                                (oldValue, newValue) {
                                              return TextEditingValue(
                                                selection: newValue.selection,
                                                text: newValue.text
                                                    .toCapitalization(
                                                        TextCapitalization
                                                            .sentences),
                                              );
                                            }),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        await showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) {
                                            return WebViewAware(
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: RecipientWidget(),
                                                ),
                                              ),
                                            );
                                          },
                                        ).then((value) => safeSetState(() {}));
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 57.0,
                                        decoration: BoxDecoration(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Контакт получателя*',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          lineHeight: 1.0,
                                                        ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                if (FFAppState()
                                                        .pointB
                                                        .sender !=
                                                    null)
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                8.0, 0.0),
                                                    child: Text(
                                                      valueOrDefault<String>(
                                                        FFAppState()
                                                                    .pointB
                                                                    .sender !=
                                                                null
                                                            ? functions
                                                                .formatPhoneNumber1(
                                                                    FFAppState()
                                                                        .pointB
                                                                        .sender
                                                                        .phone)
                                                            : '  ',
                                                        'Номер телефона',
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'SF',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            fontSize: 14.0,
                                                            letterSpacing: 0.0,
                                                            lineHeight: 1.0,
                                                          ),
                                                    ),
                                                  ),
                                                Icon(
                                                  FFIcons.kiconrightStroke,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 12.0,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!_model.isFastOrder)
                              _descriptionCard(context),
                            if (!_model.isFastOrder)
                              Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 6.0, 24.0, 6.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Фото груза',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'SF',
                                                fontSize: 21.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        FFButtonWidget(
                                          onPressed: (_model.images.length >=
                                                  10)
                                              ? null
                                              : () async {
                                                  final selectedMedia =
                                                      await selectMedia(
                                                    maxWidth: 500.00,
                                                    maxHeight: 500.00,
                                                    imageQuality: 95,
                                                    mediaSource: MediaSource
                                                        .photoGallery,
                                                    multiImage: true,
                                                  );
                                                  if (selectedMedia != null &&
                                                      selectedMedia.every((m) =>
                                                          validateFileFormat(
                                                              m.storagePath,
                                                              context))) {
                                                    safeSetState(() => _model
                                                            .isDataUploading_uploadDataH1g3 =
                                                        true);
                                                    var selectedUploadedFiles =
                                                        <FFUploadedFile>[];

                                                    try {
                                                      selectedUploadedFiles =
                                                          selectedMedia
                                                              .map((m) =>
                                                                  FFUploadedFile(
                                                                    name: m
                                                                        .storagePath
                                                                        .split(
                                                                            '/')
                                                                        .last,
                                                                    bytes:
                                                                        m.bytes,
                                                                    height: m
                                                                        .dimensions
                                                                        ?.height,
                                                                    width: m
                                                                        .dimensions
                                                                        ?.width,
                                                                    blurHash: m
                                                                        .blurHash,
                                                                  ))
                                                              .toList();
                                                    } finally {
                                                      _model.isDataUploading_uploadDataH1g3 =
                                                          false;
                                                    }
                                                    if (selectedUploadedFiles
                                                            .length ==
                                                        selectedMedia.length) {
                                                      safeSetState(() {
                                                        _model.uploadedLocalFiles_uploadDataH1g3 =
                                                            selectedUploadedFiles;
                                                      });
                                                    } else {
                                                      safeSetState(() {});
                                                      return;
                                                    }
                                                  }

                                                  if (_model
                                                      .uploadedLocalFiles_uploadDataH1g3
                                                      .isNotEmpty) {
                                                    if (_model
                                                            .uploadedLocalFiles_uploadDataH1g3
                                                            .length >
                                                        (10 -
                                                            _model.images
                                                                .length)) {
                                                      safeSetState(() {
                                                        _model.isDataUploading_uploadDataH1g3 =
                                                            false;
                                                        _model.uploadedLocalFiles_uploadDataH1g3 =
                                                            [];
                                                      });

                                                      await showModalBottomSheet(
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        context: context,
                                                        builder: (context) {
                                                          return WebViewAware(
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                FocusScope.of(
                                                                        context)
                                                                    .unfocus();
                                                                FocusManager
                                                                    .instance
                                                                    .primaryFocus
                                                                    ?.unfocus();
                                                              },
                                                              child: Padding(
                                                                padding: MediaQuery
                                                                    .viewInsetsOf(
                                                                        context),
                                                                child:
                                                                    ErrorPopupWidget(
                                                                  title:
                                                                      'Что-то пошло не так',
                                                                  text:
                                                                      'Максимальное количество изображений - 10!',
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).then((value) =>
                                                          safeSetState(() {}));

                                                      return;
                                                    } else {
                                                      if (_model
                                                              .images.length ==
                                                          0) {
                                                        _model.images = _model
                                                            .uploadedLocalFiles_uploadDataH1g3
                                                            .toList()
                                                            .cast<
                                                                FFUploadedFile>();
                                                        safeSetState(() {});
                                                      } else {
                                                        _model.images = functions
                                                            .myCustomFileFunction(
                                                                _model.images
                                                                    .toList(),
                                                                _model
                                                                    .uploadedLocalFiles_uploadDataH1g3
                                                                    .toList())
                                                            .toList()
                                                            .cast<
                                                                FFUploadedFile>();
                                                        safeSetState(() {});
                                                      }

                                                      safeSetState(() {
                                                        _model.isDataUploading_uploadDataH1g3 =
                                                            false;
                                                        _model.uploadedLocalFiles_uploadDataH1g3 =
                                                            [];
                                                      });

                                                      return;
                                                    }
                                                  } else {
                                                    return;
                                                  }
                                                },
                                          text: 'Добавить',
                                          options: FFButtonOptions(
                                            height: 35.0,
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            textStyle: FlutterFlowTheme.of(
                                                    context)
                                                .titleSmall
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .tertiary,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                            elevation: 0.0,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            disabledTextColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                          ),
                                          showLoadingIndicator: false,
                                        ),
                                      ],
                                    ),
                                    if (_model.images.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 12.0, 0.0, 0.0),
                                        child: Builder(
                                          builder: (context) {
                                            final imagesCargo =
                                                _model.images.toList();

                                            return GridView.builder(
                                              padding: EdgeInsets.zero,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 5,
                                                crossAxisSpacing: 6.0,
                                                mainAxisSpacing: 6.0,
                                                childAspectRatio: 1.0,
                                              ),
                                              primary: false,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: imagesCargo.length,
                                              itemBuilder:
                                                  (context, imagesCargoIndex) {
                                                final imagesCargoItem =
                                                    imagesCargo[
                                                        imagesCargoIndex];
                                                return Stack(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, -1.0),
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: Image.memory(
                                                        imagesCargoItem.bytes ??
                                                            Uint8List.fromList(
                                                                []),
                                                        width: double.infinity,
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    FlutterFlowIconButton(
                                                      borderColor:
                                                          Colors.transparent,
                                                      borderRadius: 10.0,
                                                      buttonSize: 40.0,
                                                      fillColor:
                                                          Color(0x69161616),
                                                      icon: Icon(
                                                        FFIcons.kkrestStroke,
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        size: 14.0,
                                                      ),
                                                      onPressed: () async {
                                                        _model.removeFromImages(
                                                            imagesCargoItem);
                                                        safeSetState(() {});
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 5.0)),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        8.0,
                        0.0,
                        8.0,
                        valueOrDefault<double>(
                          (isWeb
                                  ? MediaQuery.viewInsetsOf(context).bottom > 0
                                  : _isKeyboardVisible)
                              ? 8.0
                              : 35.0,
                          35.0,
                        )),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Builder(
                          builder: (context) {
                            if (_canSubmit()) {
                              return FFButtonWidget(
                                onPressed: () async {
                                  unawaited(
                                    () async {
                                      await actions.closeKeyboard();
                                    }(),
                                  );
                                  _applyFastOrderDefaults();
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    isDismissible: false,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return WebViewAware(
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: CreateOrderWidget(
                                              intermediateOn: intermediateOn,
                                              supply: _model.supply!,
                                              dateTime: _model.datePicked,
                                              movers: FFAppState().movers,
                                              images: _model.isFastOrder
                                                  ? const []
                                                  : _model.images,
                                              description: _model.isFastOrder
                                                  ? ''
                                                  : _model
                                                      .descriptionTextController
                                                      .text,
                                              budget: _resolvedBudget(),
                                              car: widget!.car!,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                text: 'Создать заказ',
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
                                        fontWeight: FontWeight.w500,
                                      ),
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                showLoadingIndicator: false,
                              );
                            } else {
                              return Container(
                                width: double.infinity,
                                height: 56.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFFEEEEEE),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Создать заказ',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'SF',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Text(
                                      'Заполните все данные о заказе',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'SF',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.normal,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
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
