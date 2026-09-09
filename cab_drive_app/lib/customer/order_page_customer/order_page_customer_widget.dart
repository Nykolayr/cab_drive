import 'dart:async';

import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:cab_drive/backend/api/app_me_api.dart';
import 'package:cab_drive/backend/api/chat_open.dart';
import 'package:cab_drive/backend/api/file_storage_service.dart';
import 'package:cab_drive/backend/api/order_record_mapper.dart';
import 'package:cab_drive/backend/api/users_record_api.dart';
import 'package:cab_drive/driver/order_page_driver/widgets/images_grid_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '../../driver/order_page_driver/widgets/countdown_or_expired.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/customer/order_menu_p_o_p_u_p/order_menu_p_o_p_u_p_widget.dart';
import '/customer/response/response_widget.dart';
import '/customer/responsed_detail/responsed_detail_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/pages/bottom/create_rewievs/create_rewievs_widget.dart';
import '/pages/bottom/image_view/image_view_widget.dart';
import '/pages/bottom/ratting/ratting_widget.dart';
import '/pages/bottom/text_info/text_info_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'order_page_customer_model.dart';

export 'order_page_customer_model.dart';

class OrderPageCustomerWidget extends StatefulWidget {
  const OrderPageCustomerWidget({
    super.key,
    required this.index,
    required this.order,
  });

  final int? index;
  final DocumentReference? order;

  static String routeName = 'order_Page_Customer';
  static String routePath = '/orderPageCustomer';

  @override
  State<OrderPageCustomerWidget> createState() =>
      _OrderPageCustomerWidgetState();
}

