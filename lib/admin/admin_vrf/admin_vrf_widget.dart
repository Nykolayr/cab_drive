import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'admin_vrf_model.dart';
export 'admin_vrf_model.dart';

class AdminVrfWidget extends StatefulWidget {
  const AdminVrfWidget({
    super.key,
    required this.doc,
  });

  final RequestVereficationRecord? doc;

  @override
  State<AdminVrfWidget> createState() => _AdminVrfWidgetState();
}

class _AdminVrfWidgetState extends State<AdminVrfWidget> {
  late AdminVrfModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminVrfModel());
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
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(22.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 18.0, 8.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.doc?.surname} ${widget.doc?.name}',
                    maxLines: 1,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    '${() {
                      if (widget.doc?.marka == Car.largus) {
                        return 'LADA Largus';
                      } else if (widget.doc?.marka == Car.largusTermo) {
                        return 'LADA Largus с термо будкой';
                      } else {
                        return 'Fiat Doblò/Citroën Berlingo/PEUGEOT PARTNER ';
                      }
                    }()} - ${widget.doc?.numberAvto}',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'SF',
                          color: const Color(0xFFA4A6B2),
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ].divide(const SizedBox(height: 2.0)),
              ),
            ),
            const Divider(
              height: 0.3,
              thickness: 0.3,
              color: Color(0xFFD0CFCE),
            ),
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 13.0, 0.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () async {
                        context.pushNamed(
                          DetaliZayavkiAdminWidget.routeName,
                          queryParameters: {
                            'docref': serializeParam(
                              widget.doc?.reference,
                              ParamType.DocumentReference,
                            ),
                          }.withoutNulls,
                        );
                      },
                      text: 'Детали',
                      options: FFButtonOptions(
                        height: 45.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'SF',
                                  color: FlutterFlowTheme.of(context).tertiary,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      showLoadingIndicator: false,
                    ),
                  ),
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () async {
                        await widget.doc!.user!.update(createUsersRecordData(
                          onVerifNow: false,
                          verifCompl: true,
                        ));

                        await widget.doc!.reference
                            .update(createRequestVereficationRecordData(
                          status: StatusVerif.Completed,
                        ));
                      },
                      text: 'Одобрить',
                      options: FFButtonOptions(
                        height: 45.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).tertiary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'SF',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontSize: 15.0,
                                  letterSpacing: 0.0,
                                ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ].divide(const SizedBox(width: 7.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
