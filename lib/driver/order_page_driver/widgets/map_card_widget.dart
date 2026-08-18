import '../../../customer/zakaz_na_karte/zakaz_na_karte_widget.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

class MapCardWidget extends StatelessWidget {
  const MapCardWidget({
    super.key,
    required this.order,
  });

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final pointA = order.pointA.latlng;
    final pointB = order.pointB.latlng;
    final showDriver = (order.status == StatusOrder.at_work ||
            order.status == StatusOrder.spec_set) &&
        order.hasDriverLocation();
    final etaText = order.hasTimeLeft() ? order.timeLeft : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional(0.0, 1.0),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 300.0,
                    child: pointA == null || pointB == null
                        ? const SizedBox.shrink()
                        : custom_widgets.YandexOrderMap(
                            width: double.infinity,
                            height: 300.0,
                            startLatLng: pointA,
                            endLatLng: pointB,
                            driverLocation: order.driverLocation,
                            showDriver: showDriver,
                            etaText: etaText,
                            isStatic: true,
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
                            order.reference,
                            ParamType.DocumentReference,
                          ),
                        }.withoutNulls,
                      );
                    },
                    text: 'Маршрут на карте',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 35.0,
                      color: const Color(0xD8F4F5F8),
                      textStyle: FlutterFlowTheme.of(context)
                          .titleSmall
                          .override(
                            fontFamily: 'SF',
                            color: FlutterFlowTheme.of(context).tertiary,
                            fontSize: 14.0,
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    showLoadingIndicator: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (pointA == null || pointB == null) return;
                      await actions.openYandexRoute(pointA, pointB);
                    },
                    text: 'Проложить маршрут в Яндекс Навигаторе',
                    options: FFButtonOptions(
                      width: 222.0,
                      height: 45.0,
                      color: const Color(0xD8F4F5F8),
                      textStyle: FlutterFlowTheme.of(context)
                          .titleSmall
                          .override(
                            fontFamily: 'SF',
                            color: FlutterFlowTheme.of(context).tertiary,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    showLoadingIndicator: false,
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
