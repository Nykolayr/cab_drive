import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/customer/pay_add_card/pay_add_card_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/chips_card/chips_card_widget.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'sposob_oplaty_model.dart';
export 'sposob_oplaty_model.dart';

class SposobOplatyWidget extends StatefulWidget {
  const SposobOplatyWidget({super.key});

  @override
  State<SposobOplatyWidget> createState() => _SposobOplatyWidgetState();
}

class _SposobOplatyWidgetState extends State<SposobOplatyWidget> {
  late SposobOplatyModel _model;

  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SposobOplatyModel());

    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        safeSetState(() {
          _isKeyboardVisible = visible;
        });
      });
    }
  }

  @override
  void dispose() {
    _model.maybeDispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.only(
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
                topLeft: Radius.circular(22.0),
                topRight: Radius.circular(22.0),
                bottomLeft: Radius.circular(5.0),
                bottomRight: Radius.circular(5.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Способы оплаты',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                    hoverIconColor: FlutterFlowTheme.of(context).primaryText,
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
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      wrapWithModel(
                        model: _model.chipsCardModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: ChipsCardWidget(
                          text: 'Оплата картой',
                          selectedItem: _model.select,
                          action: (text) async {
                            _model.select = text;
                            _model.type = PayMethod.card;
                            safeSetState(() {});
                          },
                        ),
                      ),
                      wrapWithModel(
                        model: _model.chipsCardModel2,
                        updateCallback: () => safeSetState(() {}),
                        child: ChipsCardWidget(
                          text: 'Оплата наличными',
                          selectedItem: _model.select,
                          action: (text) async {
                            _model.select = text;
                            _model.type = PayMethod.cahs;
                            safeSetState(() {});
                          },
                        ),
                      ),
                      if (responsiveVisibility(
                        context: context,
                        phone: false,
                        tablet: false,
                        tabletLandscape: false,
                        desktop: false,
                      ))
                        StreamBuilder<List<SavedCardsRecord>>(
                          stream: querySavedCardsRecord(
                            parent: currentUserReference,
                          ),
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
                            List<SavedCardsRecord>
                                listViewSavedCardsRecordList = snapshot.data!;

                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              primary: false,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: listViewSavedCardsRecordList.length,
                              itemBuilder: (context, listViewIndex) {
                                final listViewSavedCardsRecord =
                                    listViewSavedCardsRecordList[listViewIndex];
                                return ChipsCardWidget(
                                  key: Key(
                                      'Keyshx_${listViewIndex}_of_${listViewSavedCardsRecordList.length}'),
                                  text: listViewSavedCardsRecord.pan,
                                  selectedItem: _model.select,
                                  action: (text) async {
                                    _model.select = text;
                                    _model.type = PayMethod.card;
                                    _model.card = listViewSavedCardsRecord;
                                    safeSetState(() {});
                                  },
                                );
                              },
                            );
                          },
                        ),
                      if (responsiveVisibility(
                        context: context,
                        phone: false,
                        tablet: false,
                        tabletLandscape: false,
                        desktop: false,
                      ))
                        FFButtonWidget(
                          onPressed: () async {
                            var payOrderRecordReference =
                                PayOrderRecord.collection.doc();
                            await payOrderRecordReference
                                .set(createPayOrderRecordData(
                              orderId: getCurrentTimestamp
                                  .millisecondsSinceEpoch
                                  .toString(),
                              isPaid: false,
                              amountInCop: 100,
                              user: currentUserReference,
                              paymentType: PaymentType.initRecurrent,
                            ));
                            _model.order = PayOrderRecord.getDocumentFromData(
                                createPayOrderRecordData(
                                  orderId: getCurrentTimestamp
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  isPaid: false,
                                  amountInCop: 100,
                                  user: currentUserReference,
                                  paymentType: PaymentType.initRecurrent,
                                ),
                                payOrderRecordReference);
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return WebViewAware(
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: PayAddCardWidget(
                                      payOrderRef: _model.order!.reference,
                                      amountCop: 100,
                                    ),
                                  ),
                                );
                              },
                            ).then((value) => safeSetState(() {}));

                            safeSetState(() {});
                          },
                          text: 'Добавить карту',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: 45.81,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0x00F4F5F8),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'SF',
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  8.0,
                  8.0,
                  8.0,
                  valueOrDefault<double>(
                    (isWeb
                            ? MediaQuery.viewInsetsOf(context).bottom > 0
                            : _isKeyboardVisible)
                        ? 8.0
                        : 35.0,
                    8.0,
                  )),
              child: FFButtonWidget(
                onPressed: () async {
                  FFAppState().payMethod = _model.type;
                  FFAppState().card = CardStruct(
                    pan: _model.card?.pan,
                    id: _model.card?.rebillId,
                    ref: _model.card?.reference,
                  );
                  safeSetState(() {});
                  Navigator.pop(context);
                },
                text: 'Готово',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 56.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).tertiary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'SF',
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        letterSpacing: 0.0,
                      ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                showLoadingIndicator: false,
              ),
            ),
          ),
        ].divide(SizedBox(height: 5.0)),
      ),
    );
  }
}
