import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'net_poiska_model.dart';
export 'net_poiska_model.dart';

class NetPoiskaWidget extends StatefulWidget {
  const NetPoiskaWidget({super.key});

  @override
  State<NetPoiskaWidget> createState() => _NetPoiskaWidgetState();
}

class _NetPoiskaWidgetState extends State<NetPoiskaWidget> {
  late NetPoiskaModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NetPoiskaModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Image.asset(
                'assets/images/freepik--Character--inject-2.png',
                width: 84.0,
                height: 155.0,
                fit: BoxFit.contain,
              ),
            ),
            Text(
              'Нет подходящих заказов.\nВозможно, дело в фильтрах',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              'Попробуйте убрать фильтры \nили поищите заказы позже',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ].divide(const SizedBox(height: 24.0)),
        ),
      ),
    );
  }
}
