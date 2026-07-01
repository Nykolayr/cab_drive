import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/driver/create_otklick/create_otklick_widget.dart';
import '/driver/otmena_otklika/otmena_otklika_widget.dart';
import '/driver/vkl_geo/vkl_geo_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import '/pages/bottom/create_rewievs/create_rewievs_widget.dart';
import '/pages/bottom/error_popup/error_popup_widget.dart';
import '/pages/bottom/image_view/image_view_widget.dart';
import '/pages/bottom/ratting/ratting_widget.dart';
import '/pages/bottom/text_info/text_info_widget.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/permissions_util.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'order_page_driver_model.dart';
export 'order_page_driver_model.dart';

class OrderPageDriverWidget extends StatefulWidget {
  const OrderPageDriverWidget({
    super.key,
    required this.order,
  });

  final DocumentReference? order;

  static String routeName = 'order_Page_Driver';
  static String routePath = '/orderPageDriver';

  @override
  State<OrderPageDriverWidget> createState() => _OrderPageDriverWidgetState();
}

class _OrderPageDriverWidgetState extends State<OrderPageDriverWidget> {
  late OrderPageDriverModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderPageDriverModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrderRecord>(
      stream: OrderRecord.getDocument(widget!.order!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Center(
              child: SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ),
          );
        }

