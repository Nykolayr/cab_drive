import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/file_storage_service.dart';
import '/backend/api/order_record_mapper.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/customer/net_zakazov_klient/net_zakazov_klient_widget.dart';
import '/customer/order_card_customer/order_card_customer_widget.dart';
import '/driver/net_zakazov_vodila/net_zakazov_vodila_widget.dart';
import '/driver/order_card_driver/order_card_driver_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import 'dart:async';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'my_orders_model.dart';
export 'my_orders_model.dart';

class MyOrdersWidget extends StatefulWidget {
  const MyOrdersWidget({super.key});

  static String routeName = 'My_Orders';
  static String routePath = '/myOrders';

  @override
  State<MyOrdersWidget> createState() => _MyOrdersWidgetState();
}

class _MyOrdersWidgetState extends State<MyOrdersWidget> {
  late MyOrdersModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _showPriceBanner = false;
  Timer? _priceBannerTimer;
  String? _resolvedLocation;
  bool _isResolvingLocation = false;
  bool _userDocCoordsTried = false;
  bool _gpsTried = false;

  Timer? _minePoll;
  List<OrderRecord>? _mineOrders;
  bool _mineFsFallback = false;
  bool? _lastDriverRole;

  void _onPriceCommitted() {
    _priceBannerTimer?.cancel();
    setState(() => _showPriceBanner = true);
    _priceBannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showPriceBanner = false);
    });
    unawaited(_reloadMineOrders());
  }

  Future<void> _reloadMineOrders() async {
    final role = FFAppState().driver ? 'driver' : 'customer';
    try {
      final maps = await AppMeApi.ordersMine(role: role, limit: 100);
      final out = <OrderRecord>[];
      for (final m in maps) {
        final id = m['id']?.toString();
        if (id == null || id.isEmpty) continue;
        try {
          out.add(OrderRecordMapper.fromApi(m, id));
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _mineOrders = out;
        _mineFsFallback = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('[my_orders] API fail (no FS fallback): $e');
      if (!mounted) return;
      setState(() {
        _mineOrders = const [];
        _mineFsFallback = false;
      });
    }
  }

  Stream<List<OrderRecord>> _mineStream(Stream<List<OrderRecord>> fs) {
    return Stream<List<OrderRecord>>.value(_mineOrders ?? const []);
  }

  Widget _mineLoadingBox(BuildContext context) {
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

  Widget _greetingHeader(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final name = (currentUserDisplayName ?? '').isNotEmpty
        ? currentUserDisplayName
        : 'друг';
    final photo = currentUserDocument?.photoUrl ?? '';
    final city = currentUserDocument?.city ?? '';
    final region = currentUserDocument?.region ?? '';
    final location = city.isNotEmpty
        ? city
        : (region.isNotEmpty
            ? region
            : (_resolvedLocation ?? '…'));
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsetsDirectional.fromSTEB(16.0, 48.0, 16.0, 4.0),
      color: theme.primaryBackground,
      child: Row(
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

  Widget _priceChangedBanner(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        border: Border.all(color: theme.tertiary),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        children: [
          Container(
            width: 22.0,
            height: 22.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.tertiary, width: 1.6),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check, size: 14.0, color: theme.tertiary),
          ),
          const SizedBox(width: 10.0),
          Text(
            'Цена изменена',
            style: theme.bodyMedium.override(
              fontFamily: 'SF',
              color: theme.tertiary,
              fontSize: 16.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyOrdersModel());
    unawaited(_reloadMineOrders());
    _minePoll =
        Timer.periodic(const Duration(seconds: 5), (_) => _reloadMineOrders());
  }

  void _kickoffLocationResolve() {
    if (_resolvedLocation != null || _isResolvingLocation) return;
    final city = currentUserDocument?.city ?? '';
    final region = currentUserDocument?.region ?? '';
    if (city.isNotEmpty || region.isNotEmpty) return;

    final docCoords = currentUserDocument?.cityLatlng;
    if (docCoords != null && !_userDocCoordsTried) {
      _userDocCoordsTried = true;
      _resolveFromCoords(docCoords.latitude, docCoords.longitude);
      return;
    }
    if (!_gpsTried) {
      _gpsTried = true;
      _resolveFromGps();
    }
  }

  Future<void> _resolveFromGps() async {
    _isResolvingLocation = true;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      );
      await _resolveFromCoords(pos.latitude, pos.longitude);
    } catch (_) {
    } finally {
      _isResolvingLocation = false;
    }
  }

  Future<void> _resolveFromCoords(double lat, double lng) async {
    _isResolvingLocation = true;
    try {
      final response =
          await GeocodeLatLngCall.call(latlng: '$lat,$lng');
      if (!mounted || !response.succeeded) return;
      final body = response.jsonBody;
      final loc = GeocodeLatLngCall.city(body) ??
          GeocodeLatLngCall.areal2(body) ??
          GeocodeLatLngCall.areal(body);
      if (loc != null && loc.isNotEmpty) {
        setState(() => _resolvedLocation = loc);
      }
    } catch (_) {
    } finally {
      _isResolvingLocation = false;
    }
  }

  @override
  void dispose() {
    _minePoll?.cancel();
    _priceBannerTimer?.cancel();
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final driverNow = FFAppState().driver;
    if (_lastDriverRole != driverNow) {
      _lastDriverRole = driverNow;
      unawaited(_reloadMineOrders());
    }
    _kickoffLocationResolve();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _greetingHeader(context),
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Builder(
                    builder: (context) {
                      if (!FFAppState().driver) {
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_showPriceBanner)
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.fromSTEB(
                                        16.0, 8.0, 16.0, 16.0),
                                child: _priceChangedBanner(context),
                              ),
                            if (!_showPriceBanner)
                              Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 8.0, 0.0, 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (_model.index == 1) {
                                          return;
                                        }

                                        _model.index = 1;
                                        safeSetState(() {});
                                        HapticFeedback.mediumImpact();
                                        return;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: valueOrDefault<Color>(
                                            _model.index == 1
                                                ? FlutterFlowTheme.of(context)
                                                    .tertiary
                                                : FlutterFlowTheme.of(context)
                                                    .primary,
                                            FlutterFlowTheme.of(context)
                                                .tertiary,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  18.0, 9.0, 18.0, 9.0),
                                          child: Text(
                                            'Активные',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: valueOrDefault<Color>(
                                                    _model.index == 1
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .secondary
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                  ),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (_model.index == 2) {
                                          return;
                                        }

                                        _model.index = 2;
                                        safeSetState(() {});
                                        HapticFeedback.mediumImpact();
                                        return;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: valueOrDefault<Color>(
                                            _model.index == 2
                                                ? FlutterFlowTheme.of(context)
                                                    .tertiary
                                                : FlutterFlowTheme.of(context)
                                                    .primary,
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  18.0, 9.0, 18.0, 9.0),
                                          child: Text(
                                            'Архив',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: valueOrDefault<Color>(
                                                    _model.index == 2
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .secondary
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                  ),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: StreamBuilder<List<OrderRecord>>(
                                stream: _mineStream(
                                  queryOrderRecord(
                                    queryBuilder: (orderRecord) => orderRecord
                                        .where(
                                          'user_customer',
                                          isEqualTo: currentUserReference,
                                        )
                                        .orderBy('date_upd', descending: true),
                                  ),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return _mineLoadingBox(context);
                                  }
                                  List<OrderRecord> containerOrderRecordList =
                                      snapshot.data!;

                                  print(containerOrderRecordList.map((e) => e.images).toList());
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(18.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          final containerVar = containerOrderRecordList
                                              .where((e) => _model.index == 1
                                                  ? ((e.status == StatusOrder.newOrder) ||
                                              (e.status == StatusOrder.place_delivery) ||
                                              (e.status == StatusOrder.place_pickup) ||
                                                      (e.status ==
                                                          StatusOrder
                                                              .spec_set) ||
                                                      (e.status ==
                                                          StatusOrder
                                                              .at_work) ||
                                                      (e.status ==
                                                          StatusOrder
                                                              .on_confirmation) ||
                                                      (e.status ==
                                                          StatusOrder
                                                              .completed))

                                                  : ((e.status ==
                                                          StatusOrder.hidden) ||
                                                      (e.status ==
                                                          StatusOrder
                                                              .cancelled)))
                                              .toList();
                                          if (containerVar.isEmpty) {
                                            return Container(
                                              height: double.infinity,
                                              child: NetZakazovKlientWidget(),
                                            );
                                          }

                                          return ListView.separated(
                                            padding: EdgeInsets.zero,
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: containerVar.length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 5.0),
                                            itemBuilder:
                                                (context, containerVarIndex) {
                                              final containerVarItem =
                                                  containerVar[
                                                      containerVarIndex];
                                              return InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  context.pushNamed(
                                                    OrderPageCustomerWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'index': serializeParam(
                                                        2,
                                                        ParamType.int,
                                                      ),
                                                      'order': serializeParam(
                                                        containerVarItem
                                                            .reference,
                                                        ParamType
                                                            .DocumentReference,
                                                      ),
                                                    }.withoutNulls,
                                                  );
                                                },
                                                child: OrderCardCustomerWidget(
                                                  key: Key(
                                                      'Keyf97_${containerVarIndex}_of_${containerVar.length}'),
                                                  order: containerVarItem,
                                                  onPriceCommitted:
                                                      _onPriceCommitted,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ].divide(SizedBox(height: 5.0)),
                        );
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 8.0, 0.0, 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (_model.index == 1) {
                                          return;
                                        }

                                        _model.index = 1;
                                        safeSetState(() {});
                                        HapticFeedback.mediumImpact();
                                        return;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: valueOrDefault<Color>(
                                            _model.index == 1
                                                ? FlutterFlowTheme.of(context)
                                                    .tertiary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            FlutterFlowTheme.of(context)
                                                .tertiary,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  18.0, 9.0, 18.0, 9.0),
                                          child: Text(
                                            'Активные',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: valueOrDefault<Color>(
                                                    _model.index == 1
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .secondary
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                  ),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (_model.index == 2) {
                                          return;
                                        }

                                        _model.index = 2;
                                        safeSetState(() {});
                                        HapticFeedback.mediumImpact();
                                        return;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: valueOrDefault<Color>(
                                            _model.index == 2
                                                ? FlutterFlowTheme.of(context)
                                                    .tertiary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  18.0, 9.0, 18.0, 9.0),
                                          child: Text(
                                            'Отклики',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: valueOrDefault<Color>(
                                                    _model.index == 2
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .secondary
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                  ),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        if (_model.index == 3) {
                                          return;
                                        }

                                        _model.index = 3;
                                        safeSetState(() {});
                                        HapticFeedback.mediumImpact();
                                        return;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: valueOrDefault<Color>(
                                            _model.index == 3
                                                ? FlutterFlowTheme.of(context)
                                                    .tertiary
                                                : FlutterFlowTheme.of(context)
                                                    .secondaryBackground,
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  18.0, 9.0, 18.0, 9.0),
                                          child: Text(
                                            'Архив',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  color: valueOrDefault<Color>(
                                                    _model.index == 3
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .secondary
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .primaryText,
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                  ),
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ].divide(SizedBox(width: 8.0)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: StreamBuilder<List<OrderRecord>>(
                                stream: _mineStream(
                                  queryOrderRecord(
                                    queryBuilder: (orderRecord) => orderRecord
                                        .where(Filter.or(
                                          Filter(
                                            'selected_driver',
                                            isEqualTo: currentUserReference,
                                          ),
                                          Filter(
                                            'user_who_responced',
                                            arrayContains: currentUserReference,
                                          ),
                                        ))
                                        .orderBy('date_upd', descending: true),
                                  ),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return _mineLoadingBox(context);
                                  }
                                  List<OrderRecord> containerOrderRecordList =
                                      snapshot.data!;

                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(18.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          final pol = containerOrderRecordList
                                              .where((e) => () {
                                                    if (_model.index == 1) {
                                                      return ((e.status == StatusOrder.place_delivery) ||
                                                          (e.status == StatusOrder.place_pickup) ||(e.status ==
                                                              StatusOrder
                                                                  .spec_set) ||
                                                          (e.status ==
                                                              StatusOrder
                                                                  .at_work));
                                                    } else if (_model.index ==
                                                        2) {
                                                      return (e.status ==
                                                          StatusOrder.newOrder);
                                                    } else {
                                                      return (e.status ==
                                                          StatusOrder
                                                              .completed);
                                                    }
                                                  }())
                                              .toList();
                                          if (pol.isEmpty) {
                                            return Container(
                                              height: double.infinity,
                                              child: NetZakazovVodilaWidget(),
                                            );
                                          }

                                          return ListView.separated(
                                            padding: EdgeInsets.zero,
                                            primary: false,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemCount: pol.length,
                                            separatorBuilder: (_, __) =>
                                                SizedBox(height: 5.0),
                                            itemBuilder: (context, polIndex) {
                                              final polItem = pol[polIndex];
                                              return OrderCardDriverWidget(
                                                key: Key(
                                                    'Keygqd_${polIndex}_of_${pol.length}'),
                                                order: polItem,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ].divide(SizedBox(height: 5.0)),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            wrapWithModel(
              model: _model.navbarModel,
              updateCallback: () => safeSetState(() {}),
              child: NavbarWidget(
                index: 2,
              ),
            ),
          ].divide(SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
