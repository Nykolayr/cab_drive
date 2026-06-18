import 'package:cab_drive/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

import '../../../flutter_flow/flutter_flow_icon_button.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../pages/my_orders/my_orders_widget.dart';

class EditAppBar extends StatelessWidget {
  const EditAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18.0),
          bottomRight: Radius.circular(18.0),
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
      ),
      child: Align(
        alignment: AlignmentDirectional(0.0, 1.0),
        child: Padding(
          padding:
          EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 12.0),
          child: Container(
            width: double.infinity,
            height: 56.0,
            decoration: BoxDecoration(
              color: Color(0xFFF4F5F8),
              borderRadius: BorderRadius.circular(88.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  FlutterFlowIconButton(
                    borderRadius: 88.0,
                    buttonSize: 48.0,
                    fillColor: FlutterFlowTheme.of(context)
                        .secondaryBackground,
                    icon: Icon(
                      FFIcons.kiconStroke,
                      color:
                      FlutterFlowTheme.of(context).primaryText,
                      size: 12.0,
                    ),
                    onPressed: () async {

                        context.safePop();
                        return;

                    },
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          8.0, 0.0, 0.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context)
                              .secondaryBackground,
                          borderRadius: BorderRadius.circular(88.0),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            "Редактировать заказ",
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                              fontFamily: 'SF',
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
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