class _OrderPageCustomerWidgetState extends State<OrderPageCustomerWidget> {
  late OrderPageCustomerModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _poll;
  OrderRecord? _order;
  List<ResponsesRecord>? _bids;
  bool _loading = true;
  bool _useFsFallback = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderPageCustomerModel());
    unawaited(_reload());
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _reload());
  }

  Future<void> _reload() async {
    final id = widget.order?.id;
    if (id == null || id.isEmpty) return;
    try {
      final map = await AppMeApi.getOrder(id);
      final bids = await AppMeApi.listBids(id);
      if (!mounted) return;
      if (map == null) {
        setState(() {
          _useFsFallback = false;
          _loading = false;
        });
        return;
      }
      setState(() {
        _order = OrderRecordMapper.fromApi(map, id);
        _bids = bids
            .map((b) => OrderRecordMapper.bidFromApi(b, id))
            .toList();
        _useFsFallback = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _useFsFallback = false;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _model.dispose();

    super.dispose();
  }

  Widget _loadingScaffold() {
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

  Widget _buildBidsList(
    OrderRecord orderPageCustomerOrderRecord,
    List<ResponsesRecord> listViewResponsesRecordList,
  ) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: listViewResponsesRecordList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
      itemBuilder: (context, listViewIndex) {
        final listViewResponsesRecord =
            listViewResponsesRecordList[listViewIndex];
        Future<void> openDetail() async {
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
                    child: ResponsedDetailWidget(
                      order: orderPageCustomerOrderRecord,
                      respDT: listViewResponsesRecord,
                    ),
                  ),
                ),
              );
            },
          ).then((value) => safeSetState(() {}));
        }

        return InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: openDetail,
          child: ResponseWidget(
            key: Key(
                'Key18r_${listViewIndex}_of_${listViewResponsesRecordList.length}'),
            responseDT: listViewResponsesRecord,
            order: orderPageCustomerOrderRecord,
            onAccept: openDetail,
            onReject: () async {
              final orderId = widget.order?.id ?? '';
              final bidId = listViewResponsesRecord.reference.id;
              final ok = await AppMeApi.deleteBid(orderId, bidId);
              if (!ok) {
                // ignore: avoid_print
                print('[order_page] deleteBid failed bid=$bidId');
              }
              await _reload();
              safeSetState(() {});
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_order != null) {
      return _buildLoaded(_order!);
    }
    if (_loading) {
      return _loadingScaffold();
    }
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: const Center(child: Text('Не удалось загрузить заказ')),
    );
  }

  Widget _buildLoaded(OrderRecord orderPageCustomerOrderRecord) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 120.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18.0),
                      bottomRight: Radius.circular(18.0),
                      topLeft: Radius.circular(0.0),
                      topRight: Radius.circular(0.0),
                    ),
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 12.0),
                      child: Container(
                        width: double.infinity,
                        height: 56.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFF4F5F8),
                          borderRadius: BorderRadius.circular(88.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              FlutterFlowIconButton(
                                borderRadius: 88.0,
                                buttonSize: 48.0,
                                fillColor: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                icon: Icon(
                                  FFIcons.kiconStroke,
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  size: 12.0,
                                ),
                                onPressed: () async {
                                  if (widget!.index == 1) {
                                    context.pushNamed(MyOrdersWidget.routeName);

                                    return;
                                  } else {
                                    context.safePop();
                                    return;
                                  }
                                },
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      8.0, 0.0, 0.0, 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(88.0),
                                    ),
                                    child: Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        valueOrDefault<String>(
                                          () {
                                            if (orderPageCustomerOrderRecord
                                                    .status ==
                                                StatusOrder.newOrder) {
                                              return 'Поиск водителя';
                                            } else if (orderPageCustomerOrderRecord
                                                    .status ==
                                                StatusOrder.spec_set) {
                                              return 'Ожидает доставки';
                                            } else if (orderPageCustomerOrderRecord
                                                    .status ==
                                                StatusOrder.place_pickup) {
                                              return 'Водитель ожидает на месте подачи';
                                            } else if (orderPageCustomerOrderRecord
                                                    .status ==
                                                StatusOrder.place_delivery) {
                                              return 'Водитель ожидает на месте выгрузки';
                                            } else if (orderPageCustomerOrderRecord
                                                    .status ==
                                                StatusOrder.at_work) {
                                              return 'В работе';
                                            } else if (orderPageCustomerOrderRecord
                                                    .status ==
                                                StatusOrder.completed) {
                                              return 'Заказ завершен';
                                            } else if (orderPageCustomerOrderRecord
                                                    .status ==
                                                StatusOrder.hidden) {
                                              return 'Заказ скрыт';
                                            } else if (orderPageCustomerOrderRecord
                                                    .status ==
                                                StatusOrder.cancelled) {
                                              return 'Заказ отменен';
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
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if ((orderPageCustomerOrderRecord.status ==
                                      StatusOrder.newOrder) ||
                                  (orderPageCustomerOrderRecord.status ==
                                      StatusOrder.hidden))
                                Builder(
                                  builder: (context) => Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        8.0, 0.0, 0.0, 0.0),
                                    child: FlutterFlowIconButton(
                                      borderColor: Colors.transparent,
                                      borderRadius: 88.0,
                                      buttonSize: 48.0,
                                      fillColor: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      icon: Icon(
                                        Icons.keyboard_control,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        await showAlignedDialog(
                                          context: context,
                                          isGlobal: false,
                                          avoidOverflow: true,
                                          targetAnchor: AlignmentDirectional(
                                                  -1.0, 3.0)
                                              .resolve(
                                                  Directionality.of(context)),
                                          followerAnchor: AlignmentDirectional(
                                                  0.0, 0.0)
                                              .resolve(
                                                  Directionality.of(context)),
                                          builder: (dialogContext) {
                                            return Material(
                                              color: Colors.transparent,
                                              child: WebViewAware(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    FocusScope.of(dialogContext)
                                                        .unfocus();
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                  },
                                                  child: OrderMenuPOPUPWidget(
                                                    order:
                                                        orderPageCustomerOrderRecord,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(0.0),
                          bottomRight: Radius.circular(0.0),
                          topLeft: Radius.circular(18.0),
                          topRight: Radius.circular(18.0),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Builder(
                                builder: (context) {
                                  if (orderPageCustomerOrderRecord.countResp ==
                                      0) {
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 24.0, 16.0, 24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            valueOrDefault<String>(
                                              () {
                                                if (orderPageCustomerOrderRecord
                                                        .status ==
                                                    StatusOrder.newOrder) {
                                                  return 'Ждём предложений от водителей...';
                                                } else if (orderPageCustomerOrderRecord
                                                        .status ==
                                                    StatusOrder.hidden) {
                                                  return 'Заказ скрыт';
                                                } else if (orderPageCustomerOrderRecord
                                                        .status ==
                                                    StatusOrder.cancelled) {
                                                  return 'Заказ отменен';
                                                } else {
                                                  return 'Ждём предложений от водителей...';
                                                }
                                              }(),
                                              'Ждём предложений от водителей...',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 21.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else if ((orderPageCustomerOrderRecord
                                              .status ==
                                          StatusOrder.spec_set) ||
                                      (orderPageCustomerOrderRecord.status ==
                                          StatusOrder.place_pickup) ||
                                      (orderPageCustomerOrderRecord.status ==
                                          StatusOrder.place_delivery) ||
                                      (orderPageCustomerOrderRecord.status ==
                                          StatusOrder.at_work) ||
                                      (orderPageCustomerOrderRecord.status ==
                                          StatusOrder.completed)) {
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 24.0, 16.0, 12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    8.0, 0.0, 0.0, 24.0),
                                            child: Text(
                                              () {
                                                if (orderPageCustomerOrderRecord
                                                        .status ==
                                                    StatusOrder.spec_set) {
                                                  return 'Заказ выполнит';
                                                }
                                                if (orderPageCustomerOrderRecord
                                                        .status ==
                                                    StatusOrder.place_pickup) {
                                                  return 'Ожидание на месте подачи';
                                                }
                                                if (orderPageCustomerOrderRecord
                                                        .status ==
                                                    StatusOrder
                                                        .place_delivery) {
                                                  return 'Ожидание на месте выгрузки';
                                                } else if (orderPageCustomerOrderRecord
                                                        .status ==
                                                    StatusOrder.completed) {
                                                  return 'Заказ выполнил';
                                                } else if (orderPageCustomerOrderRecord
                                                        .status ==
                                                    StatusOrder.at_work) {
                                                  return 'Заказ доставляет';
                                                } else {
                                                  return 'В работе';
                                                }
                                              }(),
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
                                          ),
                                          if (orderPageCustomerOrderRecord
                                                      .status ==
                                                  StatusOrder.place_pickup ||
                                              orderPageCustomerOrderRecord
                                                      .status ==
                                                  StatusOrder.place_delivery)
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0, left: 10),
                                                child: CountdownOrExpired(
                                                  dateUpd:
                                                      orderPageCustomerOrderRecord
                                                          .dateUpd,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                      ),
                                                  expiredStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .error,
                                                      ),
                                                  descriptionTextStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'SF',
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                )),
                                          FutureBuilder<UsersRecord>(
                                            future: UsersRecordApi.getOnce(
                                                orderPageCustomerOrderRecord
                                                    .selectedDriver!),
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

                                              final containerUsersRecord =
                                                  snapshot.data!;

                                              return Container(
                                                decoration: BoxDecoration(),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  8.0,
                                                                  0.0,
                                                                  8.0,
                                                                  14.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0),
                                                              border:
                                                                  Border.all(
                                                                color: Color(
                                                                    0x26A4A6B2),
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0),
                                                              child:
                                                                  Image.network(
                                                                FileStorageService
                                                                    .getImageUrl(
                                                                        containerUsersRecord
                                                                            .photoUrl),
                                                                width: 60.0,
                                                                height: 80.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Flexible(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            2.0),
                                                                    child: Text(
                                                                      containerUsersRecord
                                                                          .displayName,
                                                                      maxLines:
                                                                          1,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'SF',
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      functions.isWithinFiveMinutes(
                                                                              containerUsersRecord.lastOnline!)
                                                                          ? 'В сети '
                                                                          : 'Был(а) в сети ${dateTimeFormat(
                                                                              "relative",
                                                                              containerUsersRecord.lastOnline,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            )}',
                                                                      'В сети ',
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'SF',
                                                                          color:
                                                                              Color(0xFFA4A6B2),
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            0.0),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        if (containerUsersRecord.numberOfReviews !=
                                                                            0)
                                                                          InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
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
                                                                                        child: RattingWidget(
                                                                                          user: containerUsersRecord.reference,
                                                                                          index: 3,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ).then((value) => safeSetState(() {}));
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Container(
                                                                                  height: 30.0,
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
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
                                                                                  height: 30.0,
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
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
                                                                              ].divide(SizedBox(width: 4.0)),
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
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Icon(
                                                                                  FFIcons.kcar01,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 14.0,
                                                                                ),
                                                                                Text(
                                                                                  containerUsersRecord.car.nomer,
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
                                                                              width: 4.0)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              final peer =
                                                                  containerUsersRecord
                                                                      .reference
                                                                      .id;
                                                              final name =
                                                                  '${containerUsersRecord.displayName} ${containerUsersRecord.surname}';
                                                              await openPeerChat(
                                                                context,
                                                                peerUid: peer,
                                                                name: name,
                                                              );
                                                            },
                                                            text: 'Написать',
                                                            options:
                                                                FFButtonOptions(
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
                                                            onPressed:
                                                                () async {
                                                              await launchUrl(
                                                                  Uri(
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
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          if (!orderPageCustomerOrderRecord
                                              .driverReviewed)
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 24.0, 0.0, 0.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 4.0,
                                                      color: Color(0x19000000),
                                                      offset: Offset(
                                                        0.0,
                                                        2.0,
                                                      ),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 24.0, 0.0, 24.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          FlutterFlowIconButton(
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              1,
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
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              2,
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
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              3,
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
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              4,
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
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              5,
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
                                  } else if (orderPageCustomerOrderRecord
                                          .status ==
                                      StatusOrder.on_confirmation) {
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16.0, 24.0, 16.0, 12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 0.0, 0.0, 24.0),
                                            child: Text(
                                              'Подтвердите вручение в течение 12 часов',
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
                                          ),
                                          FutureBuilder<UsersRecord>(
                                            future: UsersRecordApi.getOnce(
                                                orderPageCustomerOrderRecord
                                                    .selectedDriver!),
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

                                              final containerUsersRecord =
                                                  snapshot.data!;

                                              return Container(
                                                decoration: BoxDecoration(),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  8.0,
                                                                  0.0,
                                                                  8.0,
                                                                  14.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0),
                                                              border:
                                                                  Border.all(
                                                                color: Color(
                                                                    0x26A4A6B2),
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0),
                                                              child:
                                                                  Image.network(
                                                                FileStorageService
                                                                    .getImageUrl(
                                                                        containerUsersRecord
                                                                            .photoUrl),
                                                                width: 60.0,
                                                                height: 80.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Flexible(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          14.0,
                                                                          0.0,
                                                                          0.0,
                                                                          0.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            0.0,
                                                                            0.0,
                                                                            2.0),
                                                                    child: Text(
                                                                      containerUsersRecord
                                                                          .displayName,
                                                                      maxLines:
                                                                          1,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .override(
                                                                            fontFamily:
                                                                                'SF',
                                                                            fontSize:
                                                                                16.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    valueOrDefault<
                                                                        String>(
                                                                      functions.isWithinFiveMinutes(
                                                                              containerUsersRecord.lastOnline!)
                                                                          ? 'В сети '
                                                                          : 'Был(а) в сети ${dateTimeFormat(
                                                                              "relative",
                                                                              containerUsersRecord.lastOnline,
                                                                              locale: FFLocalizations.of(context).languageCode,
                                                                            )}',
                                                                      'В сети ',
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .override(
                                                                          fontFamily:
                                                                              'SF',
                                                                          color:
                                                                              Color(0xFFA4A6B2),
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            0.0,
                                                                            8.0,
                                                                            0.0,
                                                                            0.0),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children:
                                                                          [
                                                                        if (containerUsersRecord.numberOfReviews !=
                                                                            0)
                                                                          InkWell(
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            focusColor:
                                                                                Colors.transparent,
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap:
                                                                                () async {
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
                                                                                        child: RattingWidget(
                                                                                          user: containerUsersRecord.reference,
                                                                                          index: 3,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ).then((value) => safeSetState(() {}));
                                                                            },
                                                                            child:
                                                                                Row(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Container(
                                                                                  height: 30.0,
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
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
                                                                                  height: 30.0,
                                                                                  decoration: BoxDecoration(
                                                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      children: [
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
                                                                              ].divide(SizedBox(width: 4.0)),
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
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Icon(
                                                                                  FFIcons.kcar01,
                                                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                                                  size: 14.0,
                                                                                ),
                                                                                Text(
                                                                                  containerUsersRecord.car.nomer,
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
                                                                              width: 4.0)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Expanded(
                                                          child: FFButtonWidget(
                                                            onPressed:
                                                                () async {
                                                              final peer =
                                                                  containerUsersRecord
                                                                      .reference
                                                                      .id;
                                                              final name =
                                                                  '${containerUsersRecord.displayName} ${containerUsersRecord.surname}';
                                                              await openPeerChat(
                                                                context,
                                                                peerUid: peer,
                                                                name: name,
                                                              );
                                                            },
                                                            text: 'Написать',
                                                            options:
                                                                FFButtonOptions(
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
                                                            onPressed:
                                                                () async {
                                                              await launchUrl(
                                                                  Uri(
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
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 12.0, 0.0, 0.0),
                                            child: Hero(
                                              tag: orderPageCustomerOrderRecord
                                                  .imageCompl,
                                              transitionOnUserGestures: true,
                                              child: SizedBox(
                                                height: 150,
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                        .width,
                                                child: ListView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  children:
                                                      orderPageCustomerOrderRecord
                                                          .imageCompl
                                                          .map(
                                                            (e) => Padding(
                                                              padding:
                                                                  EdgeInsetsGeometry
                                                                      .only(
                                                                          right:
                                                                              15),
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  await Navigator
                                                                      .push(
                                                                    context,
                                                                    PageTransition(
                                                                      type: PageTransitionType
                                                                          .fade,
                                                                      child:
                                                                          FlutterFlowExpandedImageView(
                                                                        image:
                                                                            CachedNetworkImage(
                                                                          imageUrl:
                                                                              FileStorageService.getImageUrl(e),
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                        allowRotation:
                                                                            false,
                                                                        tag: orderPageCustomerOrderRecord
                                                                            .imageCompl,
                                                                        useHeroAnimation:
                                                                            true,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: FileStorageService
                                                                        .getImageUrl(
                                                                            e),
                                                                    width: 150,
                                                                    height:
                                                                        150.0,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (!orderPageCustomerOrderRecord
                                              .driverReviewed)
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 24.0, 0.0, 0.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 4.0,
                                                      color: Color(0x19000000),
                                                      offset: Offset(
                                                        0.0,
                                                        2.0,
                                                      ),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          0.0, 24.0, 0.0, 24.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          FlutterFlowIconButton(
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              1,
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
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              2,
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
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              3,
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
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              4,
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
                                                            borderColor: Colors
                                                                .transparent,
                                                            borderRadius: 8.0,
                                                            buttonSize: 55.0,
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
                                                                            CreateRewievsWidget(
                                                                          user:
                                                                              orderPageCustomerOrderRecord.selectedDriver!,
                                                                          order:
                                                                              widget!.order!,
                                                                          rait:
                                                                              5,
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
                                  } else {
                                    return Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 16.0, 24.0, 16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                valueOrDefault<String>(
                                                  () {
                                                    if (orderPageCustomerOrderRecord
                                                            .status ==
                                                        StatusOrder.newOrder) {
                                                      return 'Предложения';
                                                    } else if (orderPageCustomerOrderRecord
                                                            .status ==
                                                        StatusOrder.hidden) {
                                                      return 'Заказ скрыт';
                                                    } else if (orderPageCustomerOrderRecord
                                                            .status ==
                                                        StatusOrder.cancelled) {
                                                      return 'Заказ отменен';
                                                    } else {
                                                      return 'Предложения';
                                                    }
                                                  }(),
                                                  'Предложения',
                                                ),
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
                                              Text(
                                                orderPageCustomerOrderRecord
                                                    .countResp
                                                    .toString(),
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          fontSize: 21.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0.0, 24.0, 0.0, 0.0),
                                            child: _buildBidsList(
                                              orderPageCustomerOrderRecord,
                                              _bids ?? const [],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
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
                                      alignment: AlignmentDirectional(0.0, 1.0),
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 300.0,
                                              child: Builder(
                                                builder: (context) {
                                                  final order =
                                                      orderPageCustomerOrderRecord;
                                                  final showDriver = (order
                                                                  .status ==
                                                              StatusOrder
                                                                  .at_work ||
                                                          order.status ==
                                                              StatusOrder
                                                                  .spec_set) &&
                                                      order.hasDriverLocation();

                                                  return custom_widgets
                                                      .YandexOrderMap(
                                                    width: double.infinity,
                                                    height: 300.0,
                                                    startLatLng:
                                                        order.pointA.latlng!,
                                                    endLatLng:
                                                        order.pointB.latlng!,
                                                    driverLocation:
                                                        order.driverLocation,
                                                    showDriver: showDriver,
                                                    etaText: order.hasTimeLeft()
                                                        ? order.timeLeft
                                                        : null,
                                                    isStatic: true,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              context.pushNamed(
                                                ZakazNaKarteWidget.routeName,
                                                queryParameters: {
                                                  'order': serializeParam(
                                                    widget!.order,
                                                    ParamType.DocumentReference,
                                                  ),
                                                }.withoutNulls,
                                              );
                                            },
                                            text: valueOrDefault<String>(
                                              orderPageCustomerOrderRecord
                                                          .status ==
                                                      StatusOrder.at_work
                                                  ? 'Отследить'
                                                  : 'Заказ на карте',
                                              'Заказ на карте',
                                            ),
                                            options: FFButtonOptions(
                                              width: double.infinity,
                                              height: 35.0,
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                              color: Color(0xD8F4F5F8),
                                              textStyle:
                                                  FlutterFlowTheme.of(context)
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
                                                  BorderRadius.circular(8.0),
                                            ),
                                            showLoadingIndicator: false,
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
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 16.0, 24.0, 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Детали заказа',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'SF',
                                            fontSize: 21.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 12.0, 0.0, 0.0),
                                      child: wrapWithModel(
                                        model: _model.textInfoModel1,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: TextInfoWidget(
                                          tittle: 'Откуда',
                                          pole: orderPageCustomerOrderRecord
                                              .pointA.address,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (orderPageCustomerOrderRecord
                                                .pointA.entrance !=
                                            0)
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0,
                                                      0.0,
                                                      valueOrDefault<double>(
                                                        orderPageCustomerOrderRecord
                                                                        .pointA
                                                                        .flat !=
                                                                    null &&
                                                                orderPageCustomerOrderRecord
                                                                        .pointA
                                                                        .flat !=
                                                                    ''
                                                            ? 7.0
                                                            : 0.0,
                                                        0.0,
                                                      ),
                                                      0.0),
                                              child: wrapWithModel(
                                                model: _model.textInfoModel2,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: TextInfoWidget(
                                                  tittle: 'Подъезд',
                                                  pole:
                                                      orderPageCustomerOrderRecord
                                                          .pointA.entrance
                                                          .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (orderPageCustomerOrderRecord
                                                    .pointA.flat !=
                                                null &&
                                            orderPageCustomerOrderRecord
                                                    .pointA.flat !=
                                                '')
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      valueOrDefault<double>(
                                                        orderPageCustomerOrderRecord
                                                                    .pointA
                                                                    .entrance !=
                                                                0
                                                            ? 7.0
                                                            : 0.0,
                                                        0.0,
                                                      ),
                                                      0.0,
                                                      0.0,
                                                      0.0),
                                              child: wrapWithModel(
                                                model: _model.textInfoModel3,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: TextInfoWidget(
                                                  tittle: 'Кв./офис',
                                                  pole:
                                                      orderPageCustomerOrderRecord
                                                          .pointA.flat,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (orderPageCustomerOrderRecord
                                                .pointA.floor !=
                                            0)
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0,
                                                      0.0,
                                                      valueOrDefault<double>(
                                                        orderPageCustomerOrderRecord
                                                                        .pointA
                                                                        .intercom !=
                                                                    null &&
                                                                orderPageCustomerOrderRecord
                                                                        .pointA
                                                                        .intercom !=
                                                                    ''
                                                            ? 7.0
                                                            : 0.0,
                                                        0.0,
                                                      ),
                                                      0.0),
                                              child: wrapWithModel(
                                                model: _model.textInfoModel4,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: TextInfoWidget(
                                                  tittle: 'Этаж',
                                                  pole:
                                                      orderPageCustomerOrderRecord
                                                          .pointA.floor
                                                          .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (orderPageCustomerOrderRecord
                                                    .pointA.intercom !=
                                                null &&
                                            orderPageCustomerOrderRecord
                                                    .pointA.intercom !=
                                                '')
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      valueOrDefault<double>(
                                                        orderPageCustomerOrderRecord
                                                                    .pointA
                                                                    .floor !=
                                                                0
                                                            ? 7.0
                                                            : 0.0,
                                                        0.0,
                                                      ),
                                                      0.0,
                                                      0.0,
                                                      0.0),
                                              child: wrapWithModel(
                                                model: _model.textInfoModel5,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: TextInfoWidget(
                                                  tittle: 'Домофон',
                                                  pole:
                                                      orderPageCustomerOrderRecord
                                                          .pointA.intercom,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (orderPageCustomerOrderRecord
                                                .pointA.comment !=
                                            null &&
                                        orderPageCustomerOrderRecord
                                                .pointA.comment !=
                                            '')
                                      wrapWithModel(
                                        model: _model.textInfoModel6,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: TextInfoWidget(
                                          tittle: 'Комментарий водителю',
                                          pole: orderPageCustomerOrderRecord
                                              .pointA.comment,
                                        ),
                                      ),
                                    wrapWithModel(
                                      model: _model.textInfoModel7,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
                                        tittle: 'Контакт отправителя',
                                        pole:
                                            '${orderPageCustomerOrderRecord.pointA.sender.phone}, ${orderPageCustomerOrderRecord.pointA.sender.name}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (orderPageCustomerOrderRecord
                                .pointC.address.isNotEmpty)
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      24.0, 16.0, 24.0, 16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      wrapWithModel(
                                        model: TextInfoModel(),
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: TextInfoWidget(
                                          tittle: 'Промежуточная точка',
                                          pole: orderPageCustomerOrderRecord
                                              .pointC.address,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (orderPageCustomerOrderRecord
                                                  .pointC.entrance !=
                                              0)
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0,
                                                        0.0,
                                                        valueOrDefault<double>(
                                                          orderPageCustomerOrderRecord
                                                                          .pointC
                                                                          .flat !=
                                                                      null &&
                                                                  orderPageCustomerOrderRecord
                                                                          .pointC
                                                                          .flat !=
                                                                      ''
                                                              ? 7.0
                                                              : 0.0,
                                                          0.0,
                                                        ),
                                                        0.0),
                                                child: wrapWithModel(
                                                  model: TextInfoModel(),
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: TextInfoWidget(
                                                    tittle: 'Подъезд',
                                                    pole:
                                                        orderPageCustomerOrderRecord
                                                            .pointC.entrance
                                                            .toString(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (orderPageCustomerOrderRecord
                                                      .pointC.flat !=
                                                  null &&
                                              orderPageCustomerOrderRecord
                                                      .pointC.flat !=
                                                  '')
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        valueOrDefault<double>(
                                                          orderPageCustomerOrderRecord
                                                                      .pointC
                                                                      .entrance !=
                                                                  0
                                                              ? 7.0
                                                              : 0.0,
                                                          0.0,
                                                        ),
                                                        0.0,
                                                        0.0,
                                                        0.0),
                                                child: wrapWithModel(
                                                  model: TextInfoModel(),
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: TextInfoWidget(
                                                    tittle: 'Кв./офис',
                                                    pole:
                                                        orderPageCustomerOrderRecord
                                                            .pointC.flat,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (orderPageCustomerOrderRecord
                                                  .pointC.floor !=
                                              0)
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0,
                                                        0.0,
                                                        valueOrDefault<double>(
                                                          orderPageCustomerOrderRecord
                                                                          .pointC
                                                                          .intercom !=
                                                                      null &&
                                                                  orderPageCustomerOrderRecord
                                                                          .pointC
                                                                          .intercom !=
                                                                      ''
                                                              ? 7.0
                                                              : 0.0,
                                                          0.0,
                                                        ),
                                                        0.0),
                                                child: wrapWithModel(
                                                  model: TextInfoModel(),
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: TextInfoWidget(
                                                    tittle: 'Этаж',
                                                    pole:
                                                        orderPageCustomerOrderRecord
                                                            .pointC.floor
                                                            .toString(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (orderPageCustomerOrderRecord
                                                      .pointC.intercom !=
                                                  null &&
                                              orderPageCustomerOrderRecord
                                                      .pointC.intercom !=
                                                  '')
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        valueOrDefault<double>(
                                                          orderPageCustomerOrderRecord
                                                                      .pointC
                                                                      .floor !=
                                                                  0
                                                              ? 7.0
                                                              : 0.0,
                                                          0.0,
                                                        ),
                                                        0.0,
                                                        0.0,
                                                        0.0),
                                                child: wrapWithModel(
                                                  model: TextInfoModel(),
                                                  updateCallback: () =>
                                                      safeSetState(() {}),
                                                  child: TextInfoWidget(
                                                    tittle: 'Домофон',
                                                    pole:
                                                        orderPageCustomerOrderRecord
                                                            .pointC.intercom,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (orderPageCustomerOrderRecord
                                                  .pointC.comment !=
                                              null &&
                                          orderPageCustomerOrderRecord
                                                  .pointC.comment !=
                                              '')
                                        wrapWithModel(
                                          model: TextInfoModel(),
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle: 'Комментарий водителю',
                                            pole: orderPageCustomerOrderRecord
                                                .pointC.comment,
                                          ),
                                        ),
                                      wrapWithModel(
                                        model: TextInfoModel(),
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: TextInfoWidget(
                                          tittle: 'Контакт отправителя',
                                          pole:
                                              '${orderPageCustomerOrderRecord.pointC.sender.phone}, ${orderPageCustomerOrderRecord.pointC.sender.name}',
                                        ),
                                      ),
                                    ],
                                  ),
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
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 16.0, 24.0, 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    wrapWithModel(
                                      model: _model.textInfoModel8,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
                                        tittle: 'Куда',
                                        pole: orderPageCustomerOrderRecord
                                            .pointB.address,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (orderPageCustomerOrderRecord
                                                .pointB.entrance !=
                                            0)
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0,
                                                      0.0,
                                                      valueOrDefault<double>(
                                                        orderPageCustomerOrderRecord
                                                                        .pointB
                                                                        .flat !=
                                                                    null &&
                                                                orderPageCustomerOrderRecord
                                                                        .pointB
                                                                        .flat !=
                                                                    ''
                                                            ? 7.0
                                                            : 0.0,
                                                        0.0,
                                                      ),
                                                      0.0),
                                              child: wrapWithModel(
                                                model: _model.textInfoModel9,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: TextInfoWidget(
                                                  tittle: 'Подъезд',
                                                  pole:
                                                      orderPageCustomerOrderRecord
                                                          .pointB.entrance
                                                          .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (orderPageCustomerOrderRecord
                                                    .pointB.flat !=
                                                null &&
                                            orderPageCustomerOrderRecord
                                                    .pointB.flat !=
                                                '')
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      valueOrDefault<double>(
                                                        orderPageCustomerOrderRecord
                                                                    .pointB
                                                                    .entrance !=
                                                                0
                                                            ? 7.0
                                                            : 0.0,
                                                        0.0,
                                                      ),
                                                      0.0,
                                                      0.0,
                                                      0.0),
                                              child: wrapWithModel(
                                                model: _model.textInfoModel10,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: TextInfoWidget(
                                                  tittle: 'Кв./офис',
                                                  pole:
                                                      orderPageCustomerOrderRecord
                                                          .pointB.flat,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (orderPageCustomerOrderRecord
                                                .pointB.floor !=
                                            0)
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0,
                                                      0.0,
                                                      valueOrDefault<double>(
                                                        orderPageCustomerOrderRecord
                                                                        .pointB
                                                                        .intercom !=
                                                                    null &&
                                                                orderPageCustomerOrderRecord
                                                                        .pointB
                                                                        .intercom !=
                                                                    ''
                                                            ? 7.0
                                                            : 0.0,
                                                        0.0,
                                                      ),
                                                      0.0),
                                              child: wrapWithModel(
                                                model: _model.textInfoModel11,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: TextInfoWidget(
                                                  tittle: 'Этаж',
                                                  pole:
                                                      orderPageCustomerOrderRecord
                                                          .pointB.floor
                                                          .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        if (orderPageCustomerOrderRecord
                                                    .pointB.intercom !=
                                                null &&
                                            orderPageCustomerOrderRecord
                                                    .pointB.intercom !=
                                                '')
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      valueOrDefault<double>(
                                                        orderPageCustomerOrderRecord
                                                                    .pointB
                                                                    .floor !=
                                                                0
                                                            ? 7.0
                                                            : 0.0,
                                                        0.0,
                                                      ),
                                                      0.0,
                                                      0.0,
                                                      0.0),
                                              child: wrapWithModel(
                                                model: _model.textInfoModel12,
                                                updateCallback: () =>
                                                    safeSetState(() {}),
                                                child: TextInfoWidget(
                                                  tittle: 'Домофон',
                                                  pole:
                                                      orderPageCustomerOrderRecord
                                                          .pointB.intercom,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (orderPageCustomerOrderRecord
                                                .pointB.comment !=
                                            null &&
                                        orderPageCustomerOrderRecord
                                                .pointB.comment !=
                                            '')
                                      wrapWithModel(
                                        model: _model.textInfoModel13,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: TextInfoWidget(
                                          tittle: 'Комментарий водителю',
                                          pole: orderPageCustomerOrderRecord
                                              .pointB.comment,
                                        ),
                                      ),
                                    wrapWithModel(
                                      model: _model.textInfoModel14,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
                                        tittle: 'Контакт отправителя',
                                        pole:
                                            '${orderPageCustomerOrderRecord.pointB.sender.phone}, ${orderPageCustomerOrderRecord.pointB.sender.name}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(0.0),
                                  bottomRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(18.0),
                                  topRight: Radius.circular(18.0),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    24.0, 16.0, 24.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextInfoWidget(
                                      tittle: 'Ожидаемая стоимость',
                                      pole:
                                          '${orderPageCustomerOrderRecord.budget.toString()} ₽',
                                    ),
                                    if ((orderPageCustomerOrderRecord.status ==
                                            StatusOrder.spec_set) ||
                                        (orderPageCustomerOrderRecord.status ==
                                            StatusOrder.at_work) ||
                                        (orderPageCustomerOrderRecord.status ==
                                            StatusOrder.completed) ||
                                        (orderPageCustomerOrderRecord.status ==
                                            StatusOrder.on_confirmation))
                                      TextInfoWidget(
                                        tittle: 'Итоговая стоимость доставки',
                                        pole:
                                            '${orderPageCustomerOrderRecord.currentPrice.toString()} ₽',
                                      ),
                                    TextInfoWidget(
                                      tittle: 'Способ оплаты',
                                      pole: orderPageCustomerOrderRecord
                                                  .payMethod ==
                                              PayMethod.card
                                          ? 'Оплата картой'
                                          : 'Оплата наличными',
                                    ),
                                    TextInfoWidget(
                                      tittle: 'Подача',
                                      pole: orderPageCustomerOrderRecord
                                                  .supply ==
                                              1
                                          ? 'В ближайшее время'
                                          : valueOrDefault<String>(
                                              dateTimeFormat(
                                                "MMMMEEEEd HH:mm",
                                                orderPageCustomerOrderRecord
                                                    .dateTime,
                                                locale:
                                                    FFLocalizations.of(context)
                                                        .languageCode,
                                              ),
                                              'MMMMEEEEd HH:mm',
                                            ),
                                    ),
                                    TextInfoWidget(
                                      tittle: 'Время и дистанция',
                                      pole:
                                          '${orderPageCustomerOrderRecord.time}, ${orderPageCustomerOrderRecord.distanceStr}',
                                    ),
                                    TextInfoWidget(
                                      tittle: 'Авто',
                                      pole: () {
                                        if (orderPageCustomerOrderRecord.car ==
                                            Car.largus) {
                                          return 'Мини S';
                                        } else if (orderPageCustomerOrderRecord
                                                .car ==
                                            Car.largusTermo) {
                                          return 'Термобудка S/M';
                                        } else {
                                          return 'МиниПлюс/M';
                                        }
                                      }(),
                                    ),
                                    TextInfoWidget(
                                      tittle: 'Грузчики',
                                      pole: () {
                                        if (orderPageCustomerOrderRecord
                                                .movers ==
                                            1) {
                                          return 'Помощь водителя (1)';
                                        } else if (orderPageCustomerOrderRecord
                                                .movers ==
                                            2) {
                                          return 'Помощь двух грузчиков';
                                        } else {
                                          return 'Помощь не нужна';
                                        }
                                      }(),
                                    ),
                                    TextInfoWidget(
                                      tittle: 'Описание груза',
                                      pole: orderPageCustomerOrderRecord
                                          .description,
                                    ),
                                    if (orderPageCustomerOrderRecord
                                        .images.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
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
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondaryText,
                                                    fontSize: 16.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 12.0, 0.0, 0.0),
                                              child: Builder(
                                                builder: (context) {
                                                  final imagesCargo =
                                                      orderPageCustomerOrderRecord
                                                          .images
                                                          .toList();

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
                                                            isScrollControlled:
                                                                true,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
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
                                                                  child:
                                                                      Padding(
                                                                    padding: MediaQuery
                                                                        .viewInsetsOf(
                                                                            context),
                                                                    child:
                                                                        ImageViewWidget(
                                                                      indexCurrent:
                                                                          imagesCargoIndex,
                                                                      alllistImage:
                                                                          orderPageCustomerOrderRecord
                                                                              .images,
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
                                                          child: Image.network(
                                                            FileStorageService
                                                                .getImageUrl(
                                                                    imagesCargoItem),
                                                            width:
                                                                double.infinity,
                                                            height: 120.0,
                                                            fit: BoxFit.cover,
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
                                  ].addToEnd(SizedBox(height: 50.0)),
                                ),
                              ),
                            ),
                          ].divide(SizedBox(height: 5.0)),
                        ),
                      ),
                    ),
                  ),
                ),
                if (orderPageCustomerOrderRecord.status ==
                    StatusOrder.on_confirmation)
                  Container(
                    width: double.infinity,
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
                      padding:
                          EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 35.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          final orderId = widget!.order!.id;
                          final apiOk =
                              await AppMeApi.completeOrder(orderId) != null;
                          if (!apiOk) {
                            await widget!.order!.update(createOrderRecordData(
                              status: StatusOrder.completed,
                            ));
                            if (orderPageCustomerOrderRecord.payMethod ==
                                PayMethod.card) {
                              await orderPageCustomerOrderRecord.selectedDriver!
                                  .update({
                                ...mapToFirestore(
                                  {
                                    'balance': FieldValue.increment(
                                        (orderPageCustomerOrderRecord
                                                    .currentPrice
                                                    .toDouble() /
                                                100) *
                                            currentUserDocument!
                                                .commissionPercent),
                                  },
                                ),
                              });

                              createPayOrderRecordData(
                                isPaid: false,
                                amountInCop: ((orderPageCustomerOrderRecord
                                                .currentPrice
                                                .toDouble() /
                                            100) *
                                        currentUserDocument!.commissionPercent)
                                    .toInt(),
                                user: currentUserReference,
                                paymentType: PaymentType.finishedMyShift,
                              );
                            } else {
                              final driver = (UsersRecord.fromSnapshot(
                                  await orderPageCustomerOrderRecord
                                      .selectedDriver!
                                      .get()));
                              await orderPageCustomerOrderRecord.selectedDriver!
                                  .update(createUsersRecordData(
                                currentCommision: driver.currentCommision +
                                    ((orderPageCustomerOrderRecord.currentPrice
                                                .toDouble() /
                                            100) *
                                        currentUserDocument!.commissionPercent),
                              ));
                            }
                          }
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
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'SF',
                                    color: FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    ),
                  ),
              ].divide(SizedBox(height: 5.0)),
            ),
          ),
        );
  }
}
