import 'package:cab_drive/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

import '../../flutter_flow/flutter_flow_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  const CustomButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FFButtonWidget(text: text, onPressed: onTap, options: FFButtonOptions(width: double.infinity,
      height: 56.0,
      padding: EdgeInsetsDirectional.fromSTEB(
          0.0, 0.0, 0.0, 0.0),
      iconPadding: EdgeInsetsDirectional.fromSTEB(
          0.0, 0.0, 0.0, 0.0),
      color: FlutterFlowTheme.of(context).tertiary,
      textStyle: FlutterFlowTheme.of(context)
          .titleSmall
          .override(
        fontFamily: 'SF',
        color: FlutterFlowTheme.of(context)
            .primaryBackground,
        letterSpacing: 0.0,
      ),
      elevation: 0.0,
      borderRadius: BorderRadius.circular(16.0),
    ),
      showLoadingIndicator: false,);
  }
}
