import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/customer/order_menu_p_o_p_u_p/order_menu_p_o_p_u_p_widget.dart';
import '/customer/response/response_widget.dart';
import '/customer/responsed_detail/responsed_detail_widget.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/create_rewievs/create_rewievs_widget.dart';
import '/pages/bottom/image_view/image_view_widget.dart';
import '/pages/bottom/ratting/ratting_widget.dart';
import '/pages/bottom/text_info/text_info_widget.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderPageCustomerModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OrderRecord>(
      stream: OrderRecord.getDocument(widget.order!),
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

        final orderPageCustomerOrderRecord = snapshot.data!;

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
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18.0),
                      bottomRight: Radius.circular(18.0),
                    ),
                  ),
                  child: Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          12.0, 0.0, 12.0, 12.0),
                      child: Container(
                        width: double.infinity,
                        height: 56.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F8),
                          borderRadius: BorderRadius.circular(88.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
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
                                  if (widget.index == 1) {
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(
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
                                      alignment:
                                          const AlignmentDirectional(0.0, 0.0),
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
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
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
                                          targetAnchor:
                                              const AlignmentDirectional(
                                                      -1.0, 1.0)
                                                  .resolve(Directionality.of(
                                                      context)),
                                          followerAnchor:
                                              const AlignmentDirectional(
                                                      0.0, 0.0)
                                                  .resolve(Directionality.of(
                                                      context)),
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
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
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
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
                                          StatusOrder.at_work) ||
                                      (orderPageCustomerOrderRecord.status ==
                                          StatusOrder.completed)) {
                                    return Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 24.0, 16.0, 12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(8.0, 0.0, 0.0, 24.0),
                                            child: Text(
                                              () {
                                                if (orderPageCustomerOrderRecord
                                                        .status ==
                                                    StatusOrder.spec_set) {
                                                  return 'Заказ выполнит';
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
                                          FutureBuilder<UsersRecord>(
                                            future: UsersRecord.getDocumentOnce(
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
                                                decoration:
                                                    const BoxDecoration(),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(8.0,
                                                              0.0, 8.0, 14.0),
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
                                                                color: const Color(
                                                                    0x26A4A6B2),
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0),
                                                              child: custom_widgets
                                                                  .UserAvatarImage(
                                                                imageUrl:
                                                                    containerUsersRecord
                                                                        .photoUrl,
                                                                width: 60.0,
                                                                height: 80.0,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12.0),
                                                              ),
                                                            ),
                                                          ),
                                                          Flexible(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
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
                                                                    padding: const EdgeInsetsDirectional
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
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
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
                                                                              const Color(0xFFA4A6B2),
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0.0,
                                                                        8.0,
                                                                        0.0,
                                                                        0.0),
                                                                    child: Wrap(
                                                                      spacing:
                                                                          4.0,
                                                                      runSpacing:
                                                                          4.0,
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
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
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
                                                                                                color: const Color(0xFFA4A6B2),
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                              ),
                                                                                        ),
                                                                                      ].divide(const SizedBox(width: 6.0)),
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
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
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
                                                                                                color: const Color(0xFFA4A6B2),
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                              ),
                                                                                        ),
                                                                                      ].divide(const SizedBox(width: 6.0)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ].divide(const SizedBox(width: 4.0)),
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
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
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
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'SF',
                                                                                        color: const Color(0xFFA4A6B2),
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                      ),
                                                                                ),
                                                                              ].divide(const SizedBox(width: 6.0)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ].divide(const SizedBox(
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
                                                              if (_model
                                                                  .mychats!
                                                                  .where((e) => e
                                                                      .users
                                                                      .contains(
                                                                          containerUsersRecord
                                                                              .reference))
                                                                  .toList()
                                                                  .isNotEmpty) {
                                                                context
                                                                    .pushNamed(
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

                                                                context
                                                                    .pushNamed(
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
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                              iconPadding:
                                                                  const EdgeInsetsDirectional
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
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                              iconPadding:
                                                                  const EdgeInsetsDirectional
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
                                                      ].divide(const SizedBox(
                                                          width: 7.0)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          if (!orderPageCustomerOrderRecord
                                              .driverReviewed)
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 24.0, 0.0, 0.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  boxShadow: [
                                                    const BoxShadow(
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
                                                  padding:
                                                      const EdgeInsetsDirectional
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              16.0, 24.0, 16.0, 12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 0.0, 0.0, 24.0),
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
                                            future: UsersRecord.getDocumentOnce(
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
                                                decoration:
                                                    const BoxDecoration(),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(8.0,
                                                              0.0, 8.0, 14.0),
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
                                                                color: const Color(
                                                                    0x26A4A6B2),
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0),
                                                              child: custom_widgets
                                                                  .UserAvatarImage(
                                                                imageUrl:
                                                                    containerUsersRecord
                                                                        .photoUrl,
                                                                width: 60.0,
                                                                height: 80.0,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12.0),
                                                              ),
                                                            ),
                                                          ),
                                                          Flexible(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsetsDirectional
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
                                                                    padding: const EdgeInsetsDirectional
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
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
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
                                                                              const Color(0xFFA4A6B2),
                                                                          fontSize:
                                                                              14.0,
                                                                          letterSpacing:
                                                                              0.0,
                                                                        ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0.0,
                                                                        8.0,
                                                                        0.0,
                                                                        0.0),
                                                                    child: Wrap(
                                                                      spacing:
                                                                          4.0,
                                                                      runSpacing:
                                                                          4.0,
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
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
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
                                                                                                color: const Color(0xFFA4A6B2),
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                              ),
                                                                                        ),
                                                                                      ].divide(const SizedBox(width: 6.0)),
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
                                                                                    padding: const EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
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
                                                                                                color: const Color(0xFFA4A6B2),
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                              ),
                                                                                        ),
                                                                                      ].divide(const SizedBox(width: 6.0)),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ].divide(const SizedBox(width: 4.0)),
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
                                                                            padding: const EdgeInsetsDirectional.fromSTEB(
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
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'SF',
                                                                                        color: const Color(0xFFA4A6B2),
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.w500,
                                                                                      ),
                                                                                ),
                                                                              ].divide(const SizedBox(width: 6.0)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ].divide(const SizedBox(
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
                                                              var _shouldSetState =
                                                                  false;
                                                              _model.mychats2 =
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
                                                              if (_model
                                                                  .mychats2!
                                                                  .where((e) => e
                                                                      .users
                                                                      .contains(
                                                                          containerUsersRecord
                                                                              .reference))
                                                                  .toList()
                                                                  .isNotEmpty) {
                                                                context
                                                                    .pushNamed(
                                                                  ChatWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'chat':
                                                                        serializeParam(
                                                                      _model
                                                                          .mychats2
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
                                                                _model.newchat2 =
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

                                                                context
                                                                    .pushNamed(
                                                                  ChatWidget
                                                                      .routeName,
                                                                  queryParameters:
                                                                      {
                                                                    'chat':
                                                                        serializeParam(
                                                                      _model
                                                                          .newchat2
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
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                              iconPadding:
                                                                  const EdgeInsetsDirectional
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
                                                                  const EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                      0.0,
                                                                      0.0,
                                                                      0.0,
                                                                      0.0),
                                                              iconPadding:
                                                                  const EdgeInsetsDirectional
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
                                                      ].divide(const SizedBox(
                                                          width: 7.0)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                await Navigator.push(
                                                  context,
                                                  PageTransition(
                                                    type:
                                                        PageTransitionType.fade,
                                                    child:
                                                        FlutterFlowExpandedImageView(
                                                      image: Image.network(
                                                        orderPageCustomerOrderRecord
                                                            .imageCompl,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      allowRotation: false,
                                                      tag:
                                                          orderPageCustomerOrderRecord
                                                              .imageCompl,
                                                      useHeroAnimation: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Hero(
                                                tag:
                                                    orderPageCustomerOrderRecord
                                                        .imageCompl,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: Image.network(
                                                    orderPageCustomerOrderRecord
                                                        .imageCompl,
                                                    width: double.infinity,
                                                    height: 150.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (!orderPageCustomerOrderRecord
                                              .driverReviewed)
                                            Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 24.0, 0.0, 0.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  boxShadow: [
                                                    const BoxShadow(
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
                                                  padding:
                                                      const EdgeInsetsDirectional
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                                            icon: const Icon(
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
                                                                              widget.order!,
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
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
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
                                            padding: const EdgeInsetsDirectional
                                                .fromSTEB(0.0, 24.0, 0.0, 0.0),
                                            child: StreamBuilder<
                                                List<ResponsesRecord>>(
                                              stream: queryResponsesRecord(
                                                parent: widget.order,
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
                                                    listViewResponsesRecordList =
                                                    snapshot.data!;

                                                return ListView.separated(
                                                  padding: EdgeInsets.zero,
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount:
                                                      listViewResponsesRecordList
                                                          .length,
                                                  separatorBuilder: (_, __) =>
                                                      const SizedBox(
                                                          height: 16.0),
                                                  itemBuilder:
                                                      (context, listViewIndex) {
                                                    final listViewResponsesRecord =
                                                        listViewResponsesRecordList[
                                                            listViewIndex];
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
                                                                child: Padding(
                                                                  padding: MediaQuery
                                                                      .viewInsetsOf(
                                                                          context),
                                                                  child:
                                                                      ResponsedDetailWidget(
                                                                    order:
                                                                        orderPageCustomerOrderRecord,
                                                                    respDT:
                                                                        listViewResponsesRecord,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).then((value) =>
                                                            safeSetState(
                                                                () {}));
                                                      },
                                                      child: ResponseWidget(
                                                        key: Key(
                                                            'Key18r_${listViewIndex}_of_${listViewResponsesRecordList.length}'),
                                                        responseDT:
                                                            listViewResponsesRecord,
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
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
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Stack(
                                      alignment:
                                          const AlignmentDirectional(0.0, 1.0),
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Container(
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
                                                    isStatic: true,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: FFButtonWidget(
                                            onPressed: () async {
                                              context.pushNamed(
                                                ZakazNaKarteWidget.routeName,
                                                queryParameters: {
                                                  'order': serializeParam(
                                                    widget.order,
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
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      16.0, 0.0, 16.0, 0.0),
                                              iconPadding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      0.0, 0.0, 0.0, 0.0),
                                              color: const Color(0xD8F4F5F8),
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
                                padding: const EdgeInsetsDirectional.fromSTEB(
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
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
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
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
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
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18.0),
                                  topRight: Radius.circular(18.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24.0, 16.0, 24.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    wrapWithModel(
                                      model: _model.textInfoModel15,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
                                        tittle: 'Ожидаемая стоимость',
                                        pole:
                                            '${orderPageCustomerOrderRecord.budget.toString()} ₽',
                                      ),
                                    ),
                                    if ((orderPageCustomerOrderRecord.status ==
                                            StatusOrder.spec_set) ||
                                        (orderPageCustomerOrderRecord.status ==
                                            StatusOrder.at_work) ||
                                        (orderPageCustomerOrderRecord.status ==
                                            StatusOrder.completed) ||
                                        (orderPageCustomerOrderRecord.status ==
                                            StatusOrder.on_confirmation))
                                      wrapWithModel(
                                        model: _model.textInfoModel16,
                                        updateCallback: () =>
                                            safeSetState(() {}),
                                        child: TextInfoWidget(
                                          tittle: 'Итоговая стоимость доставки',
                                          pole:
                                              '${orderPageCustomerOrderRecord.currentPrice.toString()} ₽',
                                        ),
                                      ),
                                    wrapWithModel(
                                      model: _model.textInfoModel17,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
                                        tittle: 'Способ оплаты',
                                        pole: orderPageCustomerOrderRecord
                                                    .payMethod ==
                                                PayMethod.card
                                            ? 'Оплата картой'
                                            : 'Оплата наличными',
                                      ),
                                    ),
                                    wrapWithModel(
                                      model: _model.textInfoModel18,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
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
                                                  locale: FFLocalizations.of(
                                                          context)
                                                      .languageCode,
                                                ),
                                                'MMMMEEEEd HH:mm',
                                              ),
                                      ),
                                    ),
                                    wrapWithModel(
                                      model: _model.textInfoModel19,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
                                        tittle: 'Время и дистанция',
                                        pole:
                                            '${orderPageCustomerOrderRecord.time}, ${orderPageCustomerOrderRecord.distance}',
                                      ),
                                    ),
                                    wrapWithModel(
                                      model: _model.textInfoModel20,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
                                        tittle: 'Авто',
                                        pole: () {
                                          if (orderPageCustomerOrderRecord
                                                  .car ==
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
                                    ),
                                    wrapWithModel(
                                      model: _model.textInfoModel21,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
                                        tittle: 'Грузчики',
                                        pole: () {
                                          if (orderPageCustomerOrderRecord
                                                  .movers ==
                                              1) {
                                            return 'Помощь водителя';
                                          } else if (orderPageCustomerOrderRecord
                                                  .movers ==
                                              2) {
                                            return 'Помощь двух грузчиков';
                                          } else {
                                            return 'Помощь не нужна';
                                          }
                                        }(),
                                      ),
                                    ),
                                    wrapWithModel(
                                      model: _model.textInfoModel22,
                                      updateCallback: () => safeSetState(() {}),
                                      child: TextInfoWidget(
                                        tittle: 'Описание груза',
                                        pole: orderPageCustomerOrderRecord
                                            .description,
                                      ),
                                    ),
                                    if (orderPageCustomerOrderRecord
                                        .images.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 16.0, 0.0, 0.0),
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
                                              padding:
                                                  const EdgeInsetsDirectional
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
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                                            imagesCargoItem,
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
                                  ].addToEnd(const SizedBox(height: 50.0)),
                                ),
                              ),
                            ),
                          ].divide(const SizedBox(height: 5.0)),
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
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18.0),
                        topRight: Radius.circular(18.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          8.0, 8.0, 8.0, 35.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          await widget.order!.update(createOrderRecordData(
                            status: StatusOrder.completed,
                          ));
                          if (orderPageCustomerOrderRecord.payMethod ==
                              PayMethod.card) {
                            await orderPageCustomerOrderRecord.selectedDriver!
                                .update({
                              ...mapToFirestore(
                                {
                                  'balance': FieldValue.increment(
                                      orderPageCustomerOrderRecord.currentPrice
                                              .toDouble() *
                                          0.85),
                                },
                              ),
                            });
                          } else {
                            await orderPageCustomerOrderRecord.selectedDriver!
                                .update(createUsersRecordData(
                              currentCommision: orderPageCustomerOrderRecord
                                      .currentPrice
                                      .toDouble() *
                                  0.15,
                            ));
                          }
                        },
                        text: 'Завершить заказ',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
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
              ].divide(const SizedBox(height: 5.0)),
            ),
          ),
        );
      },
    );
  }
}
