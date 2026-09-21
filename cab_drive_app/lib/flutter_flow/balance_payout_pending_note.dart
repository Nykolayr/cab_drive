import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:flutter/material.dart';

/// Лаконичная пометка: сумма на одобрении вывода.
class BalancePayoutPendingNote extends StatelessWidget {
  const BalancePayoutPendingNote({
    super.key,
    this.amount,
    this.topPadding = 4.0,
    this.fontSize = 12.0,
    this.color,
  });

  /// Если null — берём effectiveBalancePayoutPending.
  final double? amount;
  final double topPadding;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final double pending =
        amount ?? valueOrDefault(effectiveBalancePayoutPending, 0.0) ?? 0.0;
    if (pending <= 0) {
      return const SizedBox.shrink();
    }
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, topPadding, 0.0, 0.0),
      child: Text(
        'На одобрении: ${formatNumber(
          pending,
          formatType: FormatType.custom,
          format: '0',
          locale: '',
        )} ₽',
        style: theme.bodySmall.override(
          fontFamily: 'SF',
          color: color ?? theme.secondaryText,
          fontSize: fontSize,
          letterSpacing: 0.0,
        ),
      ),
    );
  }
}
