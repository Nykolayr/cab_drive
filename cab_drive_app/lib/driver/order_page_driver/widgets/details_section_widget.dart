import 'package:flutter/services.dart';

import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/schema/enums/enums.dart';
import '../../../flutter_flow/flutter_flow_icon_button.dart';
import '../order_page_driver_model.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/text_info/text_info_widget.dart';
import '/backend/backend.dart';
import 'package:flutter/material.dart';

// Details section: addresses, info rows (simplified, extracted)
class DetailsSectionWidget extends StatelessWidget {
  const DetailsSectionWidget({
    super.key,
    required this.order,
    required this.model,
  });

  final OrderRecord order;
  final OrderPageDriverModel model;

  Widget _addressBlock(BuildContext context, String title, PointStruct point, {bool includeCopy = true}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground, borderRadius: BorderRadius.circular(18.0)),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                TextInfoWidget(tittle: title, pole: point.address),
                if (includeCopy)
                  Align(
                    alignment: AlignmentDirectional(1.0, 0.0),
                    child: FlutterFlowIconButton(
                      buttonSize: 50.0,
                      icon: Icon(Icons.content_copy_outlined, color: FlutterFlowTheme.of(context).tertiary, size: 20.0),
                      onPressed: () async {
                        HapticFeedback.heavyImpact();
                        await Clipboard.setData(ClipboardData(text: point.fullAddress));
                      },
                    ),
                  ),
              ],
            ),
            if (point.comment != null && point.comment != '') SizedBox(height: 8.0),
            if (point.comment != null && point.comment != '') TextInfoWidget(tittle: 'Комментарий водителю', pole: point.comment),
            TextInfoWidget(tittle: 'Контакт отправителя', pole: '${point.sender.phone}, ${point.sender.name}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDriverSelected = order.selectedDriver == currentUserReference;

    return Column(
      children: [
          Column(
            children: [
              _addressBlock(context, 'Откуда', order.pointA),
              SizedBox(height: 5.0),
              if (order.pointC.address.isNotEmpty)
                Column(
                  children: [
                    _addressBlock(context, 'Промежуточная точка', order.pointC),
                    SizedBox(height: 5.0),
                  ],
                ),
              _addressBlock(context, 'Куда', order.pointB),
            ],
          ),
        // Info card with summary fields
        SizedBox(height: 5.0),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: FlutterFlowTheme.of(context).secondaryBackground, borderRadius: BorderRadius.circular(18.0)),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInfoWidget(tittle: 'Ожидаемая стоимость', pole: '${order.budget.toString()} ₽'),
                TextInfoWidget(tittle: 'Итоговая стоимость доставки', pole: '${order.currentPrice.toString()} ₽'),
                TextInfoWidget(tittle: 'Способ оплаты', pole: order.payMethod == PayMethod.card ? 'Оплата картой' : 'Оплата наличными'),
                TextInfoWidget(tittle: 'Время и дистанция', pole: '${order.time}, ${order.distanceStr}'),
                TextInfoWidget(
                  tittle: 'Подача',
                  pole: order.supply == 1 ? 'В ближайшее время' : valueOrDefault<String>(dateTimeFormat("MMMMEEEEd", order.dateTime, locale: FFLocalizations.of(context).languageCode), 'MMMMEEEEd HH:mm'),
                ),
                TextInfoWidget(
                  tittle: 'Грузчики',
                  pole: () {
                    if (order.movers == 1) return 'Нужна помощь водителя';
                    if (order.movers == 2) return 'Нужна помощь двух грузчиков';
                    return 'Помощь не нужна';
                  }(),
                ),
                TextInfoWidget(
                  tittle: 'Авто',
                  pole: () {
                    if (order.car == Car.largus) return 'LADA Largus';
                    if (order.car == Car.largusTermo) return 'LADA Largus с термо будкой';
                    return 'Fiat Doblò/Citroën Berlingo/PEUGEOT PARTNER ';
                  }(),
                ),
                TextInfoWidget(tittle: 'Описание груза', pole: order.description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}