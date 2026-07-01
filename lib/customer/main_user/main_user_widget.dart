import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/customer/create_order/searh_address/searh_address_widget.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/main_load/main_load_widget.dart';
import '/pages/bottom/navbar/navbar_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'main_user_model.dart';
export 'main_user_model.dart';

class MainUserWidget extends StatefulWidget {
  const MainUserWidget({super.key});

  static String routeName = 'MAIN_USER';
  static String routePath = '/mainUser';

  @override
  State<MainUserWidget> createState() => _MainUserWidgetState();
}

class _MainUserWidgetState extends State<MainUserWidget> {
  late MainUserModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainUserModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      currentUserLocationValue =
          await getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0));
      if (await getPermissionStatus(locationPermission)) {
        await _model.googleMapsController.future.then(
          (c) => c.animateCamera(
            CameraUpdate.newLatLng(currentUserLocationValue!.toGoogleMaps()),
          ),
        );
      }
    });
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
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  if (valueOrDefault<bool>(
                    FFAppState().pointB.latlng != null,
                    false,
                  )) {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18.0),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height: double.infinity,
                                    child: custom_widgets.PolylineMap(
                                      width: MediaQuery.sizeOf(context).width *
                                          1.0,
                                      height: double.infinity,
                                      googleApiKey:
                                          'AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
                                      startLatLng: FFAppState().pointA.latlng!,
                                      endLatLng: FFAppState().pointB.latlng!,
                                      isStatic: false,
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(-1.0, 1.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 0.0, 16.0),
                                  child: FlutterFlowIconButton(
                                    borderColor: Colors.transparent,
                                    borderRadius: 88.0,
                                    buttonSize: 48.0,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    icon: Icon(
                                      FFIcons.kiconStroke,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 12.0,
                                    ),
                                    onPressed: () async {
                                      FFAppState().pointB = PointStruct();
                                      FFAppState().pointA = PointStruct();
                                      FFAppState().update(() {});
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(18.0),
                          ),
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
                                            child: SearhAddressWidget(
                                              index: 1,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                child: Container(
                                  height: 60.0,
                                  decoration: BoxDecoration(),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 16.0,
                                          height: 16.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Color(0xFFA4A6B2),
                                              width: 3.0,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    13.0, 0.0, 0.0, 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Text(
                                                      valueOrDefault<String>(
                                                        FFAppState()
                                                            .pointA
                                                            .address,
                                                        'Откуда забрать',
                                                      ).maybeHandleOverflow(
                                                        maxChars: 35,
                                                        replacement: '…',
                                                      ),
                                                      maxLines: 1,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'SF',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryText,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  height: 0.3,
                                                  thickness: 0.3,
                                                  color: Color(0xFFD0CFCE),
                                                ),
                                              ].divide(SizedBox(height: 18.0)),
                                            ),
                                          ),
                                        ),
                                      ],
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
                                            child: SearhAddressWidget(
                                              index: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));
                                },
                                child: Container(
                                  height: 60.0,
                                  decoration: BoxDecoration(),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 16.0,
                                          height: 16.0,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Color(0xFFA4A6B2),
                                              width: 3.0,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    13.0, 0.0, 0.0, 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        valueOrDefault<String>(
                                                          FFAppState()
                                                              .pointB
                                                              .address,
                                                          'Куда доставить',
                                                        ).maybeHandleOverflow(
                                                          maxChars: 35,
                                                          replacement: '…',
                                                        ),
                                                        maxLines: 1,
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily: 'SF',
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              fontSize: 16.0,
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                      ),
                                                    ),
                                                    if (FFAppState()
                                                                .distanceTime !=
                                                            null &&
                                                        FFAppState()
                                                                .distanceTime !=
                                                            '')
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    6.0,
                                                                    0.0,
                                                                    6.0,
                                                                    0.0),
                                                        child: Container(
                                                          width: 5.0,
                                                          height: 5.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),
                                                    Text(
                                                      FFAppState().distanceTime,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'SF',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  height: 0.3,
                                                  thickness: 0.3,
                                                  color: Color(0xFFD0CFCE),
                                                ),
                                              ].divide(SizedBox(height: 18.0)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 8.0),
                                child: Container(
                                  height: 100.0,
                                  decoration: BoxDecoration(),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.car = Car.largus;
                                            safeSetState(() {});
                                            HapticFeedback.mediumImpact();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: valueOrDefault<Color>(
                                                _model.car == Car.largus
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .tertiary
                                                    : Colors.transparent,
                                                FlutterFlowTheme.of(context)
                                                    .tertiary,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(8.0, 0.0, 8.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                    child: Image.asset(
                                                      'assets/images/1200x900_1.png',
                                                      width: 96.9,
                                                      height: 38.1,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(6.0, 12.0,
                                                                0.0, 0.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Мини/S',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'SF',
                                                                color:
                                                                    valueOrDefault<
                                                                        Color>(
                                                                  _model.car ==
                                                                          Car
                                                                              .largus
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                ),
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                        RichText(
                                                          textScaler:
                                                              MediaQuery.of(
                                                                      context)
                                                                  .textScaler,
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'от ',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: FFAppState()
                                                                    .priceLargus
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: ' ₽',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              )
                                                            ],
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color:
                                                                      valueOrDefault<
                                                                          Color>(
                                                                    _model.car ==
                                                                            Car
                                                                                .largus
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondary
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                  ),
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
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
                                            _model.car = Car.fiat;
                                            safeSetState(() {});
                                            HapticFeedback.mediumImpact();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: valueOrDefault<Color>(
                                                _model.car == Car.fiat
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .tertiary
                                                    : Colors.transparent,
                                                Colors.transparent,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(8.0, 0.0, 8.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                    child: Image.asset(
                                                      'assets/images/fiat_16doblopackcv2fbc_sideview_1.png',
                                                      width: 92.53,
                                                      height: 39.2,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(6.0, 12.0,
                                                                0.0, 0.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'МиниПлюс/M',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'SF',
                                                                color:
                                                                    valueOrDefault<
                                                                        Color>(
                                                                  _model.car ==
                                                                          Car
                                                                              .fiat
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                ),
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                        RichText(
                                                          textScaler:
                                                              MediaQuery.of(
                                                                      context)
                                                                  .textScaler,
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'от ',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: FFAppState()
                                                                    .priceFiat
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: ' ₽',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              )
                                                            ],
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color:
                                                                      valueOrDefault<
                                                                          Color>(
                                                                    _model.car ==
                                                                            Car
                                                                                .fiat
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondary
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                  ),
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
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
                                            _model.car = Car.largusTermo;
                                            safeSetState(() {});
                                            HapticFeedback.mediumImpact();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: valueOrDefault<Color>(
                                                _model.car == Car.largusTermo
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .tertiary
                                                    : Colors.transparent,
                                                Colors.transparent,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(8.0, 0.0, 8.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                    child: Image.asset(
                                                      'assets/images/ladalargus013_1.png',
                                                      width: 99.9,
                                                      height: 39.2,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(6.0, 12.0,
                                                                0.0, 0.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Термобудка/S-M',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'SF',
                                                                color:
                                                                    valueOrDefault<
                                                                        Color>(
                                                                  _model.car ==
                                                                          Car
                                                                              .largusTermo
                                                                      ? FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondary
                                                                      : FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                ),
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                        RichText(
                                                          textScaler:
                                                              MediaQuery.of(
                                                                      context)
                                                                  .textScaler,
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: 'от ',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: FFAppState()
                                                                    .priceTermo
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      15.0,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text: ' ₽',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                ),
                                                              )
                                                            ],
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color:
                                                                      valueOrDefault<
                                                                          Color>(
                                                                    _model.car ==
                                                                            Car
                                                                                .largusTermo
                                                                        ? FlutterFlowTheme.of(context)
                                                                            .secondary
                                                                        : FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryText,
                                                                  ),
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]
                                          .divide(SizedBox(width: 8.0))
                                          .addToStart(SizedBox(width: 16.0))
                                          .addToEnd(SizedBox(width: 16.0)),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    8.0, 0.0, 8.0, 8.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    context.pushNamed(
                                      DetaliySozdanieWidget.routeName,
                                      queryParameters: {
                                        'car': serializeParam(
                                          _model.car,
                                          ParamType.Enum,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  text: 'Уточнить детали',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 56.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color:
                                        FlutterFlowTheme.of(context).tertiary,
                                    textStyle: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
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
                      ].divide(SizedBox(height: 5.0)),
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18.0),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Stack(
                                children: [
                                  FlutterFlowGoogleMap(
                                    controller: _model.googleMapsController,
                                    onCameraIdle: (latLng) => safeSetState(
                                        () => _model.googleMapsCenter = latLng),
                                    initialLocation: _model.googleMapsCenter ??=
                                        FFAppState().mskGeo!,
                                    markerColor: GoogleMarkerColor.violet,
                                    mapType: MapType.normal,
                                    style: GoogleMapStyle.standard,
                                    initialZoom: 15.0,
                                    allowInteraction: true,
                                    allowZoom: true,
                                    showZoomControls: false,
                                    showLocation: true,
                                    showCompass: false,
                                    showMapToolbar: false,
                                    showTraffic: false,
                                    centerMapOnMarkerTap: false,
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: PointerInterceptor(
                                      intercepting: isWeb,
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 0.0, 40.0),
                                        child: FaIcon(
                                          FontAwesomeIcons.mapPin,
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                          size: 40.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder<ApiCallResponse>(
                          future: GeocodeLatLngCall.call(
                            latlng: functions
                                .formatLatLng(_model.googleMapsCenter!),
                          ),
                          builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                            if (!snapshot.hasData) {
                              return MainLoadWidget();
                            }
                            final containerGeocodeLatLngResponse =
                                snapshot.data!;

                            return Container(
                              constraints: BoxConstraints(
                                minHeight: 120.0,
                              ),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(18.0),
                              ),
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
                                      FFAppState().pointA = PointStruct(
                                        latlng: _model.googleMapsCenter,
                                        placeID: GeocodeLatLngCall.placeId(
                                          containerGeocodeLatLngResponse
                                              .jsonBody,
                                        ),
                                        address: () {
                                          if ((GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      null &&
                                                  GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      '') &&
                                              (GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      null &&
                                                  GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      '')) {
                                            return '${GeocodeLatLngCall.street(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            )}, ${GeocodeLatLngCall.number(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            )}';
                                          } else if ((GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      null ||
                                                  GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      '') &&
                                              (GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      null ||
                                                  GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      '') &&
                                              (GeocodeLatLngCall.areal3(
                                                    containerGeocodeLatLngResponse
                                                        .jsonBody,
                                                  ) !=
                                                  null)) {
                                            return valueOrDefault<String>(
                                              '${GeocodeLatLngCall.areal3(
                                                containerGeocodeLatLngResponse
                                                    .jsonBody,
                                              ).toString()} район',
                                              'Откуда забрать',
                                            );
                                          } else if (GeocodeLatLngCall.street(
                                                    containerGeocodeLatLngResponse
                                                        .jsonBody,
                                                  ) !=
                                                  null &&
                                              GeocodeLatLngCall.street(
                                                    containerGeocodeLatLngResponse
                                                        .jsonBody,
                                                  ) !=
                                                  '') {
                                            return GeocodeLatLngCall.street(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            );
                                          } else if ((GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      null ||
                                                  GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      '') &&
                                              (GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      null ||
                                                  GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      '') &&
                                              (GeocodeLatLngCall.areal3(
                                                    containerGeocodeLatLngResponse
                                                        .jsonBody,
                                                  ) ==
                                                  null) &&
                                              (GeocodeLatLngCall.city(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      null &&
                                                  GeocodeLatLngCall.city(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      '') &&
                                              (GeocodeLatLngCall.areal(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      null &&
                                                  GeocodeLatLngCall.areal(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      '')) {
                                            return '${GeocodeLatLngCall.city(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            )}, ${GeocodeLatLngCall.areal(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            )}';
                                          } else {
                                            return GeocodeLatLngCall.address(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            );
                                          }
                                        }(),
                                        fullAddress: GeocodeLatLngCall.address(
                                          containerGeocodeLatLngResponse
                                              .jsonBody,
                                        ),
                                        city: GeocodeLatLngCall.address(
                                          containerGeocodeLatLngResponse
                                              .jsonBody,
                                        ),
                                      );
                                      safeSetState(() {});
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
                                                child: SearhAddressWidget(
                                                  index: 1,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      height: 60.0,
                                      decoration: BoxDecoration(),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 16.0,
                                              height: 16.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Color(0xFFA4A6B2),
                                                  width: 3.0,
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        13.0, 0.0, 0.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        if ((GeocodeLatLngCall
                                                                        .street(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .street(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                        .number(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .number(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                    .areal3(
                                                                  containerGeocodeLatLngResponse
                                                                      .jsonBody,
                                                                ) ==
                                                                null) &&
                                                            (GeocodeLatLngCall
                                                                        .city(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .city(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                        .areal(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .areal(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    ''))
                                                          Text(
                                                            'Откуда забрать',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color: Color(
                                                                      0xFFA4A6B2),
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        if ((GeocodeLatLngCall
                                                                        .street(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .street(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                        .number(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .number(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                    .areal3(
                                                                  containerGeocodeLatLngResponse
                                                                      .jsonBody,
                                                                ) ==
                                                                null) &&
                                                            (GeocodeLatLngCall
                                                                        .city(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .city(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                        .areal(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) !=
                                                                    null &&
                                                                GeocodeLatLngCall
                                                                        .areal(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) !=
                                                                    ''))
                                                          Text(
                                                            GeocodeLatLngCall
                                                                .areal(
                                                              containerGeocodeLatLngResponse
                                                                  .jsonBody,
                                                            )!,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color: Color(
                                                                      0xFFA4A6B2),
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        if ((GeocodeLatLngCall
                                                                        .street(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .street(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                        .number(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .number(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                    .areal3(
                                                                  containerGeocodeLatLngResponse
                                                                      .jsonBody,
                                                                ) ==
                                                                null) &&
                                                            (GeocodeLatLngCall
                                                                        .city(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) !=
                                                                    null &&
                                                                GeocodeLatLngCall
                                                                        .city(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) !=
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                        .areal(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) !=
                                                                    null &&
                                                                GeocodeLatLngCall
                                                                        .areal(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) !=
                                                                    ''))
                                                          Text(
                                                            '${GeocodeLatLngCall.city(
                                                              containerGeocodeLatLngResponse
                                                                  .jsonBody,
                                                            )}, ${GeocodeLatLngCall.areal(
                                                              containerGeocodeLatLngResponse
                                                                  .jsonBody,
                                                            )}',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        if ((GeocodeLatLngCall
                                                                        .street(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .street(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                        .number(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    null ||
                                                                GeocodeLatLngCall
                                                                        .number(
                                                                      containerGeocodeLatLngResponse
                                                                          .jsonBody,
                                                                    ) ==
                                                                    '') &&
                                                            (GeocodeLatLngCall
                                                                    .areal3(
                                                                  containerGeocodeLatLngResponse
                                                                      .jsonBody,
                                                                ) !=
                                                                null))
                                                          Text(
                                                            valueOrDefault<
                                                                String>(
                                                              '${GeocodeLatLngCall.areal3(
                                                                containerGeocodeLatLngResponse
                                                                    .jsonBody,
                                                              ).toString()} район',
                                                              'Откуда забрать',
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        if (GeocodeLatLngCall
                                                                    .street(
                                                                  containerGeocodeLatLngResponse
                                                                      .jsonBody,
                                                                ) !=
                                                                null &&
                                                            GeocodeLatLngCall
                                                                    .street(
                                                                  containerGeocodeLatLngResponse
                                                                      .jsonBody,
                                                                ) !=
                                                                '')
                                                          Text(
                                                            GeocodeLatLngCall
                                                                .street(
                                                              containerGeocodeLatLngResponse
                                                                  .jsonBody,
                                                            )!,
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                        if (GeocodeLatLngCall
                                                                    .number(
                                                                  containerGeocodeLatLngResponse
                                                                      .jsonBody,
                                                                ) !=
                                                                null &&
                                                            GeocodeLatLngCall
                                                                    .number(
                                                                  containerGeocodeLatLngResponse
                                                                      .jsonBody,
                                                                ) !=
                                                                '')
                                                          Text(
                                                            valueOrDefault<
                                                                String>(
                                                              ' , ${GeocodeLatLngCall.number(
                                                                containerGeocodeLatLngResponse
                                                                    .jsonBody,
                                                              )}',
                                                              'Откуда забрать',
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primaryText,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                          ),
                                                      ],
                                                    ),
                                                    Divider(
                                                      height: 0.3,
                                                      thickness: 0.3,
                                                      color: Color(0xFFD0CFCE),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 18.0)),
                                                ),
                                              ),
                                            ),
                                          ],
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
                                      FFAppState().pointA = PointStruct(
                                        latlng: _model.googleMapsCenter,
                                        placeID: GeocodeLatLngCall.placeId(
                                          containerGeocodeLatLngResponse
                                              .jsonBody,
                                        ),
                                        address: () {
                                          if ((GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      null &&
                                                  GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      '') &&
                                              (GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      null &&
                                                  GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      '')) {
                                            return '${GeocodeLatLngCall.street(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            )}, ${GeocodeLatLngCall.number(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            )}';
                                          } else if ((GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      null ||
                                                  GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      '') &&
                                              (GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      null ||
                                                  GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      '') &&
                                              (GeocodeLatLngCall.areal3(
                                                    containerGeocodeLatLngResponse
                                                        .jsonBody,
                                                  ) !=
                                                  null)) {
                                            return valueOrDefault<String>(
                                              '${GeocodeLatLngCall.areal3(
                                                containerGeocodeLatLngResponse
                                                    .jsonBody,
                                              ).toString()} район',
                                              'Откуда забрать',
                                            );
                                          } else if (GeocodeLatLngCall.street(
                                                    containerGeocodeLatLngResponse
                                                        .jsonBody,
                                                  ) !=
                                                  null &&
                                              GeocodeLatLngCall.street(
                                                    containerGeocodeLatLngResponse
                                                        .jsonBody,
                                                  ) !=
                                                  '') {
                                            return GeocodeLatLngCall.street(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            );
                                          } else if ((GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      null ||
                                                  GeocodeLatLngCall.street(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      '') &&
                                              (GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      null ||
                                                  GeocodeLatLngCall.number(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) ==
                                                      '') &&
                                              (GeocodeLatLngCall.areal3(
                                                    containerGeocodeLatLngResponse
                                                        .jsonBody,
                                                  ) ==
                                                  null) &&
                                              (GeocodeLatLngCall.city(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      null &&
                                                  GeocodeLatLngCall.city(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      '') &&
                                              (GeocodeLatLngCall.areal(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      null &&
                                                  GeocodeLatLngCall.areal(
                                                        containerGeocodeLatLngResponse
                                                            .jsonBody,
                                                      ) !=
                                                      '')) {
                                            return '${GeocodeLatLngCall.city(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            )}, ${GeocodeLatLngCall.areal(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            )}';
                                          } else {
                                            return GeocodeLatLngCall.address(
                                              containerGeocodeLatLngResponse
                                                  .jsonBody,
                                            );
                                          }
                                        }(),
                                        fullAddress: GeocodeLatLngCall.address(
                                          containerGeocodeLatLngResponse
                                              .jsonBody,
                                        ),
                                        city: GeocodeLatLngCall.city(
                                          containerGeocodeLatLngResponse
                                              .jsonBody,
                                        ),
                                      );
                                      safeSetState(() {});
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
                                                child: SearhAddressWidget(
                                                  index: 2,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((value) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      height: 60.0,
                                      decoration: BoxDecoration(),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 16.0,
                                              height: 16.0,
                                              decoration: BoxDecoration(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryBackground,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Color(0xFFA4A6B2),
                                                  width: 3.0,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        13.0, 0.0, 0.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                -1.0, 0.0),
                                                        child: Text(
                                                          'Куда доставить',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'SF',
                                                                color: Color(
                                                                    0xFFA4A6B2),
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
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
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 8.0, 0.0, 8.0),
                                    child: Container(
                                      height: 100.77,
                                      decoration: BoxDecoration(),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                _model.car = Car.largus;
                                                safeSetState(() {});
                                                HapticFeedback.mediumImpact();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: valueOrDefault<Color>(
                                                    _model.car == Car.largus
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary
                                                        : Colors.transparent,
                                                    FlutterFlowTheme.of(context)
                                                        .tertiary,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 0.0, 8.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0.0),
                                                        child: Image.asset(
                                                          'assets/images/1200x900_1.png',
                                                          width: 96.9,
                                                          height: 38.1,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    6.0,
                                                                    12.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Мини/S',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'SF',
                                                                    color: valueOrDefault<
                                                                        Color>(
                                                                      _model.car ==
                                                                              Car
                                                                                  .largus
                                                                          ? Colors
                                                                              .white
                                                                          : FlutterFlowTheme.of(context)
                                                                              .secondaryText,
                                                                      Colors
                                                                          .white,
                                                                    ),
                                                                    fontSize:
                                                                        14.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                            ),
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text: 'от ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: '797',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ₽',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'SF',
                                                                      color: valueOrDefault<
                                                                          Color>(
                                                                        _model.car ==
                                                                                Car.largus
                                                                            ? Colors.white
                                                                            : FlutterFlowTheme.of(context).primaryText,
                                                                        Colors
                                                                            .white,
                                                                      ),
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                _model.car = Car.fiat;
                                                safeSetState(() {});
                                                HapticFeedback.mediumImpact();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: valueOrDefault<Color>(
                                                    _model.car == Car.fiat
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary
                                                        : Colors.transparent,
                                                    Colors.transparent,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 0.0, 8.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0.0),
                                                        child: Image.asset(
                                                          'assets/images/fiat_16doblopackcv2fbc_sideview_1.png',
                                                          width: 92.53,
                                                          height: 39.2,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    6.0,
                                                                    12.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'МиниПлюс/M',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'SF',
                                                                    color: valueOrDefault<
                                                                        Color>(
                                                                      _model.car ==
                                                                              Car
                                                                                  .fiat
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .secondary
                                                                          : FlutterFlowTheme.of(context)
                                                                              .secondaryText,
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                    ),
                                                                    fontSize:
                                                                        14.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                            ),
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text: 'от ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '1035',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ₽',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'SF',
                                                                      color: valueOrDefault<
                                                                          Color>(
                                                                        _model.car ==
                                                                                Car.fiat
                                                                            ? FlutterFlowTheme.of(context).secondary
                                                                            : FlutterFlowTheme.of(context).primaryText,
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                      ),
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                _model.car = Car.largusTermo;
                                                safeSetState(() {});
                                                HapticFeedback.mediumImpact();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: valueOrDefault<Color>(
                                                    _model.car ==
                                                            Car.largusTermo
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary
                                                        : Colors.transparent,
                                                    Colors.transparent,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 0.0, 8.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0.0),
                                                        child: Image.asset(
                                                          'assets/images/ladalargus013_1.png',
                                                          width: 99.9,
                                                          height: 39.2,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    6.0,
                                                                    12.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Термобудка/S-M',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'SF',
                                                                    color: valueOrDefault<
                                                                        Color>(
                                                                      _model.car ==
                                                                              Car
                                                                                  .largusTermo
                                                                          ? FlutterFlowTheme.of(context)
                                                                              .secondary
                                                                          : FlutterFlowTheme.of(context)
                                                                              .secondaryText,
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .secondaryText,
                                                                    ),
                                                                    fontSize:
                                                                        14.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                            ),
                                                            RichText(
                                                              textScaler:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .textScaler,
                                                              text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text: 'от ',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        '2500',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          15.0,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: ' ₽',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12.0,
                                                                    ),
                                                                  )
                                                                ],
                                                                style: FlutterFlowTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .override(
                                                                      fontFamily:
                                                                          'SF',
                                                                      color: valueOrDefault<
                                                                          Color>(
                                                                        _model.car ==
                                                                                Car.largusTermo
                                                                            ? FlutterFlowTheme.of(context).secondary
                                                                            : FlutterFlowTheme.of(context).primaryText,
                                                                        FlutterFlowTheme.of(context)
                                                                            .primaryText,
                                                                      ),
                                                                      fontSize:
                                                                          16.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]
                                              .divide(SizedBox(width: 8.0))
                                              .addToStart(SizedBox(width: 16.0))
                                              .addToEnd(SizedBox(width: 16.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ].divide(SizedBox(height: 5.0)),
                    );
                  }
                },
              ),
            ),
            wrapWithModel(
              model: _model.navbarModel,
              updateCallback: () => safeSetState(() {}),
              child: NavbarWidget(
                index: 3,
              ),
            ),
          ].divide(SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
