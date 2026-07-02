import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/customer/order_card_customer/order_card_customer_widget.dart';
import '/driver/order_card_driver/order_card_driver_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'moi_zakazy_model.dart';
export 'moi_zakazy_model.dart';

class MoiZakazyWidget extends StatefulWidget {
  const MoiZakazyWidget({super.key});

  @override
  State<MoiZakazyWidget> createState() => _MoiZakazyWidgetState();
}

class _MoiZakazyWidgetState extends State<MoiZakazyWidget> {
  late MoiZakazyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MoiZakazyModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.only(
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22.0),
                  topRight: Radius.circular(22.0),
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Мои заказы',
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
                      fillColor: FlutterFlowTheme.of(context).primary,
                      hoverColor: FlutterFlowTheme.of(context).primary,
                      hoverIconColor: FlutterFlowTheme.of(context).primaryText,
                      icon: Icon(
                        FFIcons.kkrestStroke,
                        color: FlutterFlowTheme.of(context).primaryText,
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
              child: Builder(
                builder: (context) {
                  if (valueOrDefault<bool>(
                      currentUserDocument?.isDriver, false)) {
                    return StreamBuilder<List<OrderRecord>>(
                      stream: queryOrderRecord(
                        queryBuilder: (orderRecord) => orderRecord
                            .where(
                              'selected_driver',
                              isEqualTo: currentUserReference,
                            )
                            .orderBy('date_upd', descending: true),
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
                        List<OrderRecord> listViewOrderRecordList =
                            snapshot.data!;

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            0,
                            0,
                            0,
                            50.0,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: listViewOrderRecordList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 5.0),
                          itemBuilder: (context, listViewIndex) {
                            final listViewOrderRecord =
                                listViewOrderRecordList[listViewIndex];
                            return InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  OrderPageDriverWidget.routeName,
                                  queryParameters: {
                                    'order': serializeParam(
                                      listViewOrderRecord.reference,
                                      ParamType.DocumentReference,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              child: OrderCardDriverWidget(
                                key: Key(
                                    'Keyciq_${listViewIndex}_of_${listViewOrderRecordList.length}'),
                                order: listViewOrderRecord,
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    return StreamBuilder<List<OrderRecord>>(
                      stream: queryOrderRecord(
                        queryBuilder: (orderRecord) => orderRecord
                            .where(
                              'user_customer',
                              isEqualTo: currentUserReference,
                            )
                            .orderBy('date_upd', descending: true),
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
                        List<OrderRecord> listViewOrderRecordList =
                            snapshot.data!;

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            0,
                            0,
                            0,
                            50.0,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: listViewOrderRecordList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 5.0),
                          itemBuilder: (context, listViewIndex) {
                            final listViewOrderRecord =
                                listViewOrderRecordList[listViewIndex];
                            return InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  OrderPageCustomerWidget.routeName,
                                  queryParameters: {
                                    'index': serializeParam(
                                      2,
                                      ParamType.int,
                                    ),
                                    'order': serializeParam(
                                      listViewOrderRecord.reference,
                                      ParamType.DocumentReference,
                                    ),
                                  }.withoutNulls,
                                );
                              },
                              child: OrderCardCustomerWidget(
                                key: Key(
                                    'Keyfov_${listViewIndex}_of_${listViewOrderRecordList.length}'),
                                order: listViewOrderRecord,
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ].divide(const SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