        final orderPageDriverOrderRecord = snapshot.data!;

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
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            primary: false,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (orderPageDriverOrderRecord.userWhoResponced
                                    .contains(currentUserReference))
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        if ((orderPageDriverOrderRecord
                                                    .selectedDriver ==
                                                currentUserReference) &&
                                            (orderPageDriverOrderRecord
                                                    .status ==
                                                StatusOrder.at_work)) {
                                          return Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    24.0, 16.0, 24.0, 16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        'Сделайте фото перед завершением!',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily: 'SF',
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .error,
                                                              fontSize: 21.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              lineHeight: 1.0,
                                                            ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      FFIcons.kalertHexagon,
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .error,
                                                      size: 30.0,
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 5.0, 0.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Flexible(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      8.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Text(
                                                            'Перед тем как завершить заказ, сфотографируйте груз на месте доставки. \nЭто нужно для подтверждения, что всё доставлено.',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  fontSize:
                                                                      18.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (_model.image != null &&
                                                    (_model.image?.bytes
                                                            ?.isNotEmpty ??
                                                        false))
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 16.0,
                                                                0.0, 0.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child: Image.memory(
                                                            _model.image
                                                                    ?.bytes ??
                                                                Uint8List
                                                                    .fromList(
                                                                        []),
                                                            width:
                                                                double.infinity,
                                                            height: 150.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      12.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              final selectedMedia =
                                                                  await selectMedia(
                                                                maxWidth:
                                                                    500.00,
                                                                maxHeight:
                                                                    500.00,
                                                                imageQuality:
                                                                    95,
                                                                multiImage:
                                                                    false,
                                                              );
                                                              if (selectedMedia !=
                                                                      null &&
                                                                  selectedMedia.every((m) =>
                                                                      validateFileFormat(
                                                                          m.storagePath,
                                                                          context))) {
                                                                safeSetState(() =>
                                                                    _model.isDataUploading_uploadDataG2983 =
                                                                        true);
                                                                var selectedUploadedFiles =
                                                                    <FFUploadedFile>[];

                                                                try {
                                                                  selectedUploadedFiles =
                                                                      selectedMedia
                                                                          .map((m) =>
                                                                              FFUploadedFile(
                                                                                name: m.storagePath.split('/').last,
                                                                                bytes: m.bytes,
                                                                                height: m.dimensions?.height,
                                                                                width: m.dimensions?.width,
                                                                                blurHash: m.blurHash,
                                                                                originalFilename: m.originalFilename,
                                                                              ))
                                                                          .toList();
                                                                } finally {
                                                                  _model.isDataUploading_uploadDataG2983 =
                                                                      false;
                                                                }
                                                                if (selectedUploadedFiles
                                                                        .length ==
                                                                    selectedMedia
                                                                        .length) {
                                                                  safeSetState(
                                                                      () {
                                                                    _model.uploadedLocalFile_uploadDataG2983 =
                                                                        selectedUploadedFiles
                                                                            .first;
                                                                  });
                                                                } else {
                                                                  safeSetState(
                                                                      () {});
                                                                  return;
                                                                }
                                                              }

                                                              if (_model.uploadedLocalFile_uploadDataG2983 !=
                                                                      null &&
                                                                  (_model
                                                                          .uploadedLocalFile_uploadDataG2983
                                                                          .bytes
                                                                          ?.isNotEmpty ??
                                                                      false)) {
                                                                _model.image =
                                                                    _model
                                                                        .uploadedLocalFile_uploadDataG2983;
                                                                safeSetState(
                                                                    () {});
                                                              } else {
                                                                await showModalBottomSheet(
                                                                  isScrollControlled:
                                                                      true,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return WebViewAware(
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          FocusScope.of(context)
                                                                              .unfocus();
                                                                          FocusManager
                                                                              .instance
                                                                              .primaryFocus
                                                                              ?.unfocus();
                                                                        },
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              MediaQuery.viewInsetsOf(context),
                                                                          child:
                                                                              ErrorPopupWidget(
                                                                            title:
                                                                                'Что-то пошло не так',
                                                                            text:
                                                                                'Давайте попробуем позже.',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                ).then((value) =>
                                                                    safeSetState(
                                                                        () {}));

                                                                return;
                                                              }
                                                            },
                                                            text: 'Переснять',
                                                            options:
                                                                FFButtonOptions(
                                                              width: double
                                                                  .infinity,
                                                              height: 45.83,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          16.0,
                                                                          0.0,
                                                                          16.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .tertiary,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            'SF',
                                                                        color: Colors
                                                                            .white,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            showLoadingIndicator:
                                                                false,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        } else if ((orderPageDriverOrderRecord
                                                    .selectedDriver ==
                                                currentUserReference) &&
                                            (orderPageDriverOrderRecord
                                                    .status ==
                                                StatusOrder.on_confirmation)) {
                                          return Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    24.0, 16.0, 24.0, 16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Заказ на подтверждении',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        fontSize: 21.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Text(
                                                    orderPageDriverOrderRecord
                                                                .payMethod ==
                                                            PayMethod.card
                                                        ? 'Клиент должен подтвердить завершение заказа. Если он не сделает этого в течение 12 часов, заказ автоматически завершится, и вы получите оплату.'
                                                        : 'Вы завершили заказ и получили оплату наличными. Клиенту осталось подтвердить получение. Если он не сделает этого в течение 12 часов, заказ автоматически закроется в системе.',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                                if ((orderPageDriverOrderRecord
                                                            .selectedDriver ==
                                                        currentUserReference) &&
                                                    !orderPageDriverOrderRecord
                                                        .customerReviewed)
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            blurRadius: 4.0,
                                                            color: Color(
                                                                0x19000000),
                                                            offset: Offset(
                                                              0.0,
                                                              2.0,
                                                            ),
                                                          )
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    24.0,
                                                                    0.0,
                                                                    24.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 1,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 2,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 3,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 4,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 5,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        } else if ((orderPageDriverOrderRecord
                                                    .selectedDriver ==
                                                currentUserReference) &&
                                            (orderPageDriverOrderRecord
                                                    .status ==
                                                StatusOrder.completed)) {
                                          return Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    24.0, 16.0, 24.0, 16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Заказ завершён',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        fontSize: 21.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Text(
                                                    (orderPageDriverOrderRecord
                                                                    .selectedDriver ==
                                                                currentUserReference) &&
                                                            !orderPageDriverOrderRecord
                                                                .customerReviewed
                                                        ? 'Клиент подтвердил выполнение заказа.Спасибо за работу — заказ успешно завершён! Теперь вы можете оценить заказчика — это поможет другим водителям.'
                                                        : 'Клиент подтвердил выполнение заказа.Спасибо за работу — заказ успешно завершён!',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                                if ((orderPageDriverOrderRecord
                                                            .selectedDriver ==
                                                        currentUserReference) &&
                                                    !orderPageDriverOrderRecord
                                                        .customerReviewed)
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 24.0,
                                                                0.0, 0.0),
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .secondaryBackground,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            blurRadius: 4.0,
                                                            color: Color(
                                                                0x19000000),
                                                            offset: Offset(
                                                              0.0,
                                                              2.0,
                                                            ),
                                                          )
                                                        ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    24.0,
                                                                    0.0,
                                                                    24.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 1,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 2,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 3,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 4,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                                FlutterFlowIconButton(
                                                                  borderColor:
                                                                      Colors
                                                                          .transparent,
                                                                  borderRadius:
                                                                      8.0,
                                                                  buttonSize:
                                                                      55.0,
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  icon: Icon(
                                                                    FFIcons
                                                                        .kantDesignStarFilled,
                                                                    color: Color(
                                                                        0xFFEEEEEE),
                                                                    size: 40.0,
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    await showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return WebViewAware(
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              FocusScope.of(context).unfocus();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: MediaQuery.viewInsetsOf(context),
                                                                              child: CreateRewievsWidget(
                                                                                user: orderPageDriverOrderRecord.userCustomer!,
                                                                                order: widget!.order!,
                                                                                rait: 5,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ).then((value) =>
                                                                        safeSetState(
                                                                            () {}));
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        } else if ((orderPageDriverOrderRecord
                                                    .selectedDriver ==
                                                currentUserReference) &&
                                            (orderPageDriverOrderRecord
                                                    .status ==
                                                StatusOrder.spec_set)) {
                                          return Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    24.0, 16.0, 24.0, 16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Вас выбрали!',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        fontSize: 21.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Text(
                                                    orderPageDriverOrderRecord
                                                                .supply ==
                                                            1
                                                        ? 'Подача в ближайшее время: Подготовьтесь и отправляйтесь на точку подачи как можно скорее.'
                                                        : 'Заказ нужно выполнить к назначенному времени — заранее спланируйте маршрут и выезд.',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 18.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return FutureBuilder<
                                              List<ResponsesRecord>>(
                                            future: queryResponsesRecordOnce(
                                              parent: widget!.order,
                                              queryBuilder: (responsesRecord) =>
                                                  responsesRecord.where(
                                                'user_driver',
                                                isEqualTo: currentUserReference,
                                              ),
                                              singleRecord: true,
                                            ),
                                            builder: (context, snapshot) {
                                              // Customize what your widget looks like when it's loading.
                                              if (!snapshot.hasData) {
                                                return Center(
                                                  child: SizedBox(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .primary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              List<ResponsesRecord>
                                                  containerResponsesRecordList =
                                                  snapshot.data!;
                                              // Return an empty Container when the item does not exist.
                                              if (snapshot.data!.isEmpty) {
                                                return Container();
                                              }
                                              final containerResponsesRecord =
                                                  containerResponsesRecordList
                                                          .isNotEmpty
                                                      ? containerResponsesRecordList
                                                          .first
                                                      : null;

                                              return Container(
                                                decoration: BoxDecoration(),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(24.0, 16.0,
                                                          24.0, 16.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Отклик отправлен',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily: 'SF',
                                                              fontSize: 21.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    8.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: Text(
                                                          'Вы откликнулись на заказ.\nКлиент ещё не выбрал исполнителя — вы можете отменить отклик, пока заказ не принят.',
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .bodyMedium
                                                              .override(
                                                                fontFamily:
                                                                    'SF',
                                                                fontSize: 18.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    12.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .textInfoModel1,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: TextInfoWidget(
                                                            tittle:
                                                                'Сумма отклика',
                                                            pole:
                                                                containerResponsesRecord
                                                                    ?.price
                                                                    ?.toString(),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    12.0,
                                                                    0.0,
                                                                    0.0),
                                                        child: wrapWithModel(
                                                          model: _model
                                                              .textInfoModel2,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: TextInfoWidget(
                                                            tittle:
                                                                'Комментарий отклика',
                                                            pole:
                                                                containerResponsesRecord
                                                                    ?.text,
                                                          ),
                                                        ),
                                                      ),
                                                      if (orderPageDriverOrderRecord
                                                              .status ==
                                                          StatusOrder.newOrder)
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      12.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              await showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return WebViewAware(
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            MediaQuery.viewInsetsOf(context),
                                                                        child:
                                                                            OtmenaOtklikaWidget(
                                                                          order:
                                                                              orderPageDriverOrderRecord,
                                                                          resp:
                                                                              containerResponsesRecord!.reference,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            },
                                                            text:
                                                                'Отменить отклик',
                                                            options:
                                                                FFButtonOptions(
                                                              width: double
                                                                  .infinity,
                                                              height: 45.0,
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          40.0,
                                                                          0.0,
                                                                          40.0,
                                                                          0.0),
                                                              iconPadding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
                                                              textStyle:
                                                                  FlutterFlowTheme.of(
                                                                          context)
                                                                      .titleSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            'SF',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .error,
                                                                        fontSize:
                                                                            15.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                      ),
                                                              elevation: 0.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            showLoadingIndicator:
                                                                false,
                                                          ),
                                                        ),
                                                      if ((orderPageDriverOrderRecord
                                                                  .selectedDriver ==
                                                              currentUserReference) &&
                                                          !orderPageDriverOrderRecord
                                                              .customerReviewed)
                                                        Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      24.0,
                                                                      0.0,
                                                                      0.0),
                                                          child: Container(
                                                            width:
                                                                double.infinity,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondaryBackground,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      4.0,
                                                                  color: Color(
                                                                      0x19000000),
                                                                  offset:
                                                                      Offset(
                                                                    0.0,
                                                                    2.0,
                                                                  ),
                                                                )
                                                              ],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          24.0,
                                                                          0.0,
                                                                          24.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      FlutterFlowIconButton(
                                                                        borderColor:
                                                                            Colors.transparent,
                                                                        borderRadius:
                                                                            8.0,
                                                                        buttonSize:
                                                                            55.0,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        icon:
                                                                            Icon(
                                                                          FFIcons
                                                                              .kantDesignStarFilled,
                                                                          color:
                                                                              Color(0xFFEEEEEE),
                                                                          size:
                                                                              40.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return WebViewAware(
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    FocusScope.of(context).unfocus();
                                                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: MediaQuery.viewInsetsOf(context),
                                                                                    child: CreateRewievsWidget(
                                                                                      user: orderPageDriverOrderRecord.userCustomer!,
                                                                                      order: widget!.order!,
                                                                                      rait: 1,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) =>
                                                                              safeSetState(() {}));
                                                                        },
                                                                      ),
                                                                      FlutterFlowIconButton(
                                                                        borderColor:
                                                                            Colors.transparent,
                                                                        borderRadius:
                                                                            8.0,
                                                                        buttonSize:
                                                                            55.0,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        icon:
                                                                            Icon(
                                                                          FFIcons
                                                                              .kantDesignStarFilled,
                                                                          color:
                                                                              Color(0xFFEEEEEE),
                                                                          size:
                                                                              40.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return WebViewAware(
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    FocusScope.of(context).unfocus();
                                                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: MediaQuery.viewInsetsOf(context),
                                                                                    child: CreateRewievsWidget(
                                                                                      user: orderPageDriverOrderRecord.userCustomer!,
                                                                                      order: widget!.order!,
                                                                                      rait: 2,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) =>
                                                                              safeSetState(() {}));
                                                                        },
                                                                      ),
                                                                      FlutterFlowIconButton(
                                                                        borderColor:
                                                                            Colors.transparent,
                                                                        borderRadius:
                                                                            8.0,
                                                                        buttonSize:
                                                                            55.0,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        icon:
                                                                            Icon(
                                                                          FFIcons
                                                                              .kantDesignStarFilled,
                                                                          color:
                                                                              Color(0xFFEEEEEE),
                                                                          size:
                                                                              40.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return WebViewAware(
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    FocusScope.of(context).unfocus();
                                                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: MediaQuery.viewInsetsOf(context),
                                                                                    child: CreateRewievsWidget(
                                                                                      user: orderPageDriverOrderRecord.userCustomer!,
                                                                                      order: widget!.order!,
                                                                                      rait: 3,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) =>
                                                                              safeSetState(() {}));
                                                                        },
                                                                      ),
                                                                      FlutterFlowIconButton(
                                                                        borderColor:
                                                                            Colors.transparent,
                                                                        borderRadius:
                                                                            8.0,
                                                                        buttonSize:
                                                                            55.0,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        icon:
                                                                            Icon(
                                                                          FFIcons
                                                                              .kantDesignStarFilled,
                                                                          color:
                                                                              Color(0xFFEEEEEE),
                                                                          size:
                                                                              40.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return WebViewAware(
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    FocusScope.of(context).unfocus();
                                                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: MediaQuery.viewInsetsOf(context),
                                                                                    child: CreateRewievsWidget(
                                                                                      user: orderPageDriverOrderRecord.userCustomer!,
                                                                                      order: widget!.order!,
                                                                                      rait: 4,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) =>
                                                                              safeSetState(() {}));
                                                                        },
                                                                      ),
                                                                      FlutterFlowIconButton(
                                                                        borderColor:
                                                                            Colors.transparent,
                                                                        borderRadius:
                                                                            8.0,
                                                                        buttonSize:
                                                                            55.0,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        icon:
                                                                            Icon(
                                                                          FFIcons
                                                                              .kantDesignStarFilled,
                                                                          color:
                                                                              Color(0xFFEEEEEE),
                                                                          size:
                                                                              40.0,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (context) {
                                                                              return WebViewAware(
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    FocusScope.of(context).unfocus();
                                                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: MediaQuery.viewInsetsOf(context),
                                                                                    child: CreateRewievsWidget(
                                                                                      user: orderPageDriverOrderRecord.userCustomer!,
                                                                                      order: widget!.order!,
                                                                                      rait: 5,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ).then((value) =>
                                                                              safeSetState(() {}));
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                Container(
                                  width: double.infinity,
                                  height: orderPageDriverOrderRecord
                                              .selectedDriver ==
                                          currentUserReference
                                      ? 185.0
                                      : 140.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: FutureBuilder<UsersRecord>(
                                    future: UsersRecord.getDocumentOnce(
                                        orderPageDriverOrderRecord
                                            .userCustomer!),
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

                                      final containerUsersRecord =
                                          snapshot.data!;

                                      return Container(
                                        decoration: BoxDecoration(),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  24.0, 16.0, 24.0, 16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Заказчик',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 21.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 12.0, 0.0, 0.0),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      isScrollControlled: true,
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
                                                                  RattingWidget(
                                                                user: containerUsersRecord
                                                                    .reference,
                                                                index: 2,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    11.0,
                                                                    0.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryBackground,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            border: Border.all(
                                                              color: Color(
                                                                  0x27A4A6B2),
                                                            ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child: custom_widgets
                                                                .UserAvatarImage(
                                                              imageUrl:
                                                                  containerUsersRecord
                                                                      .photoUrl,
                                                              width: 45.0,
                                                              height: 60.0,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              containerUsersRecord
                                                                  .displayName,
                                                              maxLines: 1,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'SF',
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                            Builder(
                                                              builder:
                                                                  (context) {
                                                                if (containerUsersRecord
                                                                        .numberOfReviews !=
                                                                    0) {
                                                                  return Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            30.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              10.0,
                                                                              4.0,
                                                                              10.0,
                                                                              4.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children:
                                                                                [
                                                                              Icon(
                                                                                FFIcons.kantDesignStarFilled,
                                                                                color: FlutterFlowTheme.of(context).warning,
                                                                                size: 16.0,
                                                                              ),
                                                                              Text(
                                                                                formatNumber(
                                                                                  containerUsersRecord.averageRating,
                                                                                  formatType: FormatType.custom,
                                                                                  format: '0.0',
                                                                                  locale: '',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: 'SF',
                                                                                      color: Color(0xFFA4A6B2),
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                              ),
                                                                            ].divide(SizedBox(width: 6.0)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            30.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                              10.0,
                                                                              4.0,
                                                                              10.0,
                                                                              4.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children:
                                                                                [
                                                                              Icon(
                                                                                FFIcons.kmessageTextCircle02,
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                size: 14.0,
                                                                              ),
                                                                              Text(
                                                                                containerUsersRecord.numberOfReviews.toString(),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: 'SF',
                                                                                      color: Color(0xFFA4A6B2),
                                                                                      letterSpacing: 0.0,
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                              ),
                                                                            ].divide(SizedBox(width: 6.0)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ].divide(SizedBox(
                                                                        width:
                                                                            4.0)),
                                                                  );
                                                                } else {
                                                                  return Container(
                                                                    height:
                                                                        30.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primaryBackground,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8.0),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          10.0,
                                                                          4.0,
                                                                          10.0,
                                                                          4.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children:
                                                                            [
                                                                          Icon(
                                                                            FFIcons.kantDesignStarFilled,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).warning,
                                                                            size:
                                                                                16.0,
                                                                          ),
                                                                          Text(
                                                                            'Нет отзывов',
                                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                  fontFamily: 'SF',
                                                                                  color: Color(0xFFA4A6B2),
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 6.0)),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ].divide(SizedBox(
                                                              height: 9.0)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (orderPageDriverOrderRecord
                                                      .selectedDriver ==
                                                  currentUserReference)
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 8.0, 0.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Expanded(
                                                        child: FFButtonWidget(
                                                          onPressed: () async {
                                                            var _shouldSetState =
                                                                false;
                                                            _model.mychats =
                                                                await queryChatsRecordOnce(
                                                              queryBuilder:
                                                                  (chatsRecord) =>
                                                                      chatsRecord
                                                                          .where(
                                                                'users',
                                                                arrayContains:
                                                                    currentUserReference,
                                                              ),
                                                            );
                                                            _shouldSetState =
                                                                true;
                                                            if (_model.mychats!
                                                                .where((e) => e
                                                                    .users
                                                                    .contains(
                                                                        containerUsersRecord
                                                                            .reference))
                                                                .toList()
                                                                .isNotEmpty) {
                                                              context.pushNamed(
                                                                ChatWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'chat':
                                                                      serializeParam(
                                                                    _model
                                                                        .mychats
                                                                        ?.where((e) => e
                                                                            .users
                                                                            .contains(containerUsersRecord.reference))
                                                                        .toList()
                                                                        ?.firstOrNull
                                                                        ?.reference,
                                                                    ParamType
                                                                        .DocumentReference,
                                                                  ),
                                                                  'name':
                                                                      serializeParam(
                                                                    '${containerUsersRecord.displayName} ${containerUsersRecord.surname}',
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                }.withoutNulls,
                                                              );

                                                              if (_shouldSetState)
                                                                safeSetState(
                                                                    () {});
                                                              return;
                                                            } else {
                                                              var chatsRecordReference =
                                                                  ChatsRecord
                                                                      .collection
                                                                      .doc();
                                                              await chatsRecordReference
                                                                  .set({
                                                                ...createChatsRecordData(
                                                                  dateCreated:
                                                                      getCurrentTimestamp,
                                                                  support:
                                                                      false,
                                                                ),
                                                                ...mapToFirestore(
                                                                  {
                                                                    'users': functions.comnineUsers(
                                                                        containerUsersRecord
                                                                            .reference,
                                                                        currentUserReference!),
                                                                  },
                                                                ),
                                                              });
                                                              _model.newchat =
                                                                  ChatsRecord
                                                                      .getDocumentFromData({
                                                                ...createChatsRecordData(
                                                                  dateCreated:
                                                                      getCurrentTimestamp,
                                                                  support:
                                                                      false,
                                                                ),
                                                                ...mapToFirestore(
                                                                  {
                                                                    'users': functions.comnineUsers(
                                                                        containerUsersRecord
                                                                            .reference,
                                                                        currentUserReference!),
                                                                  },
                                                                ),
                                                              }, chatsRecordReference);
                                                              _shouldSetState =
                                                                  true;

                                                              context.pushNamed(
                                                                ChatWidget
                                                                    .routeName,
                                                                queryParameters:
                                                                    {
                                                                  'chat':
                                                                      serializeParam(
                                                                    _model
                                                                        .newchat
                                                                        ?.reference,
                                                                    ParamType
                                                                        .DocumentReference,
                                                                  ),
                                                                  'name':
                                                                      serializeParam(
                                                                    '${containerUsersRecord.displayName} ${containerUsersRecord.surname}',
                                                                    ParamType
                                                                        .String,
                                                                  ),
                                                                }.withoutNulls,
                                                              );

                                                              if (_shouldSetState)
                                                                safeSetState(
                                                                    () {});
                                                              return;
                                                            }

                                                            if (_shouldSetState)
                                                              safeSetState(
                                                                  () {});
                                                          },
                                                          text: 'Написать',
                                                          options:
                                                              FFButtonOptions(
                                                            height: 45.0,
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        40.0,
                                                                        0.0,
                                                                        40.0,
                                                                        0.0),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'SF',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                      fontSize:
                                                                          15.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.0),
                                                          ),
                                                          showLoadingIndicator:
                                                              false,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: FFButtonWidget(
                                                          onPressed: () async {
                                                            await launchUrl(Uri(
                                                              scheme: 'tel',
                                                              path: containerUsersRecord
                                                                  .phoneNumber,
                                                            ));
                                                          },
                                                          text: 'Позвонить',
                                                          options:
                                                              FFButtonOptions(
                                                            height: 45.0,
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        40.0,
                                                                        0.0,
                                                                        40.0,
                                                                        0.0),
                                                            iconPadding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primaryBackground,
                                                            textStyle:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .titleSmall
                                                                    .override(
                                                                      fontFamily:
                                                                          'SF',
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .tertiary,
                                                                      fontSize:
                                                                          15.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                            elevation: 0.0,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.0),
                                                          ),
                                                          showLoadingIndicator:
                                                              false,
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 7.0)),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 1.0),
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 150.0,
                                                  child: custom_widgets
                                                      .PolylineMap(
                                                    width: double.infinity,
                                                    height: 150.0,
                                                    googleApiKey:
                                                        'AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
                                                    startLatLng:
                                                        orderPageDriverOrderRecord
                                                            .pointA.latlng!,
                                                    endLatLng:
                                                        orderPageDriverOrderRecord
                                                            .pointB.latlng!,
                                                    isStatic: true,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: FFButtonWidget(
                                                onPressed: () async {
                                                  context.pushNamed(
                                                    ZakazNaKarteWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'order': serializeParam(
                                                        widget!.order,
                                                        ParamType
                                                            .DocumentReference,
                                                      ),
                                                    }.withoutNulls,
                                                  );
                                                },
                                                text: 'Маршрут на карте',
                                                options: FFButtonOptions(
                                                  width: double.infinity,
                                                  height: 35.0,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          16.0, 0.0, 16.0, 0.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: Color(0xD8F4F5F8),
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .titleSmall
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .tertiary,
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                  elevation: 0.0,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                showLoadingIndicator: false,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (responsiveVisibility(
                                          context: context,
                                          phone: false,
                                          tablet: false,
                                          tabletLandscape: false,
                                          desktop: false,
                                        ))
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 12.0, 0.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  child: FFButtonWidget(
                                                    onPressed: () async {
                                                      await actions
                                                          .open2GISRoute(
                                                        orderPageDriverOrderRecord
                                                            .pointA.latlng!,
                                                        orderPageDriverOrderRecord
                                                            .pointB.latlng!,
                                                      );
                                                    },
                                                    text: 'В 2ГИС',
                                                    options: FFButtonOptions(
                                                      width: 222.0,
                                                      height: 45.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      color: Color(0xD8F4F5F8),
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily:
                                                                    'SF',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .tertiary,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                      elevation: 0.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16.0),
                                                    ),
                                                    showLoadingIndicator: false,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: FFButtonWidget(
                                                    onPressed: () async {
                                                      await actions
                                                          .openYandexRoute(
                                                        orderPageDriverOrderRecord
                                                            .pointA.latlng!,
                                                        orderPageDriverOrderRecord
                                                            .pointB.latlng!,
                                                      );
                                                    },
                                                    text: 'В Яндекс картах',
                                                    options: FFButtonOptions(
                                                      width: double.infinity,
                                                      height: 45.0,
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      iconPadding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0.0,
                                                                  0.0,
                                                                  0.0,
                                                                  0.0),
                                                      color: Color(0xD8F4F5F8),
                                                      textStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .titleSmall
                                                              .override(
                                                                fontFamily:
                                                                    'SF',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .tertiary,
                                                                fontSize: 16.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                      elevation: 0.0,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16.0),
                                                    ),
                                                    showLoadingIndicator: false,
                                                  ),
                                                ),
                                              ].divide(SizedBox(width: 8.0)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    if (valueOrDefault<bool>(
                                      orderPageDriverOrderRecord
                                              .selectedDriver ==
                                          currentUserReference,
                                      false,
                                    )) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      24.0, 16.0, 24.0, 16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Детали заказа',
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 21.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Stack(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0.0, 0.0),
                                                        children: [
                                                          wrapWithModel(
                                                            model: _model
                                                                .textInfoModel3,
                                                            updateCallback: () =>
                                                                safeSetState(
                                                                    () {}),
                                                            child:
                                                                TextInfoWidget(
                                                              tittle:
                                                                  'Откуда',
                                                              pole:
                                                                  orderPageDriverOrderRecord
                                                                      .pointA
                                                                      .address,
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    1.0, 0.0),
                                                            child:
                                                                FlutterFlowIconButton(
                                                              buttonSize:
                                                                  50.0,
                                                              icon: Icon(
                                                                Icons
                                                                    .content_copy_outlined,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .tertiary,
                                                                size: 20.0,
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                HapticFeedback
                                                                    .heavyImpact();
                                                                await Clipboard.setData(ClipboardData(
                                                                    text: orderPageDriverOrderRecord
                                                                        .pointA
                                                                        .fullAddress));
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (orderPageDriverOrderRecord
                                                                  .pointA
                                                                  .entrance !=
                                                              0)
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        valueOrDefault<
                                                                            double>(
                                                                          orderPageDriverOrderRecord.pointA.flat != '0'
                                                                              ? 7.0
                                                                              : 0.0,
                                                                          0.0,
                                                                        ),
                                                                        0.0),
                                                                child:
                                                                    wrapWithModel(
                                                                  model: _model
                                                                      .textInfoModel4,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  child:
                                                                      TextInfoWidget(
                                                                    tittle:
                                                                        'Подъезд',
                                                                    pole: orderPageDriverOrderRecord
                                                                        .pointA
                                                                        .entrance
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          if (orderPageDriverOrderRecord
                                                                  .pointA
                                                                  .flat !=
                                                              '0')
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        valueOrDefault<
                                                                            double>(
                                                                          orderPageDriverOrderRecord.pointA.entrance != 0
                                                                              ? 7.0
                                                                              : 0.0,
                                                                          0.0,
                                                                        ),
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    wrapWithModel(
                                                                  model: _model
                                                                      .textInfoModel5,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  child:
                                                                      TextInfoWidget(
                                                                    tittle:
                                                                        'Кв./офис',
                                                                    pole: orderPageDriverOrderRecord
                                                                        .pointA
                                                                        .flat,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (orderPageDriverOrderRecord
                                                                  .pointA
                                                                  .floor !=
                                                              0)
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        0.0,
                                                                        0.0,
                                                                        valueOrDefault<
                                                                            double>(
                                                                          orderPageDriverOrderRecord.pointA.intercom != '0'
                                                                              ? 7.0
                                                                              : 0.0,
                                                                          0.0,
                                                                        ),
                                                                        0.0),
                                                                child:
                                                                    wrapWithModel(
                                                                  model: _model
                                                                      .textInfoModel6,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  child:
                                                                      TextInfoWidget(
                                                                    tittle:
                                                                        'Этаж',
                                                                    pole: orderPageDriverOrderRecord
                                                                        .pointA
                                                                        .floor
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          if (orderPageDriverOrderRecord
                                                                  .pointA
                                                                  .intercom !=
                                                              '0')
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        valueOrDefault<
                                                                            double>(
                                                                          orderPageDriverOrderRecord.pointA.floor != 0
                                                                              ? 7.0
                                                                              : 0.0,
                                                                          0.0,
                                                                        ),
                                                                        0.0,
                                                                        0.0,
                                                                        0.0),
                                                                child:
                                                                    wrapWithModel(
                                                                  model: _model
                                                                      .textInfoModel7,
                                                                  updateCallback: () =>
                                                                      safeSetState(
                                                                          () {}),
                                                                  child:
                                                                      TextInfoWidget(
                                                                    tittle:
                                                                        'Домофон',
                                                                    pole: orderPageDriverOrderRecord
                                                                        .pointA
                                                                        .intercom,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      if (orderPageDriverOrderRecord
                                                                  .pointA
                                                                  .comment !=
                                                              null &&
                                                          orderPageDriverOrderRecord
                                                                  .pointA
                                                                  .comment !=
                                                              '')
                                                        wrapWithModel(
                                                          model: _model
                                                              .textInfoModel8,
                                                          updateCallback: () =>
                                                              safeSetState(
                                                                  () {}),
                                                          child: TextInfoWidget(
                                                            tittle:
                                                                'Комментарий водителю',
                                                            pole:
                                                                orderPageDriverOrderRecord
                                                                    .pointA
                                                                    .comment,
                                                          ),
                                                        ),
                                                      wrapWithModel(
                                                        model: _model
                                                            .textInfoModel9,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child: TextInfoWidget(
                                                          tittle:
                                                              'Контакт отправителя',
                                                          pole:
                                                              '${orderPageDriverOrderRecord.pointA.sender.phone}, ${orderPageDriverOrderRecord.pointA.sender.name}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      24.0, 16.0, 24.0, 16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    children: [
                                                      wrapWithModel(
                                                        model: _model
                                                            .textInfoModel10,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child: TextInfoWidget(
                                                          tittle: 'Куда',
                                                          pole:
                                                              orderPageDriverOrderRecord
                                                                  .pointB
                                                                  .address,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        child:
                                                            FlutterFlowIconButton(
                                                          buttonSize: 50.0,
                                                          icon: Icon(
                                                            Icons
                                                                .content_copy_outlined,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .tertiary,
                                                            size: 20.0,
                                                          ),
                                                          onPressed: () async {
                                                            HapticFeedback
                                                                .heavyImpact();
                                                            await Clipboard.setData(
                                                                ClipboardData(
                                                                    text: orderPageDriverOrderRecord
                                                                        .pointB
                                                                        .fullAddress));
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (orderPageDriverOrderRecord
                                                              .pointB
                                                              .entrance !=
                                                          0)
                                                        Expanded(
                                                          child: Padding(
                                                            padding: EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    valueOrDefault<
                                                                        double>(
                                                                      orderPageDriverOrderRecord.pointB.flat !=
                                                                              '0'
                                                                          ? 7.0
                                                                          : 0.0,
                                                                      0.0,
                                                                    ),
                                                                    0.0),
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .textInfoModel11,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  TextInfoWidget(
                                                                tittle:
                                                                    'Подъезд',
                                                                pole: orderPageDriverOrderRecord
                                                                    .pointB
                                                                    .entrance
                                                                    .toString(),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      if (orderPageDriverOrderRecord
                                                              .pointB.flat !=
                                                          '0')
                                                        Expanded(
                                                          child: Padding(
                                                            padding: EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    valueOrDefault<
                                                                        double>(
                                                                      orderPageDriverOrderRecord.pointB.entrance !=
                                                                              0
                                                                          ? 7.0
                                                                          : 0.0,
                                                                      0.0,
                                                                    ),
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .textInfoModel12,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  TextInfoWidget(
                                                                tittle:
                                                                    'Кв./офис',
                                                                pole:
                                                                    orderPageDriverOrderRecord
                                                                        .pointB
                                                                        .flat,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (orderPageDriverOrderRecord
                                                              .pointB.floor !=
                                                          0)
                                                        Expanded(
                                                          child: Padding(
                                                            padding: EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    0.0,
                                                                    0.0,
                                                                    valueOrDefault<
                                                                        double>(
                                                                      orderPageDriverOrderRecord.pointB.intercom !=
                                                                              '0'
                                                                          ? 7.0
                                                                          : 0.0,
                                                                      0.0,
                                                                    ),
                                                                    0.0),
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .textInfoModel13,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  TextInfoWidget(
                                                                tittle: 'Этаж',
                                                                pole: orderPageDriverOrderRecord
                                                                    .pointB
                                                                    .floor
                                                                    .toString(),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      if (orderPageDriverOrderRecord
                                                              .pointB
                                                              .intercom !=
                                                          '0')
                                                        Expanded(
                                                          child: Padding(
                                                            padding: EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    valueOrDefault<
                                                                        double>(
                                                                      orderPageDriverOrderRecord.pointB.floor !=
                                                                              0
                                                                          ? 7.0
                                                                          : 0.0,
                                                                      0.0,
                                                                    ),
                                                                    0.0,
                                                                    0.0,
                                                                    0.0),
                                                            child:
                                                                wrapWithModel(
                                                              model: _model
                                                                  .textInfoModel14,
                                                              updateCallback: () =>
                                                                  safeSetState(
                                                                      () {}),
                                                              child:
                                                                  TextInfoWidget(
                                                                tittle:
                                                                    'Домофон',
                                                                pole: orderPageDriverOrderRecord
                                                                    .pointB
                                                                    .intercom,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  if (orderPageDriverOrderRecord
                                                              .pointB.comment !=
                                                          null &&
                                                      orderPageDriverOrderRecord
                                                              .pointB.comment !=
                                                          '')
                                                    wrapWithModel(
                                                      model: _model
                                                          .textInfoModel15,
                                                      updateCallback: () =>
                                                          safeSetState(() {}),
                                                      child: TextInfoWidget(
                                                        tittle:
                                                            'Комментарий водителю',
                                                        pole:
                                                            orderPageDriverOrderRecord
                                                                .pointB.comment,
                                                      ),
                                                    ),
                                                  wrapWithModel(
                                                    model:
                                                        _model.textInfoModel16,
                                                    updateCallback: () =>
                                                        safeSetState(() {}),
                                                    child: TextInfoWidget(
                                                      tittle:
                                                          'Контакт отправителя',
                                                      pole:
                                                          '${orderPageDriverOrderRecord.pointB.sender.phone}, ${orderPageDriverOrderRecord.pointB.sender.name}',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(height: 5.0)),
                                      );
                                    } else {
                                      return Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                        ),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  24.0, 16.0, 24.0, 16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Детали заказа',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 21.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Stack(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    children: [
                                                      wrapWithModel(
                                                        model: _model
                                                            .textInfoModel17,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child: TextInfoWidget(
                                                          tittle: 'Откуда',
                                                          pole:
                                                              orderPageDriverOrderRecord
                                                                  .pointA
                                                                  .address,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        child:
                                                            FlutterFlowIconButton(
                                                          buttonSize: 50.0,
                                                          icon: Icon(
                                                            Icons
                                                                .content_copy_outlined,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .tertiary,
                                                            size: 20.0,
                                                          ),
                                                          onPressed: () async {
                                                            HapticFeedback
                                                                .heavyImpact();
                                                            await Clipboard.setData(
                                                                ClipboardData(
                                                                    text: orderPageDriverOrderRecord
                                                                        .pointA
                                                                        .fullAddress));
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Stack(
                                                    alignment:
                                                        AlignmentDirectional(
                                                            0.0, 0.0),
                                                    children: [
                                                      wrapWithModel(
                                                        model: _model
                                                            .textInfoModel18,
                                                        updateCallback: () =>
                                                            safeSetState(() {}),
                                                        child: TextInfoWidget(
                                                          tittle: 'Куда',
                                                          pole:
                                                              orderPageDriverOrderRecord
                                                                  .pointB
                                                                  .address,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                1.0, 0.0),
                                                        child:
                                                            FlutterFlowIconButton(
                                                          buttonSize: 50.0,
                                                          icon: Icon(
                                                            Icons
                                                                .content_copy_outlined,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .tertiary,
                                                            size: 20.0,
                                                          ),
                                                          onPressed: () async {
                                                            HapticFeedback
                                                                .heavyImpact();
                                                            await Clipboard.setData(
                                                                ClipboardData(
                                                                    text: orderPageDriverOrderRecord
                                                                        .pointB
                                                                        .fullAddress));
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        wrapWithModel(
                                          model: _model.textInfoModel19,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle: 'Ожидаемая стоимость',
                                            pole:
                                                '${orderPageDriverOrderRecord.budget.toString()} ₽',
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.textInfoModel20,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle:
                                                'Итоговая стоимость доставки',
                                            pole:
                                                '${orderPageDriverOrderRecord.currentPrice.toString()} ₽',
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.textInfoModel21,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle: 'Способ оплаты',
                                            pole: orderPageDriverOrderRecord
                                                        .payMethod ==
                                                    PayMethod.card
                                                ? 'Оплата картой'
                                                : 'Оплата наличными',
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.textInfoModel22,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle: 'Время и дистанция',
                                            pole:
                                                '${orderPageDriverOrderRecord.time}, ${orderPageDriverOrderRecord.distance}',
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.textInfoModel23,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle: 'Подача',
                                            pole: orderPageDriverOrderRecord
                                                        .supply ==
                                                    1
                                                ? 'В ближайшее время'
                                                : valueOrDefault<String>(
                                                    dateTimeFormat(
                                                      "MMMMEEEEd",
                                                      orderPageDriverOrderRecord
                                                          .dateTime,
                                                      locale:
                                                          FFLocalizations.of(
                                                                  context)
                                                              .languageCode,
                                                    ),
                                                    'MMMMEEEEd HH:mm',
                                                  ),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.textInfoModel24,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle: 'Грузчики',
                                            pole: () {
                                              if (orderPageDriverOrderRecord
                                                      .movers ==
                                                  1) {
                                                return 'Нужна помощь водителя';
                                              } else if (orderPageDriverOrderRecord
                                                      .movers ==
                                                  2) {
                                                return 'Нужна помощь двух грузчиков';
                                              } else {
                                                return 'Помощь не нужна';
                                              }
                                            }(),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.textInfoModel25,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle: 'Авто',
                                            pole: () {
                                              if (orderPageDriverOrderRecord
                                                      .car ==
                                                  Car.largus) {
                                                return 'LADA Largus';
                                              } else if (orderPageDriverOrderRecord
                                                      .car ==
                                                  Car.largusTermo) {
                                                return 'LADA Largus с термо будкой';
                                              } else {
                                                return 'Fiat Doblò/Citroën Berlingo/PEUGEOT PARTNER ';
                                              }
                                            }(),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.textInfoModel26,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle: 'Описание груза',
                                            pole: orderPageDriverOrderRecord
                                                .description,
                                          ),
                                        ),
                                        if (orderPageDriverOrderRecord
                                            .images.isNotEmpty)
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 16.0, 0.0, 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Фото груза',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 12.0, 0.0, 0.0),
                                                  child: Builder(
                                                    builder: (context) {
                                                      final imagesCargo =
                                                          orderPageDriverOrderRecord
                                                              .images
                                                              .toList();

                                                      return GridView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 5,
                                                          crossAxisSpacing: 6.0,
                                                          mainAxisSpacing: 6.0,
                                                          childAspectRatio: 1.0,
                                                        ),
                                                        primary: false,
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.vertical,
                                                        itemCount:
                                                            imagesCargo.length,
                                                        itemBuilder: (context,
                                                            imagesCargoIndex) {
                                                          final imagesCargoItem =
                                                              imagesCargo[
                                                                  imagesCargoIndex];
                                                          return InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              await showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return WebViewAware(
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        FocusScope.of(context)
                                                                            .unfocus();
                                                                        FocusManager
                                                                            .instance
                                                                            .primaryFocus
                                                                            ?.unfocus();
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            MediaQuery.viewInsetsOf(context),
                                                                        child:
                                                                            ImageViewWidget(
                                                                          indexCurrent:
                                                                              imagesCargoIndex,
                                                                          alllistImage:
                                                                              orderPageDriverOrderRecord.images,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ).then((value) =>
                                                                  safeSetState(
                                                                      () {}));
                                                            },
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              child:
                                                                  Image.network(
                                                                imagesCargoItem,
                                                                width: double
                                                                    .infinity,
                                                                height: 120.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ].addToEnd(SizedBox(height: 120.0)),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(height: 5.0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                  ),
                  child: Builder(
                    builder: (context) {
                      if ((orderPageDriverOrderRecord.status ==
                              StatusOrder.newOrder) &&
                          !orderPageDriverOrderRecord.userWhoResponced
                              .contains(currentUserReference)) {
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 8.0, 8.0, 34.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              if (valueOrDefault<bool>(
                                  currentUserDocument?.verifCompl, false)) {
                                if (await getPermissionStatus(
                                    locationPermission)) {
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
                                            child: CreateOtklickWidget(
                                              order: orderPageDriverOrderRecord,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));

                                  return;
                                } else {
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
                                            child: VklGeoWidget(),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));

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
                                            child: CreateOtklickWidget(
                                              order: orderPageDriverOrderRecord,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));

                                  return;
                                }
                              } else {
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
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: ErrorPopupWidget(
                                            title: 'Аккаунт на модерации!',
                                            text:
                                                'Мы проверим ваш аккаунт в течении 24 часов, и откроем вам доступ ко всему приложению.',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));

                                return;
                              }
                            },
                            text: 'Откликнуться',
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
                        );
                      } else if ((orderPageDriverOrderRecord.selectedDriver ==
                              currentUserReference) &&
                          (orderPageDriverOrderRecord.status ==
                              StatusOrder.spec_set) &&
                          (currentUserDocument?.currentOrder?.orderDocRef ==
                              null)) {
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 8.0, 8.0, 34.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              currentUserLocationValue =
                                  await getCurrentUserLocation(
                                      defaultLocation: LatLng(0.0, 0.0));
                              if (await getPermissionStatus(
                                  locationPermission)) {
                                await widget!.order!
                                    .update(createOrderRecordData(
                                  status: StatusOrder.at_work,
                                  driverLocation: currentUserLocationValue,
                                ));

                                await currentUserReference!
                                    .update(createUsersRecordData(
                                  currentOrder: updateCurrentOrderStruct(
                                    CurrentOrderStruct(
                                      orderDocRef:
                                          orderPageDriverOrderRecord.reference,
                                      pointB: orderPageDriverOrderRecord
                                          .pointB.latlng,
                                    ),
                                    clearUnsetFields: false,
                                  ),
                                ));
                                await actions.toggleRouteTracking(
                                  'AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
                                  true,
                                  widget!.order!,
                                  orderPageDriverOrderRecord.pointB.latlng!,
                                );
                                triggerPushNotification(
                                  notificationTitle:
                                      'Статус заказа изменен на \"В работе\"',
                                  notificationText:
                                      'Водитель начал выполнение заказа. Вы можете отследить выполнение в приложении',
                                  notificationSound: 'default',
                                  userRefs: [
                                    orderPageDriverOrderRecord.userCustomer!
                                  ],
                                  initialPageName: 'order_Page_Customer',
                                  parameterData: {
                                    'index': 1,
                                    'order': widget!.order,
                                  },
                                );
                              } else {
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
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: VklGeoWidget(),
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));

                                return;
                              }
                            },
                            text: 'Начать заказ',
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
                        );
                      } else if ((orderPageDriverOrderRecord.selectedDriver ==
                              currentUserReference) &&
                          (orderPageDriverOrderRecord.status ==
                              StatusOrder.at_work) &&
                          (_model.image == null ||
                              (_model.image?.bytes?.isEmpty ?? true))) {
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 8.0, 8.0, 35.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              if (!(await getPermissionStatus(
                                  cameraPermission))) {
                                await requestPermission(cameraPermission);
                                return;
                              }
                              final selectedMedia = await selectMedia(
                                maxWidth: 500.00,
                                maxHeight: 500.00,
                                imageQuality: 95,
                                multiImage: false,
                              );
                              if (selectedMedia != null &&
                                  selectedMedia.every((m) => validateFileFormat(
                                      m.storagePath, context))) {
                                safeSetState(() => _model
                                    .isDataUploading_uploadDataG298 = true);
                                var selectedUploadedFiles = <FFUploadedFile>[];

                                try {
                                  selectedUploadedFiles = selectedMedia
                                      .map((m) => FFUploadedFile(
                                            name: m.storagePath.split('/').last,
                                            bytes: m.bytes,
                                            height: m.dimensions?.height,
                                            width: m.dimensions?.width,
                                            blurHash: m.blurHash,
                                            originalFilename:
                                                m.originalFilename,
                                          ))
                                      .toList();
                                } finally {
                                  _model.isDataUploading_uploadDataG298 = false;
                                }
                                if (selectedUploadedFiles.length ==
                                    selectedMedia.length) {
                                  safeSetState(() {
                                    _model.uploadedLocalFile_uploadDataG298 =
                                        selectedUploadedFiles.first;
                                  });
                                } else {
                                  safeSetState(() {});
                                  return;
                                }
                              }

                              if (_model.uploadedLocalFile_uploadDataG298 !=
                                      null &&
                                  (_model.uploadedLocalFile_uploadDataG298.bytes
                                          ?.isNotEmpty ??
                                      false)) {
                                _model.image =
                                    _model.uploadedLocalFile_uploadDataG298;
                                safeSetState(() {});
                              } else {
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
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: ErrorPopupWidget(
                                            title: 'Что-то пошло не так',
                                            text: 'Давайте попробуем позже.',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));

                                return;
                              }
                            },
                            text: 'Сделать фото',
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
                          ),
                        );
                      } else if ((orderPageDriverOrderRecord.selectedDriver ==
                              currentUserReference) &&
                          (orderPageDriverOrderRecord.status ==
                              StatusOrder.at_work) &&
                          (_model.image != null &&
                              (_model.image?.bytes?.isNotEmpty ?? false))) {
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              8.0, 8.0, 8.0, 35.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              {
                                safeSetState(() => _model
                                    .isDataUploading_uploadDataSk6 = true);
                                var selectedUploadedFiles = <FFUploadedFile>[];
                                var selectedMedia = <SelectedFile>[];
                                var downloadUrls = <String>[];
                                try {
                                  selectedUploadedFiles =
                                      _model.image!.bytes!.isNotEmpty
                                          ? [_model.image!]
                                          : <FFUploadedFile>[];
                                  selectedMedia =
                                      selectedFilesFromUploadedFiles(
                                    selectedUploadedFiles,
                                  );
                                  downloadUrls = (await Future.wait(
                                    selectedMedia.map(
                                      (m) async => await uploadData(
                                          m.storagePath, m.bytes),
                                    ),
                                  ))
                                      .where((u) => u != null)
                                      .map((u) => u!)
                                      .toList();
                                } finally {
                                  _model.isDataUploading_uploadDataSk6 = false;
                                }
                                if (selectedUploadedFiles.length ==
                                        selectedMedia.length &&
                                    downloadUrls.length ==
                                        selectedMedia.length) {
                                  safeSetState(() {
                                    _model.uploadedLocalFile_uploadDataSk6 =
                                        selectedUploadedFiles.first;
                                    _model.uploadedFileUrl_uploadDataSk6 =
                                        downloadUrls.first;
                                  });
                                } else {
                                  safeSetState(() {});
                                  return;
                                }
                              }

                              await widget!.order!.update(createOrderRecordData(
                                status: StatusOrder.on_confirmation,
                                imageCompl:
                                    _model.uploadedFileUrl_uploadDataSk6,
                                completionDateByTheDriver: getCurrentTimestamp,
                              ));

                              await currentUserReference!
                                  .update(createUsersRecordData(
                                currentOrder:
                                    createCurrentOrderStruct(delete: true),
                              ));
                              await actions.toggleRouteTracking(
                                'AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY',
                                false,
                                widget!.order!,
                                orderPageDriverOrderRecord.pointB.latlng!,
                              );
                              triggerPushNotification(
                                notificationTitle:
                                    'Статус заказа изменен на \"Ожидает подтверждения клиента\"',
                                notificationText:
                                    'Если вы не подтвердите вручение в течение 12 часов, заказ будет завершён автоматически.',
                                notificationSound: 'default',
                                userRefs: [
                                  orderPageDriverOrderRecord.userCustomer!
                                ],
                                initialPageName: 'order_Page_Customer',
                                parameterData: {
                                  'index': 1,
                                  'order': widget!.order,
                                },
                              );
                            },
                            text: 'Завершить заказ',
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
                          ),
                        );
                      } else {
                        return Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ].divide(SizedBox(height: 5.0)),
            ),
          ),
        );
      },
    );
  }
}
