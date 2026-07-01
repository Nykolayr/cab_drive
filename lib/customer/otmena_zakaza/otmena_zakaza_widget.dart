import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/chips_card/chips_card_widget.dart';
import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'otmena_zakaza_model.dart';
export 'otmena_zakaza_model.dart';

class OtmenaZakazaWidget extends StatefulWidget {
  const OtmenaZakazaWidget({
    super.key,
    required this.order,
  });

  final DocumentReference? order;

  @override
  State<OtmenaZakazaWidget> createState() => _OtmenaZakazaWidgetState();
}

class _OtmenaZakazaWidgetState extends State<OtmenaZakazaWidget> {
  late OtmenaZakazaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OtmenaZakazaModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

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
                  Flexible(
                    child: Text(
                      'Выберите причину отмены',
                      textAlign: TextAlign.start,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF',
                            fontSize: 21.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
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
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  wrapWithModel(
                    model: _model.chipsCardModel1,
                    updateCallback: () => safeSetState(() {}),
                    child: ChipsCardWidget(
                      text: 'Изменились планы',
                      selectedItem: _model.reason,
                      action: (text) async {
                        _model.reason = text;
                        safeSetState(() {});
                      },
                    ),
                  ),
                  wrapWithModel(
                    model: _model.chipsCardModel2,
                    updateCallback: () => safeSetState(() {}),
                    child: ChipsCardWidget(
                      text: 'Нет подходящих предложений',
                      selectedItem: _model.reason,
                      action: (text) async {
                        _model.reason = text;
                        safeSetState(() {});
                      },
                    ),
                  ),
                  wrapWithModel(
                    model: _model.chipsCardModel3,
                    updateCallback: () => safeSetState(() {}),
                    child: ChipsCardWidget(
                      text: 'Уже нашел специалиста',
                      selectedItem: _model.reason,
                      action: (text) async {
                        _model.reason = text;
                        safeSetState(() {});
                      },
                    ),
                  ),
                  wrapWithModel(
                    model: _model.chipsCardModel4,
                    updateCallback: () => safeSetState(() {}),
                    child: ChipsCardWidget(
                      text: 'Хочу изменить заказ',
                      selectedItem: _model.reason,
                      action: (text) async {
                        _model.reason = text;
                        safeSetState(() {});
                      },
                    ),
                  ),
                  wrapWithModel(
                    model: _model.chipsCardModel5,
                    updateCallback: () => safeSetState(() {}),
                    child: ChipsCardWidget(
                      text: 'Другое',
                      selectedItem: _model.reason,
                      action: (text) async {
                        _model.reason = text;
                        safeSetState(() {});
                      },
                    ),
                  ),
                ],
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
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 34.0),
              child: FFButtonWidget(
                onPressed: (_model.reason == null || _model.reason == '')
                    ? null
                    : () async {
                        unawaited(
                          () async {
                            await widget!.order!.update(createOrderRecordData(
                              status: StatusOrder.cancelled,
                              dateUpd: getCurrentTimestamp,
                            ));
                          }(),
                        );
                        Navigator.pop(context);
                      },
                text: 'Отменить заказ',
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
                  disabledColor: FlutterFlowTheme.of(context).primaryBackground,
                  disabledTextColor: FlutterFlowTheme.of(context).secondaryText,
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
