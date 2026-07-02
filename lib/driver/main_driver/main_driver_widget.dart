import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/driver/filters/filters_widget.dart';
import '/driver/net_poiska/net_poiska_widget.dart';
import '/driver/order_card_driver/order_card_driver_widget.dart';
import '/driver/vkl_geo_copy/vkl_geo_copy_widget.dart';
import '/driver/za_chto_plata_copy/za_chto_plata_copy_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_timer.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/error_popup/error_popup_widget.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'main_driver_model.dart';
export 'main_driver_model.dart';

class MainDriverWidget extends StatefulWidget {
  const MainDriverWidget({super.key});

  static String routeName = 'MAIN_DRIVER';
  static String routePath = '/mainDriver';

  @override
  State<MainDriverWidget> createState() => _MainDriverWidgetState();
}

class _MainDriverWidgetState extends State<MainDriverWidget> {
  late MainDriverModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng currentUserLocationValue = const LatLng(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDriverModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if ((valueOrDefault(currentUserDocument?.balance, 0.0) < 0.0) &&
          (valueOrDefault<bool>(currentUserDocument?.fine, false) == false) &&
          functions.hours48(currentUserDocument!.shiftCompletionDateTime!)) {
        await currentUserReference!.update({
          ...createUsersRecordData(
            lastOnline: functions.toUtc(),
            fine: true,
          ),
          ...mapToFirestore(
            {
              'balance': FieldValue.increment(-(3000.0)),
            },
          ),
        });
        await showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            return WebViewAware(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Padding(
                  padding: MediaQuery.viewInsetsOf(context),
                  child: const ErrorPopupWidget(
                    title: 'Начислен штраф 3000 ₽',
                    text:
                        'Вы не оплатили комиссию вовремя — к балансу добавлен штраф 3000 ₽.',
                  ),
                ),
              ),
            );
          },
        ).then((value) => safeSetState(() {}));

        return;
      } else {
        unawaited(
          () async {
            await currentUserReference!.update({
              ...createUsersRecordData(
                lastOnline: functions.toUtc(),
              ),
              ...mapToFirestore(
                {
                  'fine': FieldValue.delete(),
                },
              ),
            });
          }(),
        );
      }
    });

    getCurrentUserLocation(
            defaultLocation: const LatLng(0.0, 0.0), cached: true)
        .timeout(
      const Duration(seconds: 8),
      onTimeout: () => const LatLng(0.0, 0.0),
    )
        .then((loc) {
      if (!mounted) return;
      safeSetState(() => currentUserLocationValue = loc);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

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
        body: Builder(
          builder: (context) {
            if (valueOrDefault<bool>(currentUserDocument?.onShift, false)) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 5.0),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        minHeight: 120.0,
                      ),
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
                              16.0, 50.0, 16.0, 16.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            direction: Axis.horizontal,
                            runAlignment: WrapAlignment.start,
                            verticalDirection: VerticalDirection.down,
                            clipBehavior: Clip.none,
                            children: [
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
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: const FiltersWidget(),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                child: Container(
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primary,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            12.0, 0.0, 12.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 6.0, 0.0),
                                          child: Text(
                                            'Фильтры ',
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
                                        Icon(
                                          FFIcons.kmenu04,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                          size: 20.0,
                                        ),
                                        if ((FFAppState().filter.ott != 0) ||
                                            (FFAppState().filter.doo != 0) ||
                                            (FFAppState().filter.supply != 0) ||
                                            (FFAppState().filter.radius != 0.0))
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(8.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                              width: 22.0,
                                              height: 22.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Align(
                                                alignment:
                                                    const AlignmentDirectional(
                                                        0.0, 0.0),
                                                child: Text(
                                                  (valueOrDefault<int>(
                                                            FFAppState()
                                                                        .filter
                                                                        .radius !=
                                                                    0.0
                                                                ? 1
                                                                : 0,
                                                            0,
                                                          ) +
                                                          valueOrDefault<int>(
                                                            (FFAppState()
                                                                            .filter
                                                                            .ott !=
                                                                        0) ||
                                                                    (FFAppState()
                                                                            .filter
                                                                            .doo !=
                                                                        0)
                                                                ? 1
                                                                : 0,
                                                            0,
                                                          ) +
                                                          valueOrDefault<int>(
                                                            FFAppState()
                                                                        .filter
                                                                        .supply !=
                                                                    0
                                                                ? 1
                                                                : 0,
                                                            0,
                                                          ))
                                                      .toString(),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
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
                              if (FFAppState().filter.ott != 0)
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().updateFilterStruct(
                                      (e) => e..ott = null,
                                    );
                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              12.0, 0.0, 12.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            formatNumber(
                                              FFAppState().filter.ott,
                                              formatType: FormatType.custom,
                                              format: 'От 0 ₽',
                                              locale: '',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(8.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                              width: 19.0,
                                              height: 19.0,
                                              decoration: const BoxDecoration(
                                                color: Color(0x32FFFFFF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                FFIcons.kkrestStroke,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                size: 9.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (FFAppState().filter.doo != 0)
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().updateFilterStruct(
                                      (e) => e..doo = null,
                                    );
                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              12.0, 0.0, 12.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            formatNumber(
                                              FFAppState().filter.doo,
                                              formatType: FormatType.custom,
                                              format: 'До 0 ₽',
                                              locale: '',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(8.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                              width: 19.0,
                                              height: 19.0,
                                              decoration: const BoxDecoration(
                                                color: Color(0x32FFFFFF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                FFIcons.kkrestStroke,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                size: 9.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (FFAppState().filter.supply != 0)
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().updateFilterStruct(
                                      (e) => e..supply = null,
                                    );
                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              12.0, 0.0, 12.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            FFAppState().filter.supply == 1
                                                ? 'В ближайшее время'
                                                : 'Ко времени',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(8.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                              width: 19.0,
                                              height: 19.0,
                                              decoration: const BoxDecoration(
                                                color: Color(0x32FFFFFF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                FFIcons.kkrestStroke,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                size: 9.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (FFAppState().filter.radius != 0.0)
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FFAppState().updateFilterStruct(
                                      (e) => e..radius = null,
                                    );
                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    height: 35.0,
                                    decoration: BoxDecoration(
                                      color:
                                          FlutterFlowTheme.of(context).tertiary,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              12.0, 0.0, 12.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            formatNumber(
                                              FFAppState().filter.radius,
                                              formatType: FormatType.custom,
                                              format: 'Радиус поиска 0 км',
                                              locale: '',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(8.0, 0.0, 0.0, 0.0),
                                            child: Container(
                                              width: 19.0,
                                              height: 19.0,
                                              decoration: const BoxDecoration(
                                                color: Color(0x32FFFFFF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                FFIcons.kkrestStroke,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                size: 9.0,
                                              ),
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
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 5.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (responsiveVisibility(
                              context: context,
                              phone: false,
                              tablet: false,
                              tabletLandscape: false,
                              desktop: false,
                            ))
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              8.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        'До окончания смены: ',
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
                                    FlutterFlowTimer(
                                      initialTime: functions.newCustomFunction2(
                                          currentUserDocument!
                                              .shiftStartDateTime!),
                                      getDisplayTime: (value) =>
                                          StopWatchTimer.getDisplayTime(value,
                                              milliSecond: false),
                                      controller: _model.timerController,
                                      updateStateInterval:
                                          const Duration(milliseconds: 1000),
                                      onChanged:
                                          (value, displayTime, shouldUpdate) {
                                        _model.timerMilliseconds = value;
                                        _model.timerValue = displayTime;
                                        if (shouldUpdate) safeSetState(() {});
                                      },
                                      textAlign: TextAlign.start,
                                      style: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .override(
                                            fontFamily: 'SF',
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            FFButtonWidget(
                              onPressed: () async {
                                await currentUserReference!.update({
                                  ...createUsersRecordData(
                                    onShift: false,
                                    shiftCompletionDateTime:
                                        getCurrentTimestamp,
                                  ),
                                  ...mapToFirestore(
                                    {
                                      'balance': FieldValue.increment(
                                          -(valueOrDefault(
                                              currentUserDocument
                                                  ?.currentCommision,
                                              0.0))),
                                    },
                                  ),
                                });
                                unawaited(
                                  () async {
                                    await currentUserReference!.update({
                                      ...mapToFirestore(
                                        {
                                          'current_commision':
                                              FieldValue.delete(),
                                        },
                                      ),
                                    });
                                  }(),
                                );

                                FFAppState().update(() {});
                                HapticFeedback.mediumImpact();
                                if (valueOrDefault(
                                        currentUserDocument?.balance, 0.0) <
                                    0.0) {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
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
                                            child:
                                                const ZaChtoPlataCopyWidget(),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                }
                              },
                              text: 'Завершить смену, комиссия - ${formatNumber(
                                valueOrDefault(
                                    currentUserDocument?.currentCommision, 0.0),
                                formatType: FormatType.custom,
                                format: '0',
                                locale: '',
                              )}₽',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 50.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).error,
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                      fontFamily: 'SF',
                                      color: Colors.white,
                                      letterSpacing: 0.0,
                                    ),
                                elevation: 0.0,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
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
                            children: [
                              StreamBuilder<List<OrderRecord>>(
                                stream: queryOrderRecord(
                                  queryBuilder: (orderRecord) => orderRecord
                                      .where(
                                        'status',
                                        isEqualTo:
                                            StatusOrder.newOrder.serialize(),
                                      )
                                      .where(
                                        'user_customer',
                                        isNotEqualTo: currentUserReference,
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  List<OrderRecord> containerOrderRecordList =
                                      snapshot.data!;

                                  return Container(
                                    decoration: const BoxDecoration(),
                                    child: Builder(
                                      builder: (context) {
                                        final orders = functions
                                            .filterOrders(
                                                FFAppState().filter.ott != 0
                                                    ? FFAppState().filter.ott
                                                    : null,
                                                FFAppState().filter.doo != 0
                                                    ? FFAppState().filter.doo
                                                    : null,
                                                FFAppState().filter.supply != 0
                                                    ? FFAppState().filter.supply
                                                    : null,
                                                FFAppState().filter.radius !=
                                                        0.0
                                                    ? FFAppState().filter.radius
                                                    : null,
                                                containerOrderRecordList
                                                    .toList(),
                                                currentUserLocationValue,
                                                currentUserDocument
                                                    ?.car?.mark?.name)
                                            .toList();
                                        if (orders.isEmpty) {
                                          return const SizedBox(
                                            height: 700.0,
                                            child: NetPoiskaWidget(),
                                          );
                                        }

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: orders.length,
                                          itemBuilder: (context, ordersIndex) {
                                            final ordersItem =
                                                orders[ordersIndex];
                                            return OrderCardDriverWidget(
                                              key: Key(
                                                  'Keydjd_${ordersIndex}_of_${orders.length}'),
                                              order: ordersItem,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 5.0, 0.0, 0.0),
                    child: wrapWithModel(
                      model: _model.navbarModel1,
                      updateCallback: () => safeSetState(() {}),
                      child: const NavbarWidget(
                        index: 3,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Builder(
                          builder: (context) {
                            if (valueOrDefault<bool>(
                                currentUserDocument?.verifCompl, false)) {
                              return Container(
                                width: double.infinity,
                                height: 196.87,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/freepik--Character--inject-2.png',
                                          width: 200.0,
                                          height: 161.0,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: Text(
                                          'Начните смену, \nчтобы видеть заказы',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'SF',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 20.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 24.0, 0.0, 0.0),
                                        child: FFButtonWidget(
                                          onPressed: () async {
                                            if (valueOrDefault(
                                                    currentUserDocument
                                                        ?.balance,
                                                    0.0) >=
                                                0.0) {
                                              if (await getPermissionStatus(
                                                  locationPermission)) {
                                                unawaited(
                                                  () async {
                                                    await currentUserReference!
                                                        .update(
                                                            createUsersRecordData(
                                                      onShift: true,
                                                      shiftStartDateTime:
                                                          getCurrentTimestamp,
                                                    ));
                                                  }(),
                                                );

                                                FFAppState().update(() {});
                                                HapticFeedback.mediumImpact();
                                              } else {
                                                await showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  context: context,
                                                  builder: (context) {
                                                    return WebViewAware(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                        },
                                                        child: Padding(
                                                          padding: MediaQuery
                                                              .viewInsetsOf(
                                                                  context),
                                                          child:
                                                              const VklGeoCopyWidget(),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              }
                                            } else {
                                              await showModalBottomSheet(
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (context) {
                                                  return WebViewAware(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child:
                                                            const ZaChtoPlataCopyWidget(),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).then((value) =>
                                                  safeSetState(() {}));

                                              return;
                                            }
                                          },
                                          text: 'Начать смену',
                                          options: FFButtonOptions(
                                            width: double.infinity,
                                            height: 48.3,
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(16.0, 0.0, 16.0, 0.0),
                                            iconPadding:
                                                const EdgeInsetsDirectional
                                                    .fromSTEB(
                                                    0.0, 0.0, 0.0, 0.0),
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                            textStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .override(
                                                      fontFamily: 'SF',
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                    ),
                                            elevation: 0.0,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (valueOrDefault<bool>(
                                          currentUserDocument?.onVerifNow,
                                          false) &&
                                      !valueOrDefault<bool>(
                                          currentUserDocument?.verifNeProidena,
                                          false))
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 5.0),
                                      child: AuthUserStreamWidget(
                                        builder: (context) => Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Icon(
                                                      FFIcons.kalertHexagon,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      size: 20.0,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(6.0,
                                                              0.0, 0.0, 0.0),
                                                      child: Text(
                                                        'Аккаунт на модерации!',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily: 'SF',
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .error,
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              lineHeight: 1.0,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          0.0, 5.0, 0.0, 0.0),
                                                  child: Text(
                                                    'Мы проверим ваш аккаунт в течении 24 часов, \nи откроем вам доступ ко всему приложению.',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          color: const Color(
                                                              0xFF4B4B4B),
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (valueOrDefault<bool>(
                                      currentUserDocument?.verifNeProidena,
                                      false))
                                    AuthUserStreamWidget(
                                      builder: (context) => Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Icon(
                                                    FFIcons.kalertHexagon,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .error,
                                                    size: 20.0,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            6.0, 0.0, 0.0, 0.0),
                                                    child: Text(
                                                      'Верификация не пройдена!',
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'SF',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .error,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            lineHeight: 1.0,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 5.0, 0.0, 0.0),
                                                child: Text(
                                                  'Администратор отклонил вашу заявку на верификацию № ${valueOrDefault(currentUserDocument?.verifId, 0).toString()},свяжитесь с поддержкой для получения доп инфы ',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color: const Color(
                                                            0xFF4B4B4B),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 12.0, 0.0, 0.0),
                                                child: FFButtonWidget(
                                                  onPressed: () async {
                                                    context.pushNamed(
                                                      ChatWidget.routeName,
                                                      queryParameters: {
                                                        'chat': serializeParam(
                                                          currentUserDocument
                                                              ?.chatWithSupport,
                                                          ParamType
                                                              .DocumentReference,
                                                        ),
                                                        'name': serializeParam(
                                                          'Поддержка',
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  },
                                                  text: 'Чат с поддержкой',
                                                  options: FFButtonOptions(
                                                    width: double.infinity,
                                                    height: 45.0,
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                    iconPadding:
                                                        const EdgeInsetsDirectional
                                                            .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primaryBackground,
                                                    textStyle: FlutterFlowTheme
                                                            .of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily: 'SF',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .tertiary,
                                                          fontSize: 15.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                    elevation: 0.0,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  showLoadingIndicator: false,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 5.0, 0.0, 0.0),
                    child: wrapWithModel(
                      model: _model.navbarModel2,
                      updateCallback: () => safeSetState(() {}),
                      child: const NavbarWidget(
                        index: 3,
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
