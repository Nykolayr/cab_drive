import 'package:firebase_auth/firebase_auth.dart';

import '../../custom_code/actions/toggle_route_tracking.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/file_storage_service.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/driver/filters/filters_widget.dart';
import '/driver/net_poiska/net_poiska_widget.dart';
import '/driver/order_card_driver/order_card_driver_widget.dart';
import '/driver/services/extra_orders_listener.dart';
import '/driver/vkl_geo_copy/vkl_geo_copy_widget.dart';
import '/driver/za_chto_plata_copy/za_chto_plata_copy_widget.dart';
import '/flutter_flow/nav/nav.dart' show appNavigatorKey;
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
import 'package:google_fonts/google_fonts.dart';
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
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainDriverModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {

      if(valueOrDefault(currentUserDocument?.onShift, false)) {
        toggleDriverPosTracking();
      }

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
                  child: ErrorPopupWidget(
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


      await currentUserReference!.update(createUsersRecordData(
        fbId: FirebaseAuth.instance.currentUser!.uid,
      ));
    });

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));

    // Запуск/перезапуск резервного Firestore-листенера доп.заказов «по пути».
    _activeOrderSub = queryOrderRecord(
      queryBuilder: (q) => q
          .where('selected_driver', isEqualTo: currentUserReference)
          .where('status', whereIn: [
        StatusOrder.spec_set.serialize(),
        StatusOrder.place_pickup.serialize(),
        StatusOrder.at_work.serialize(),
      ]),
      limit: 1,
    ).listen(_syncExtraOrdersListener);
  }

  StreamSubscription<List<OrderRecord>>? _activeOrderSub;

  void _syncExtraOrdersListener(List<OrderRecord> active) {
    if (active.isEmpty) {
      ExtraOrdersListener.instance.stop();
      return;
    }
    final order = active.first;
    final uid = currentUserUid;
    final mark = currentUserDocument?.car?.mark?.name;
    ExtraOrdersListener.instance.start(
      activeOrderId: order.reference.id,
      driverUid: uid,
      driverMark: mark,
      driverLocation: currentUserLocationValue,
      navigatorKey: appNavigatorKey,
    );
    ExtraOrdersListener.instance.updateDriverLocation(currentUserLocationValue);
  }

  @override
  void dispose() {
    _activeOrderSub?.cancel();
    ExtraOrdersListener.instance.stop();
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
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 5.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryBackground,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DriverGreetingHeader(),
                          Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 8.0, 8.0, 8.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            direction: Axis.horizontal,
                            runAlignment: WrapAlignment.start,
                            verticalDirection: VerticalDirection.down,
                            clipBehavior: Clip.none,
                            children: [
                              _DriverFilterChip(
                                label: FFAppState().filter.radius != 0.0
                                    ? formatNumber(
                                        FFAppState().filter.radius,
                                        formatType: FormatType.custom,
                                        format: 'Радиус 0 км',
                                        locale: '',
                                      )
                                    : 'Радиус поиска',
                                isActive:
                                    FFAppState().filter.radius != 0.0,
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
                                            child: FiltersWidget(
                                                focus: 'radius'),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                onClear: () {
                                  FFAppState().updateFilterStruct(
                                    (e) => e..radius = null,
                                  );
                                  safeSetState(() {});
                                },
                              ),
                              _DriverFilterChip(
                                label: () {
                                  final ott = FFAppState().filter.ott;
                                  final doo = FFAppState().filter.doo;
                                  if (ott != 0 && doo != 0) {
                                    return '$ott–$doo ₽';
                                  } else if (ott != 0) {
                                    return 'От $ott ₽';
                                  } else if (doo != 0) {
                                    return 'До $doo ₽';
                                  }
                                  return 'Ставка';
                                }(),
                                isActive: FFAppState().filter.ott != 0 ||
                                    FFAppState().filter.doo != 0,
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
                                            child:
                                                FiltersWidget(focus: 'rate'),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                onClear: () {
                                  FFAppState().updateFilterStruct(
                                    (e) => e
                                      ..ott = null
                                      ..doo = null,
                                  );
                                  safeSetState(() {});
                                },
                              ),
                              _DriverFilterChip(
                                label: FFAppState().filter.supply == 1
                                    ? 'В ближайшее время'
                                    : FFAppState().filter.supply == 2
                                        ? 'Ко времени'
                                        : 'Подача',
                                isActive:
                                    FFAppState().filter.supply != 0,
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
                                            child: FiltersWidget(
                                                focus: 'supply'),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                onClear: () {
                                  FFAppState().updateFilterStruct(
                                    (e) => e..supply = null,
                                  );
                                  safeSetState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 5.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
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
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
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
                                          Duration(milliseconds: 1000),
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
                                final commission = valueOrDefault(
                                    currentUserDocument?.currentCommision,
                                    0.0);
                                final bonus = valueOrDefault(
                                    currentUserDocument?.bonusBalance, 0.0);
                                final fromBonus =
                                    commission <= bonus ? commission : bonus;
                                final fromMain = commission - fromBonus;
                                print(
                                    '[main_driver.endShift] commission=$commission bonus=$bonus fromBonus=$fromBonus fromMain=$fromMain');
                                final mainBalanceAfter = valueOrDefault(
                                        currentUserDocument?.balance, 0.0) -
                                    fromMain;
                                if (fromMain > 0 && mainBalanceAfter < 0) {
                                  print(
                                      '[main_driver.endShift] WARN: balance going negative after shift end → $mainBalanceAfter');
                                }

                                final shiftWriteOff = <String, dynamic>{};
                                if (fromBonus > 0) {
                                  shiftWriteOff['bonus_balance'] =
                                      FieldValue.increment(-fromBonus);
                                }
                                if (fromMain > 0) {
                                  shiftWriteOff['balance'] =
                                      FieldValue.increment(-fromMain);
                                }

                                await currentUserReference!.update({
                                  ...createUsersRecordData(
                                    onShift: false,
                                    shiftCompletionDateTime:
                                        getCurrentTimestamp,
                                  ),
                                  ...mapToFirestore(shiftWriteOff),
                                });

                                createPayOrderRecordData(

                                  isPaid: false,
                                  amountInCop: (valueOrDefault(
                                      currentUserDocument
                                          ?.currentCommision,
                                      0.0)).toInt(),
                                  user: currentUserReference,
                                  paymentType: PaymentType.finishedMyShift,
                                );
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
                                            child: ZaChtoPlataCopyWidget(),
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
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
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
                                    decoration: BoxDecoration(),
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
                                          return Container(
                                            height: 700.0,
                                            child: NetPoiskaWidget(),
                                          );
                                        }

                                        final canGetNew = orders.where((e) => e.userWhoResponced.contains(currentUserReference) &&
                                            (e.status == StatusOrder.newOrder) || e.selectedDriver == currentUserReference).isEmpty;
                                        final hasUnrespondedOrders = orders.any(
                                          (e) =>
                                              !e.userWhoResponced.contains(
                                                  currentUserReference) &&
                                              e.selectedDriver !=
                                                  currentUserReference,
                                        );
                                        final showExtraOrderBanner =
                                            !canGetNew &&
                                                hasUnrespondedOrders;
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (showExtraOrderBanner)
                                              const _ExtraOrderBanner(),
                                            ListView.builder(
                                              padding: EdgeInsets.zero,
                                              primary: false,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              itemCount: orders.length,
                                              itemBuilder:
                                                  (context, ordersIndex) {
                                                final ordersItem =
                                                    orders[ordersIndex];
                                                return OrderCardDriverWidget(
                                                  canGetNew: canGetNew,
                                                  key: Key(
                                                      'Keydjd_${ordersIndex}_of_${orders.length}'),
                                                  order: ordersItem,
                                                );
                                              },
                                            ),
                                          ],
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
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                    child: wrapWithModel(
                      model: _model.navbarModel1,
                      updateCallback: () => safeSetState(() {}),
                      child: NavbarWidget(
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
                            if (!valueOrDefault<bool>(
                                currentUserDocument?.onVerifNow, false)) {
                              return Container(
                                width: double.infinity,
                                height: 196.87,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
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
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 12.0, 0.0, 0.0),
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
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 24.0, 0.0, 0.0),
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

                                                toggleDriverPosTracking();
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
                                                              VklGeoCopyWidget(),
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
                                                            ZaChtoPlataCopyWidget(),
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
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    16.0, 0.0, 16.0, 0.0),
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
                                  if (!valueOrDefault<bool>(
                                          currentUserDocument?.verifNeProidena,
                                          false))
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
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
                                            padding: EdgeInsets.all(16.0),
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
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  6.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
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
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 5.0, 0.0, 0.0),
                                                  child: Text(
                                                    'Мы проверим ваш аккаунт в течении 24 часов, \nи откроем вам доступ ко всему приложению.',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          color:
                                                              Color(0xFF4B4B4B),
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
                                      currentUserDocument?.isBlocked,
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
                                          padding: EdgeInsets.all(16.0),
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
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(6.0, 0.0,
                                                        0.0, 0.0),
                                                    child: Text(
                                                      'Вы заблокированы',
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                    0.0, 5.0, 0.0, 0.0),
                                                child: Text(
                                                  'Свяжитесь с поддержкой для получения доп инфы ',
                                                  style: FlutterFlowTheme.of(
                                                      context)
                                                      .bodyMedium
                                                      .override(
                                                    fontFamily: 'SF',
                                                    color:
                                                    Color(0xFF4B4B4B),
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                    FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                    0.0, 12.0, 0.0, 0.0),
                                                child: FFButtonWidget(
                                                  onPressed: () async {


                                                    var chatsRecordReference =
                                                    ChatsRecord.collection
                                                        .doc();
                                                    if (currentUserDocument
                                                        ?.chatWithSupport ==
                                                        null) {
                                                      currentUserDocument!.chatWithSupport =
                                                          ChatsRecord
                                                              .getDocumentFromData({
                                                            ...createChatsRecordData(
                                                              dateCreated:
                                                              getCurrentTimestamp,
                                                              support: true,
                                                            ),
                                                            ...mapToFirestore(
                                                              {
                                                                'users':
                                                                functions.listusers(
                                                                    currentUserReference!),
                                                              },
                                                            ),
                                                          }, chatsRecordReference).reference;
                                                    }


                                                    return;
                                                  },
                                                  text: 'Чат с поддержкой',
                                                  options: FFButtonOptions(
                                                    width: double.infinity,
                                                    height: 45.0,
                                                    padding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(0.0, 0.0,
                                                        0.0, 0.0),
                                                    iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(0.0, 0.0,
                                                        0.0, 0.0),
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
                                    ) else
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
                                          padding: EdgeInsets.all(16.0),
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
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(6.0, 0.0,
                                                                0.0, 0.0),
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
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 5.0, 0.0, 0.0),
                                                child: Text(
                                                  'Администратор отклонил вашу заявку на верификацию № ${valueOrDefault(currentUserDocument?.verifId, 0).toString()},свяжитесь с поддержкой для получения доп инфы ',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            Color(0xFF4B4B4B),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
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
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
                                                    iconPadding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                0.0, 0.0),
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
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 0.0),
                    child: wrapWithModel(
                      model: _model.navbarModel2,
                      updateCallback: () => safeSetState(() {}),
                      child: NavbarWidget(
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

class _DriverGreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final name = (currentUserDisplayName ?? '').isNotEmpty
        ? currentUserDisplayName
        : 'друг';
    final photo = currentUserDocument?.photoUrl ?? '';
    final city = currentUserDocument?.city ?? '';
    final region = currentUserDocument?.region ?? '';
    final location =
        city.isNotEmpty ? city : (region.isNotEmpty ? region : '…');
    return Padding(
      padding:
          const EdgeInsetsDirectional.fromSTEB(16.0, 48.0, 16.0, 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16.0, color: theme.secondaryText),
                    const SizedBox(width: 4.0),
                    Text(
                      location,
                      style: theme.bodyMedium.override(
                        fontFamily: 'SF',
                        color: theme.secondaryText,
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Добрый день, $name',
                  style: theme.bodyMedium.override(
                    fontFamily: 'SF',
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44.0,
            height: 44.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF4F5F8),
            ),
            child: ClipOval(
              child: photo.isNotEmpty
                  ? Image.network(
                      FileStorageService.getImageUrl(photo),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.person, color: theme.secondaryText),
                    )
                  : Icon(Icons.person, color: theme.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverFilterChip extends StatelessWidget {
  const _DriverFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 35.0,
        decoration: BoxDecoration(
          color: isActive ? theme.tertiary : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.bodyMedium.override(
                fontFamily: 'SF',
                color: isActive ? theme.secondary : theme.primaryText,
                fontSize: 14.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isActive)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                child: GestureDetector(
                  onTap: onClear,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 19.0,
                    height: 19.0,
                    decoration: BoxDecoration(
                      color: Color(0x32FFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FFIcons.kkrestStroke,
                      color: theme.secondary,
                      size: 9.0,
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

class _ExtraOrderBanner extends StatelessWidget {
  const _ExtraOrderBanner();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          border: Border.all(color: theme.tertiary, width: 1.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: EdgeInsets.all(12.0),
        alignment: Alignment.center,
        child: Text(
          'Можете взять дополнительный заказ',
          textAlign: TextAlign.center,
          style: theme.bodyMedium.override(
            fontFamily: 'SF',
            color: theme.tertiary,
            fontSize: 16.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
