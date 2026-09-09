import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/chat_open.dart';
import '/backend/api/file_storage_service.dart';
import '/backend/api/users_record_api.dart';
import '/backend/backend.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/enums/enums.dart';
import '/customer/pay_init/pay_init_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/ratting/ratting_widget.dart';
import 'dart:ui';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'responsed_detail_model.dart';
export 'responsed_detail_model.dart';

class ResponsedDetailWidget extends StatefulWidget {
  const ResponsedDetailWidget({
    super.key,
    required this.order,
    required this.respDT,
  });

  final OrderRecord? order;
  final ResponsesRecord? respDT;

  @override
  State<ResponsedDetailWidget> createState() => _ResponsedDetailWidgetState();
}

class _ResponsedDetailWidgetState extends State<ResponsedDetailWidget> {
  late ResponsedDetailModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResponsedDetailModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (widget!.respDT!.viewed) {
        return;
      }

      await widget!.respDT!.reference.update(createResponsesRecordData(
        viewed: true,
      ));
      return;
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: FutureBuilder<UsersRecord>(
        future: UsersRecordApi.getOnce(widget!.respDT!.userDriver!),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    padding:
                        EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Предложение',
                          textAlign: TextAlign.center,
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
                          hoverIconColor:
                              FlutterFlowTheme.of(context).primaryText,
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
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 24.0, 0.0, 24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 0.0, 24.0, 9.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: Color(0x26A4A6B2),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              child: Image.network(
                                                FileStorageService.getImageUrl(containerUsersRecord.photoUrl),
                                                width: 60.0,
                                                height: 80.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      14.0, 0.0, 0.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    containerUsersRecord
                                                        .displayName,
                                                    maxLines: 2,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                  Text(
                                                    valueOrDefault<String>(
                                                      functions.isWithinFiveMinutes(
                                                              containerUsersRecord
                                                                  .lastOnline!)
                                                          ? 'В сети '
                                                          : 'Был(а) в сети ${dateTimeFormat(
                                                              "relative",
                                                              containerUsersRecord
                                                                  .lastOnline,
                                                              locale: FFLocalizations
                                                                      .of(context)
                                                                  .languageCode,
                                                            )}',
                                                      'В сети ',
                                                    ),
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          color:
                                                              Color(0xFFA4A6B2),
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 8.0,
                                                                0.0, 0.0),
                                                    child: Container(
                                                      height: 30.0,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .primaryBackground,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    10.0,
                                                                    4.0,
                                                                    10.0,
                                                                    4.0),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              FFIcons.kcar01,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryText,
                                                              size: 14.0,
                                                            ),
                                                            Text(
                                                              () {
                                                                if (containerUsersRecord
                                                                        .car
                                                                        .mark ==
                                                                    Car
                                                                        .largus) {
                                                                  return 'Largus';
                                                                } else if (containerUsersRecord
                                                                        .car
                                                                        .mark ==
                                                                    Car.largusTermo) {
                                                                  return 'Largus с термобудкой';
                                                                } else {
                                                                  return 'Fiat Doblò';
                                                                }
                                                              }(),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'SF',
                                                                    color: Color(
                                                                        0xFFA4A6B2),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 6.0)),
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
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          24.0, 0.0, 24.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 89.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF4F5F8),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(12.0),
                                                  bottomRight:
                                                      Radius.circular(4.0),
                                                  topLeft:
                                                      Radius.circular(12.0),
                                                  topRight:
                                                      Radius.circular(4.0),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FFIcons.kcheckVerified03,
                                                    color: Color(0xFF31B100),
                                                    size: 20.0,
                                                  ),
                                                  Text(
                                                    'Документы\nпроверены',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ].divide(SizedBox(height: 5.0)),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
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
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: RattingWidget(
                                                          user:
                                                              containerUsersRecord
                                                                  .reference,
                                                          index: 3,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Container(
                                                height: 89.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF4F5F8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      valueOrDefault<String>(
                                                        formatNumber(
                                                          containerUsersRecord
                                                              .averageRating,
                                                          formatType:
                                                              FormatType.custom,
                                                          format: '0.0',
                                                          locale: '',
                                                        ),
                                                        '0',
                                                      ),
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'SF',
                                                            fontSize: 18.0,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                    Text(
                                                      'Рейтинг\nводителя',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: FlutterFlowTheme
                                                              .of(context)
                                                          .bodyMedium
                                                          .override(
                                                            fontFamily: 'SF',
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondaryText,
                                                            letterSpacing: 0.0,
                                                          ),
                                                    ),
                                                  ].divide(
                                                      SizedBox(height: 5.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
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
                                                      child: Padding(
                                                        padding: MediaQuery
                                                            .viewInsetsOf(
                                                                context),
                                                        child: RattingWidget(
                                                          user:
                                                              containerUsersRecord
                                                                  .reference,
                                                          index: 3,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ).then((value) =>
                                                    safeSetState(() {}));
                                              },
                                              child: Container(
                                                height: 89.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF4F5F8),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(4.0),
                                                    bottomRight:
                                                        Radius.circular(12.0),
                                                    topLeft:
                                                        Radius.circular(4.0),
                                                    topRight:
                                                        Radius.circular(12.0),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          12.0, 0.0, 12.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        valueOrDefault<String>(
                                                          containerUsersRecord
                                                              .numberOfReviews
                                                              .toString(),
                                                          '0',
                                                        ),
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .bodyMedium
                                                            .override(
                                                              fontFamily: 'SF',
                                                              fontSize: 18.0,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                      Text(
                                                        functions.getReviewString(
                                                            containerUsersRecord
                                                                .numberOfReviews),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  fontFamily:
                                                                      'SF',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(height: 5.0)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 5.0)),
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
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget!.respDT!.price >
                                        widget!.order!.budget)
                                      Padding(
                                        padding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 16.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CupertinoSwitch(
                                              value: _model
                                                  .agreedToIncreaseBudget,
                                              onChanged: (newValue) async {
                                                HapticFeedback.mediumImpact();
                                                safeSetState(() => _model
                                                        .agreedToIncreaseBudget =
                                                    newValue);
                                              },
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .tertiary,
                                              trackColor: Color(0xFFF4F5F8),
                                              thumbColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        12.0, 0.0, 0.0, 0.0),
                                                child: Text(
                                                  'Специалист согласен на выполнение, если вы увеличите бюджет до ${widget!.respDT!.price} ₽',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        color: FlutterFlowTheme
                                                                .of(context)
                                                            .tertiary,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF4F5F8),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(4.0),
                                          bottomRight: Radius.circular(16.0),
                                          topLeft: Radius.circular(16.0),
                                          topRight: Radius.circular(16.0),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 21.0, 15.0, 24.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 4.0),
                                              child: Text(
                                                'Стоимость ${widget!.respDT?.price?.toString()} ₽',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional
                                                  .fromSTEB(
                                                      0.0, 0.0, 0.0, 15.0),
                                              child: Text(
                                                'Буду у вас через ~ ${widget!.respDT?.time}',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'SF',
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            ),
                                            Text(
                                              widget!.respDT!.text,
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'SF',
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 12.0, 0.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: FFButtonWidget(
                                              onPressed: () async {
                                                await openPeerChat(
                                                  context,
                                                  peerUid: containerUsersRecord
                                                      .reference.id,
                                                  name:
                                                      '${containerUsersRecord.displayName} ${containerUsersRecord.surname}',
                                                );
                                              },
                                              text: 'Написать',
                                              options: FFButtonOptions(
                                                height: 45.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        40.0, 0.0, 40.0, 0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily: 'SF',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
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
                                                  path: containerUsersRecord
                                                      .phoneNumber,
                                                ));
                                              },
                                              text: 'Позвонить',
                                              options: FFButtonOptions(
                                                height: 45.0,
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        40.0, 0.0, 40.0, 0.0),
                                                iconPadding:
                                                    EdgeInsetsDirectional
                                                        .fromSTEB(
                                                            0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryBackground,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .override(
                                                          fontFamily: 'SF',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
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
                              ),
                            ),
                          ].divide(SizedBox(height: 5.0)),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget!.order?.status == StatusOrder.newOrder)
                  Builder(builder: (context) {
                    final bool budgetIncreaseRequired =
                        widget!.respDT!.price > widget!.order!.budget;
                    final bool selectEnabled = !budgetIncreaseRequired ||
                        _model.agreedToIncreaseBudget;
                    return Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(0.0),
                        topLeft: Radius.circular(5.0),
                        topRight: Radius.circular(5.0),
                      ),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 35.0),
                      child: FFButtonWidget(
                        onPressed: !selectEnabled ? null : () async {
                          if (widget!.order?.payMethod == PayMethod.cahs) {
                            final ok = await AppMeApi.acceptBid(
                              widget!.order!.reference.id,
                              driverUid: containerUsersRecord.reference.id,
                              price: widget!.respDT?.price,
                              commissionPercent:
                                  containerUsersRecord.commissionPercent,
                            );
                            if (!ok) {
                              await widget!.order!.reference
                                  .update(createOrderRecordData(
                                selectedDriver: containerUsersRecord.reference,
                                status: StatusOrder.spec_set,
                                commissionPercent: containerUsersRecord
                                    .commissionPercent
                                    .toInt(),
                                currentPrice: widget!.respDT?.price,
                              ));
                              try {
                                await containerUsersRecord.reference.update({
                                  'active_orders_queue': FieldValue.arrayUnion(
                                      [widget!.order!.reference]),
                                });
                              } catch (e) {
                                print(
                                    '[responsed_detail.assign] queue ERROR $e');
                              }
                            }
                            Navigator.pop(context);
                          } else {
                            final orderIdMs = getCurrentTimestamp
                                .millisecondsSinceEpoch
                                .toString();
                            final amountCop = widget!.respDT!.price * 100;
                            final driverId =
                                containerUsersRecord.reference.id;
                            final cabOrderId = widget!.order!.reference.id;
                            final created = await AppMeApi.createPayment({
                              'order_id': orderIdMs,
                              'orderId': orderIdMs,
                              'is_paid': false,
                              'amount_in_cop': amountCop,
                              'amountInCop': amountCop,
                              'payment_type':
                                  PaymentType.regularCustomer.serialize(),
                              'paymentType':
                                  PaymentType.regularCustomer.serialize(),
                              'current_order_id': cabOrderId,
                              'current_order_doc_ref': {
                                '_ref': 'order/$cabOrderId',
                              },
                              'driver_id': driverId,
                              'driver': {'_ref': 'users/$driverId'},
                              // цена отклика для accept-bid после оплаты
                              'bid_price': widget!.respDT?.price,
                              'commission_percent':
                                  containerUsersRecord.commissionPercent,
                            });
                            DocumentReference payOrderRecordReference;
                            if (created != null &&
                                (created['id']?.toString().isNotEmpty ??
                                    false)) {
                              payOrderRecordReference =
                                  PayOrderRecord.collection
                                      .doc(created['id'].toString());
                              // FS doc для PayInit stream (пока poll не готов)
                              try {
                                await payOrderRecordReference
                                    .set(createPayOrderRecordData(
                                  orderId: orderIdMs,
                                  isPaid: false,
                                  amountInCop: amountCop,
                                  user: currentUserReference,
                                  paymentType: PaymentType.regularCustomer,
                                  currentOrderDocRef: widget!.order?.reference,
                                  driver: containerUsersRecord.reference,
                                ));
                              } catch (_) {}
                            } else {
                              payOrderRecordReference =
                                  PayOrderRecord.collection.doc();
                              await payOrderRecordReference
                                  .set(createPayOrderRecordData(
                                orderId: orderIdMs,
                                isPaid: false,
                                amountInCop: amountCop,
                                user: currentUserReference,
                                paymentType: PaymentType.regularCustomer,
                                currentOrderDocRef: widget!.order?.reference,
                                driver: containerUsersRecord.reference,
                              ));
                            }
                            _model.order = PayOrderRecord.getDocumentFromData(
                                createPayOrderRecordData(
                                  orderId: orderIdMs,
                                  isPaid: false,
                                  amountInCop: amountCop,
                                  user: currentUserReference,
                                  paymentType: PaymentType.regularCustomer,
                                  currentOrderDocRef: widget!.order?.reference,
                                  driver: containerUsersRecord.reference,
                                ),
                                payOrderRecordReference);
                            showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return WebViewAware(
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: PayInitWidget(
                                      payOrderRef: _model.order!.reference,
                                      amountRUB: widget!.respDT!.price,
                                      currentprice: widget!.respDT!.price,
                                      driver: containerUsersRecord.reference,
                                    ),
                                  ),
                                );
                              },
                            ).then((value) => safeSetState(() {}));
                          }

                          triggerPushNotification(
                            notificationTitle: 'Заказчик выбрал вас!',
                            notificationText:
                                'Перейдите в заказ, чтобы начать выполнение',
                            notificationSound: 'default',
                            userRefs: [containerUsersRecord.reference],
                            initialPageName: 'order_Page_Driver',
                            parameterData: {
                              'order': widget!.order?.reference,
                            },
                          );

                          safeSetState(() {});
                        },
                        text: widget!.order?.payMethod == PayMethod.card
                            ? 'Выбрать специалиста и оплатить'
                            : 'Выбрать этого специалиста',
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
                          disabledColor: Color(0xFFF4F5F8),
                          disabledTextColor: Color(0xFFA4A6B2),
                        ),
                        showLoadingIndicator: false,
                      ),
                    ),
                  );
                  }),
              ].divide(SizedBox(height: 5.0)),
            ),
          );
        },
      ),
    );
  }
}
