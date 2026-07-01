import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'net_chatov_model.dart';
export 'net_chatov_model.dart';

class NetChatovWidget extends StatefulWidget {
  const NetChatovWidget({super.key});

  @override
  State<NetChatovWidget> createState() => _NetChatovWidgetState();
}

class _NetChatovWidgetState extends State<NetChatovWidget> {
  late NetChatovModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NetChatovModel());
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
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
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
              'У вас пока нет чатов',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'SF',
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ].divide(SizedBox(height: 24.0)),
        ),
      ),
    );
  }
}
