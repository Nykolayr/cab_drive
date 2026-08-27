import 'package:cab_drive/backend/backend.dart';
import 'package:cab_drive/backend/schema/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../create_map_page/domain/entities/entities.dart';
import '../../create_map_page/presentation/bloc/orders_bloc.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../flutter_flow/flutter_flow_util.dart';

class EditMoversWidget extends StatelessWidget {
  final Function(
    int,
      int
  )? selected;
  final int value;
  final Car car;
  final OrderRecord order;

  const EditMoversWidget(
      {super.key, this.selected, required this.value, required this.car, required this.order});


  @override
  Widget build(BuildContext context) {
    int price = 0;

    int movers = value;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
      child: Container(
        height: 57.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(10)

        ),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Грузчики',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Text(
                    valueOrDefault<String>(
                      movers != 0
                          ? 'Каждая вещь до 30 кг'
                          : 'Помощь не нужна',
                      'Помощь не нужна',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          color: Color(0xFF8F8F8E),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              height: 41.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        movers = 0;


                        context.read<OrdersBloc>().add(
                            OrdersEvent.getPrices(
                                userLocation: LocationEntity(
                                    lat: FFAppState().pointA
                                        .latlng!.latitude,
                                    lng: FFAppState().pointA
                                        .latlng!.longitude),
                                destLocation: LocationEntity(
                                    lat: FFAppState().pointB
                                        .latlng!.latitude,
                                    lng: FFAppState().pointB
                                        .latlng!.longitude),
                                intermediate: LocationEntity(
                                    lat: FFAppState().pointC
                                        .latlng!.latitude,
                                    lng: FFAppState().pointC
                                        .latlng!.longitude),
                                movers: movers, onSuccess: (value) {
                              if (car == Car.largus) {
                                price = value!['largus']!.price.toInt();
                                selected?.call(movers, price);

                              } else if (car == Car.largusTermo) {
                                price = value!['largustermo']!.price.toInt();
                                selected?.call(movers, price);

                              } else {
                                price = value!['fiat']!.price.toInt();
                                selected?.call(movers, price);

                              }
                            }));




                      },
                      child: Container(
                        width: 61.0,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: valueOrDefault<Color>(
                            movers == 0
                                ? FlutterFlowTheme.of(context)
                                    .secondaryBackground
                                : Colors.transparent,
                            FlutterFlowTheme.of(context).secondaryBackground,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            'Нет',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  color: valueOrDefault<Color>(
                                    movers == 0
                                        ? FlutterFlowTheme.of(context)
                                            .primaryText
                                        : FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    FlutterFlowTheme.of(context).primaryText,
                                  ),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
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
                        movers = 1;

                        HapticFeedback.mediumImpact();

                        context.read<OrdersBloc>().add(
                            OrdersEvent.getPrices(
                                userLocation: LocationEntity(
                                    lat: FFAppState().pointA
                                        .latlng!.latitude,
                                    lng: FFAppState().pointA
                                        .latlng!.longitude),
                                destLocation: LocationEntity(
                                    lat: FFAppState().pointB
                                        .latlng!.latitude,
                                    lng: FFAppState().pointB
                                        .latlng!.longitude),
                                intermediate: LocationEntity(
                                    lat: FFAppState().pointC
                                        .latlng!.latitude,
                                    lng: FFAppState().pointC
                                        .latlng!.longitude),
                                movers: movers, onSuccess: (value) {
                              if (car == Car.largus) {
                                price = value!['largus']!.price.toInt();
                                selected?.call(movers, price);

                              } else if (car == Car.largusTermo) {
                                price = value!['largustermo']!.price.toInt();
                                selected?.call(movers, price);

                              } else {
                                price = value!['fiat']!.price.toInt();
                                selected?.call(movers, price);

                              }
                            }));

                      },
                      child: Container(
                        width: 43.0,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: valueOrDefault<Color>(
                            movers == 1
                                ? FlutterFlowTheme.of(context)
                                    .secondaryBackground
                                : Colors.transparent,
                            Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            '1',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  color: valueOrDefault<Color>(
                                    movers == 1
                                        ? FlutterFlowTheme.of(context)
                                            .primaryText
                                        : FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
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
                        movers = 2;
                        HapticFeedback.mediumImpact();

                        context.read<OrdersBloc>().add(
                            OrdersEvent.getPrices(
                                userLocation: LocationEntity(
                                    lat: FFAppState().pointA
                                        .latlng!.latitude,
                                    lng: FFAppState().pointA
                                        .latlng!.longitude),
                                destLocation: LocationEntity(
                                    lat: FFAppState().pointB
                                        .latlng!.latitude,
                                    lng: FFAppState().pointB
                                        .latlng!.longitude),
                                intermediate: LocationEntity(
                                    lat: FFAppState().pointC
                                        .latlng!.latitude,
                                    lng: FFAppState().pointC
                                        .latlng!.longitude),
                                movers: movers, onSuccess: (value) {
                              if (car == Car.largus) {
                                price = value!['largus']!.price.toInt();
                                selected?.call(movers, price);

                              } else if (car == Car.largusTermo) {
                                price = value!['largustermo']!.price.toInt();
                                selected?.call(movers, price);

                              } else {
                                price = value!['fiat']!.price.toInt();
                                selected?.call(movers, price);

                              }
                            }));
                      },
                      child: Container(
                        width: 43.0,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: valueOrDefault<Color>(
                            movers == 2
                                ? FlutterFlowTheme.of(context)
                                    .secondaryBackground
                                : Colors.transparent,
                            Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            '2',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  color: valueOrDefault<Color>(
                                    movers == 2
                                        ? FlutterFlowTheme.of(context)
                                            .primaryText
                                        : FlutterFlowTheme.of(context)
                                            .secondaryText,
                                    FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
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
    );
  }
}
