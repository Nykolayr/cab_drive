import '/admin/orklonit/orklonit_widget.dart';
import '/backend/backend.dart';
import '/backend/push_notifications/push_notifications_util.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_expanded_image_view.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/app_bar/app_bar_widget.dart';
import '/pages/bottom/image_view/image_view_widget.dart';
import '/pages/bottom/text_info/text_info_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'detali_zayavki_admin_model.dart';
export 'detali_zayavki_admin_model.dart';

class DetaliZayavkiAdminWidget extends StatefulWidget {
  const DetaliZayavkiAdminWidget({
    super.key,
    required this.docref,
  });

  final DocumentReference? docref;

  static String routeName = 'Detali_zayavki_Admin';
  static String routePath = '/detaliZayavkiAdmin';

  @override
  State<DetaliZayavkiAdminWidget> createState() =>
      _DetaliZayavkiAdminWidgetState();
}

class _DetaliZayavkiAdminWidgetState extends State<DetaliZayavkiAdminWidget> {
  late DetaliZayavkiAdminModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DetaliZayavkiAdminModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RequestVereficationRecord>(
      stream: RequestVereficationRecord.getDocument(widget.docref!),
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

        final detaliZayavkiAdminRequestVereficationRecord = snapshot.data!;

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
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    wrapWithModel(
                      model: _model.appBarModel,
                      updateCallback: () => safeSetState(() {}),
                      child: AppBarWidget(
                        text:
                            'Детали заявки №${detaliZayavkiAdminRequestVereficationRecord.numberId.toString()}',
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
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24.0, 24.0, 24.0, 20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Статус: ${valueOrDefault<String>(
                                            () {
                                              if (detaliZayavkiAdminRequestVereficationRecord
                                                      .status ==
                                                  StatusVerif.onVerif) {
                                                return 'на верефикации';
                                              } else if (detaliZayavkiAdminRequestVereficationRecord
                                                      .status ==
                                                  StatusVerif.Completed) {
                                                return 'подтвержден';
                                              } else {
                                                return 'отклонен';
                                              }
                                            }(),
                                            'На верефикации',
                                          )}',
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
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24.0, 24.0, 24.0, 20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 24.0),
                                          child: Text(
                                            'Основная информация',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 21.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
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
                                                      image: OctoImage(
                                                        placeholderBuilder:
                                                            (_) =>
                                                                const SizedBox
                                                                    .expand(
                                                          child: Image(
                                                            image: BlurHashImage(
                                                                'LMG[~DR54To#~XofRjbH9[ozxHay'),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        image: NetworkImage(
                                                          detaliZayavkiAdminRequestVereficationRecord
                                                              .avatar,
                                                        ),
                                                        fit: BoxFit.contain,
                                                      ),
                                                      allowRotation: false,
                                                      tag:
                                                          detaliZayavkiAdminRequestVereficationRecord
                                                              .avatar,
                                                      useHeroAnimation: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Hero(
                                                tag:
                                                    detaliZayavkiAdminRequestVereficationRecord
                                                        .avatar,
                                                transitionOnUserGestures: true,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: OctoImage(
                                                    placeholderBuilder: (_) =>
                                                        const SizedBox.expand(
                                                      child: Image(
                                                        image: BlurHashImage(
                                                            'LMG[~DR54To#~XofRjbH9[ozxHay'),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    image: NetworkImage(
                                                      detaliZayavkiAdminRequestVereficationRecord
                                                          .avatar,
                                                    ),
                                                    width: 60.0,
                                                    height: 80.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 6.0, 0.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${detaliZayavkiAdminRequestVereficationRecord.name} ${detaliZayavkiAdminRequestVereficationRecord.surname}',
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
                                                      detaliZayavkiAdminRequestVereficationRecord
                                                          .city,
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
                                                  ].divide(const SizedBox(
                                                      height: 4.0)),
                                                ),
                                              ),
                                            ),
                                          ].divide(const SizedBox(width: 12.0)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: wrapWithModel(
                                            model: _model.textInfoModel1,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TextInfoWidget(
                                              tittle: 'Дата рождения',
                                              pole: dateTimeFormat(
                                                "d/M/y",
                                                detaliZayavkiAdminRequestVereficationRecord
                                                    .dfb,
                                                locale:
                                                    FFLocalizations.of(context)
                                                        .languageCode,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: wrapWithModel(
                                            model: _model.textInfoModel2,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TextInfoWidget(
                                              tittle: 'Почта',
                                              pole:
                                                  detaliZayavkiAdminRequestVereficationRecord
                                                      .email,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: wrapWithModel(
                                            model: _model.textInfoModel3,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TextInfoWidget(
                                              tittle: 'Номер телефона',
                                              pole:
                                                  detaliZayavkiAdminRequestVereficationRecord
                                                      .phoneNumber,
                                            ),
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
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            16.0, 24.0, 16.0, 24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 18.0),
                                          child: Text(
                                            'Фото документов',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 21.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        Builder(
                                          builder: (context) {
                                            final doc =
                                                detaliZayavkiAdminRequestVereficationRecord
                                                    .photoDoc
                                                    .toList();

                                            return GridView.builder(
                                              padding: EdgeInsets.zero,
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 8.0,
                                                mainAxisSpacing: 8.0,
                                                childAspectRatio: 1.0,
                                              ),
                                              primary: false,
                                              shrinkWrap: true,
                                              itemCount: doc.length,
                                              itemBuilder: (context, docIndex) {
                                                final docItem = doc[docIndex];
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
                                                                  ImageViewWidget(
                                                                indexCurrent:
                                                                    docIndex,
                                                                alllistImage:
                                                                    detaliZayavkiAdminRequestVereficationRecord
                                                                        .photoDoc,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).then((value) =>
                                                        safeSetState(() {}));
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            11.0),
                                                    child: OctoImage(
                                                      placeholderBuilder: (_) =>
                                                          const SizedBox.expand(
                                                        child: Image(
                                                          image: BlurHashImage(
                                                              'LMG[~DR54To#~XofRjbH9[ozxHay'),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      image: NetworkImage(
                                                        docItem,
                                                      ),
                                                      width: double.infinity,
                                                      height: 117.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
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
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            24.0, 24.0, 24.0, 66.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 29.0),
                                          child: Text(
                                            'Данные о транспорте',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'SF',
                                                  fontSize: 21.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        wrapWithModel(
                                          model: _model.textInfoModel4,
                                          updateCallback: () =>
                                              safeSetState(() {}),
                                          child: TextInfoWidget(
                                            tittle: 'Марка',
                                            pole: () {
                                              if (detaliZayavkiAdminRequestVereficationRecord
                                                      .marka ==
                                                  Car.largus) {
                                                return 'LADA Largus';
                                              } else if (detaliZayavkiAdminRequestVereficationRecord
                                                      .marka ==
                                                  Car.largusTermo) {
                                                return 'LADA Largus с термо будкой';
                                              } else {
                                                return 'Fiat Doblò/Citroën Berlingo/PEUGEOT PARTNER ';
                                              }
                                            }(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: wrapWithModel(
                                            model: _model.textInfoModel5,
                                            updateCallback: () =>
                                                safeSetState(() {}),
                                            child: TextInfoWidget(
                                              tittle: 'Госномер',
                                              pole:
                                                  detaliZayavkiAdminRequestVereficationRecord
                                                      .numberAvto,
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          height: 0.0,
                                          thickness: 3.0,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 24.0, 0.0, 14.0),
                                          child: Text(
                                            'Фото транспорта',
                                            style: FlutterFlowTheme.of(context)
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
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                          child: Builder(
                                            builder: (context) {
                                              final imagesCargo =
                                                  detaliZayavkiAdminRequestVereficationRecord
                                                      .photoAvto
                                                      .toList();

                                              return GridView.builder(
                                                padding: EdgeInsets.zero,
                                                gridDelegate:
                                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 4,
                                                  crossAxisSpacing: 6.0,
                                                  mainAxisSpacing: 6.0,
                                                  childAspectRatio: 1.0,
                                                ),
                                                primary: false,
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemCount: imagesCargo.length,
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
                                                                    ImageViewWidget(
                                                                  indexCurrent:
                                                                      imagesCargoIndex,
                                                                  alllistImage:
                                                                      detaliZayavkiAdminRequestVereficationRecord
                                                                          .photoAvto,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).then((value) =>
                                                          safeSetState(() {}));
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: OctoImage(
                                                        placeholderBuilder:
                                                            (_) =>
                                                                const SizedBox
                                                                    .expand(
                                                          child: Image(
                                                            image: BlurHashImage(
                                                                'LMG[~DR54To#~XofRjbH9[ozxHay'),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        image: NetworkImage(
                                                          imagesCargoItem,
                                                        ),
                                                        width: double.infinity,
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
                                ),
                              ].divide(const SizedBox(height: 5.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18.0),
                          topRight: Radius.circular(18.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            8.0, 8.0, 8.0, 34.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                if (detaliZayavkiAdminRequestVereficationRecord
                                        .status ==
                                    StatusVerif.onVerif)
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 8.0, 0.0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
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
                                                    child: OrklonitWidget(
                                                      user:
                                                          detaliZayavkiAdminRequestVereficationRecord
                                                              .user!,
                                                      verif: widget.docref!,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        text: 'Отклонить',
                                        options: FFButtonOptions(
                                          width: 222.0,
                                          height: 56.0,
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                          iconPadding:
                                              const EdgeInsetsDirectional
                                                  .fromSTEB(0.0, 0.0, 0.0, 0.0),
                                          color: const Color(0xFFF4F5F8),
                                          textStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily: 'SF',
                                                    color:
                                                        const Color(0xFFFF0004),
                                                    letterSpacing: 0.0,
                                                  ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      _model.chat = await queryChatsRecordOnce(
                                        queryBuilder: (chatsRecord) =>
                                            chatsRecord
                                                .where(
                                                  'support',
                                                  isEqualTo: true,
                                                )
                                                .where(
                                                  'users',
                                                  arrayContains:
                                                      detaliZayavkiAdminRequestVereficationRecord
                                                          .user,
                                                ),
                                        singleRecord: true,
                                      ).then((s) => s.firstOrNull);

                                      context.pushNamed(
                                        ChatWidget.routeName,
                                        queryParameters: {
                                          'chat': serializeParam(
                                            _model.chat?.reference,
                                            ParamType.DocumentReference,
                                          ),
                                          'name': serializeParam(
                                            '${detaliZayavkiAdminRequestVereficationRecord.name} ${detaliZayavkiAdminRequestVereficationRecord.surname}',
                                            ParamType.String,
                                          ),
                                        }.withoutNulls,
                                      );

                                      safeSetState(() {});
                                    },
                                    text: 'Написать',
                                    options: FFButtonOptions(
                                      width: 222.0,
                                      height: 56.0,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color: const Color(0xFFF4F5F8),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily: 'SF',
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                            letterSpacing: 0.0,
                                          ),
                                      elevation: 0.0,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (detaliZayavkiAdminRequestVereficationRecord
                                    .status ==
                                StatusVerif.onVerif)
                              FFButtonWidget(
                                onPressed: () async {
                                  await widget.docref!.update(
                                      createRequestVereficationRecordData(
                                    status: StatusVerif.Completed,
                                  ));

                                  await detaliZayavkiAdminRequestVereficationRecord
                                      .user!
                                      .update(createUsersRecordData(
                                    onVerifNow: false,
                                    verifCompl: true,
                                  ));
                                  triggerPushNotification(
                                    notificationTitle: 'Верефикация пройдена!',
                                    notificationText:
                                        'Вы прошли верефикацию. Теперь вы можете находить и выполнять заказы ',
                                    notificationSound: 'default',
                                    userRefs: [
                                      detaliZayavkiAdminRequestVereficationRecord
                                          .user!
                                    ],
                                    initialPageName: 'LOAD',
                                    parameterData: {},
                                  );
                                },
                                text: 'Одобрить',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 56.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
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
                          ].divide(const SizedBox(height: 10.0)),
                        ),
                      ),
                    ),
                  ].divide(const SizedBox(height: 5.0)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
