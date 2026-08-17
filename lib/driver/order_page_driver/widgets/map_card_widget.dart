import '../../../customer/zakaz_na_karte/zakaz_na_karte_widget.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/backend.dart';
import 'package:flutter/material.dart';

// Map preview widget with route button
class MapCardWidget extends StatelessWidget {
  const MapCardWidget({
    super.key,
    required this.order,
  });

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground, borderRadius: BorderRadius.circular(18.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional(0.0, 1.0),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    width: double.infinity,
                    height: 150.0,
                    child: custom_widgets.YandexOrderMap(
                      width: double.infinity,
                      height: 150.0,
                      startLatLng: order.pointA.latlng!,
                      endLatLng: order.pointB.latlng!,
                      isStatic: true,
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
                          'order': serializeParam(order.reference, ParamType.DocumentReference),
                        }.withoutNulls,
                      );
                    },
                    text: 'Маршрут на карте',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 35.0,
                      color: Color(0xD8F4F5F8),
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(fontFamily: 'SF', color: FlutterFlowTheme.of(context).tertiary, fontSize: 14.0),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    showLoadingIndicator: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () async {
                      await actions.open2GISRoute(order.pointA.latlng!, order.pointB.latlng!);
                    },
                    text: 'В 2ГИС',
                    options: FFButtonOptions(
                      width: 222.0,
                      height: 45.0,
                      color: Color(0xD8F4F5F8),
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(fontFamily: 'SF', color: FlutterFlowTheme.of(context).tertiary, fontSize: 16.0, fontWeight: FontWeight.w500),
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