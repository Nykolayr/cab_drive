import '/admin/admin_vrf/admin_vrf_widget.dart';
import '/admin/navbar_admin/navbar_admin_widget.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'verif_admin_model.dart';
export 'verif_admin_model.dart';

class VerifAdminWidget extends StatefulWidget {
  const VerifAdminWidget({super.key});

  static String routeName = 'verif_admin';
  static String routePath = '/verifAdmin';

  @override
  State<VerifAdminWidget> createState() => _VerifAdminWidgetState();
}

class _VerifAdminWidgetState extends State<VerifAdminWidget> {
  late VerifAdminModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerifAdminModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: double.infinity,
              height: 120.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18.0),
                  bottomRight: Radius.circular(18.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        if (_model.index == 1) {
                          return;
                        }

                        _model.index = 1;
                        safeSetState(() {});
                        HapticFeedback.mediumImpact();
                        return;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: valueOrDefault<Color>(
                            _model.index == 1
                                ? FlutterFlowTheme.of(context).tertiary
                                : FlutterFlowTheme.of(context).primary,
                            FlutterFlowTheme.of(context).tertiary,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              18.0, 9.0, 18.0, 9.0),
                          child: Text(
                            'Новые',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  color: valueOrDefault<Color>(
                                    _model.index == 1
                                        ? FlutterFlowTheme.of(context).secondary
                                        : FlutterFlowTheme.of(context)
                                            .primaryText,
                                    FlutterFlowTheme.of(context).secondary,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        if (_model.index == 2) {
                          return;
                        }

                        _model.index = 2;
                        safeSetState(() {});
                        HapticFeedback.mediumImpact();
                        return;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: valueOrDefault<Color>(
                            _model.index == 2
                                ? FlutterFlowTheme.of(context).tertiary
                                : FlutterFlowTheme.of(context).primary,
                            FlutterFlowTheme.of(context).primary,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              18.0, 9.0, 18.0, 9.0),
                          child: Text(
                            'Архив',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'SF',
                                  color: valueOrDefault<Color>(
                                    _model.index == 2
                                        ? FlutterFlowTheme.of(context).secondary
                                        : FlutterFlowTheme.of(context)
                                            .primaryText,
                                    FlutterFlowTheme.of(context).primaryText,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ].divide(SizedBox(width: 8.0)),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<RequestVereficationRecord>>(
                stream: _model.verif(
                  requestFn: () => queryRequestVereficationRecord(
                    queryBuilder: (requestVereficationRecord) =>
                        requestVereficationRecord.orderBy('dateCreated',
                            descending: true),
                  ),
                ),
                builder: (context, snapshot) {
                  // Customize what your widget looks like when it's loading.
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                    );
                  }
                  List<RequestVereficationRecord>
                      containerRequestVereficationRecordList = snapshot.data!;

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(18.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Builder(
                        builder: (context) {
                          final containerVar =
                              containerRequestVereficationRecordList
                                  .where((e) => _model.index == 1
                                      ? (e.status == StatusVerif.onVerif)
                                      : (e.status != StatusVerif.onVerif))
                                  .toList();

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: containerVar.length,
                            separatorBuilder: (_, __) => SizedBox(height: 5.0),
                            itemBuilder: (context, containerVarIndex) {
                              final containerVarItem =
                                  containerVar[containerVarIndex];
                              return AdminVrfWidget(
                                key: Key(
                                    'Keyqiw_${containerVarIndex}_of_${containerVar.length}'),
                                doc: containerVarItem,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            wrapWithModel(
              model: _model.navbarAdminModel,
              updateCallback: () => safeSetState(() {}),
              child: NavbarAdminWidget(
                index: 2,
              ),
            ),
          ].divide(SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
