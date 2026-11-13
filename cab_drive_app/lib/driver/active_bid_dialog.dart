import '/backend/backend.dart';
import '/driver/order_page_driver/order_page_driver_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Подсказка «у вас уже есть активный отклик» с переходом на тот заказ.
/// [orderInfo] — короткое описание заказа (например «за 500 ₽»), может быть null.
Future<void> showActiveBidDialog(
  BuildContext context, {
  required DocumentReference orderRef,
  String? orderInfo,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      final theme = FlutterFlowTheme.of(dialogContext);
      return AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'У вас уже есть активный отклик',
          style: theme.bodyMedium.override(
            fontFamily: 'SF',
            fontSize: 18.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Отклик можно оставить только на один заказ за раз.'
          '${orderInfo != null && orderInfo.isNotEmpty ? ' Сейчас отклик висит на заказе $orderInfo.' : ''}'
          ' Отмените его, чтобы откликнуться на другой.',
          style: theme.bodyMedium.override(
            fontFamily: 'SF',
            fontSize: 15.0,
            letterSpacing: 0.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Понятно',
              style: theme.bodyMedium.override(
                fontFamily: 'SF',
                letterSpacing: 0.0,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pushNamed(
                OrderPageDriverWidget.routeName,
                queryParameters: {
                  'order': serializeParam(
                    orderRef,
                    ParamType.DocumentReference,
                  ),
                }.withoutNulls,
              );
            },
            child: Text(
              'Перейти к заказу',
              style: theme.bodyMedium.override(
                fontFamily: 'SF',
                color: theme.primary,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}
