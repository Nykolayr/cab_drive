import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/customer/otmena_zakaza/otmena_zakaza_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'order_menu_p_o_p_u_p_model.dart';
export 'order_menu_p_o_p_u_p_model.dart';

class OrderMenuPOPUPWidget extends StatefulWidget {
  const OrderMenuPOPUPWidget({
    super.key,
    required this.order,
  });

  final OrderRecord? order;

  @override
  State<OrderMenuPOPUPWidget> createState() => _OrderMenuPOPUPWidgetState();
}

class _OrderMenuPOPUPWidgetState extends State<OrderMenuPOPUPWidget> {
  late OrderMenuPOPUPModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderMenuPOPUPModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(50.0, 0.0, 16.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: [
            BoxShadow(
              blurRadius: 44.0,
              color: Color(0x33000000),
              offset: Offset(
                4.0,
                4.0,
              ),
            )
          ],
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((widget!.order?.status == StatusOrder.newOrder) ||
                (widget!.order?.status == StatusOrder.hidden))
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 57.0,
                    child: Stack(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Text(
                            widget!.order?.status == StatusOrder.hidden
                                ? 'Опубликовать снова'
                                : 'Скрыть заказ',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            if (widget!.order?.status == StatusOrder.hidden) {
                              Navigator.pop(context);

                              await widget!.order!.reference
                                  .update(createOrderRecordData(
                                status: widget!.order?.statusDoHidden,
                                dateUpd: getCurrentTimestamp,
                              ));
                              return;
                            } else {
                              Navigator.pop(context);

                              await widget!.order!.reference
                                  .update(createOrderRecordData(
                                statusDoHidden: widget!.order?.status,
                              ));

                              await widget!.order!.reference
                                  .update(createOrderRecordData(
                                status: StatusOrder.hidden,
                                dateUpd: getCurrentTimestamp,
                              ));
                              return;
                            }
                          },
                          text: '',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: double.infinity,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Colors.transparent,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'SF',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            hoverColor: Colors.transparent,
                            hoverBorderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                            hoverTextColor: Colors.transparent,
                          ),
                          showLoadingIndicator: false,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0.3,
                    thickness: 0.3,
                    color: Color(0xFFD0CFCE),
                  ),
                  Container(
                    height: 57.0,
                    child: Stack(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Text(
                            'Отменить заказ',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                        FFButtonWidget(
                          onPressed: () async {
                            Navigator.pop(context);
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return WebViewAware(
                                  child: Padding(
                                    padding: MediaQuery.viewInsetsOf(context),
                                    child: OtmenaZakazaWidget(
                                      order: widget!.order!.reference,
                                    ),
                                  ),
                                );
                              },
                            ).then((value) => safeSetState(() {}));
                          },
                          text: '',
                          options: FFButtonOptions(
                            width: double.infinity,
                            height: double.infinity,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Colors.transparent,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'SF',
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(18.0),
                              bottomRight: Radius.circular(18.0),
                            ),
                            hoverColor: Colors.transparent,
                            hoverBorderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                            hoverTextColor: Colors.transparent,
                          ),
                          showLoadingIndicator: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
