import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

/// Поверх WebView / вместо экрана банка — понятная ошибка оплаты.
class PaymentResultOverlay extends StatelessWidget {
  const PaymentResultOverlay({
    super.key,
    required this.message,
    required this.onClose,
    this.title = 'Не получилось оплатить',
  });

  final String title;
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              decoration: BoxDecoration(
                color: theme.secondaryBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F5F8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFFE53935),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.bodyMedium.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                      fontSize: 20,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.bodyMedium.override(
                      fontFamily: 'SF',
                      fontSize: 15,
                      letterSpacing: 0,
                      color: theme.secondaryText,
                      lineHeight: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FFButtonWidget(
                    onPressed: onClose,
                    text: 'Закрыть',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 52,
                      color: theme.tertiary,
                      textStyle: theme.titleSmall.override(
                        fontFamily: 'SF',
                        color: theme.primaryBackground,
                        letterSpacing: 0,
                      ),
                      elevation: 0,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    showLoadingIndicator: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
