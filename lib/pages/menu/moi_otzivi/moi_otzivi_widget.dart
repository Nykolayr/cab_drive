import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/bottom/otziv/otziv_widget.dart';
import '/pages/bottom/rew_empt/rew_empt_widget.dart';
import 'package:flutter/material.dart';
import 'moi_otzivi_model.dart';
export 'moi_otzivi_model.dart';

class MoiOtziviWidget extends StatefulWidget {
  const MoiOtziviWidget({super.key});

  @override
  State<MoiOtziviWidget> createState() => _MoiOtziviWidgetState();
}

class _MoiOtziviWidgetState extends State<MoiOtziviWidget> {
  late MoiOtziviModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MoiOtziviModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22.0),
            topRight: Radius.circular(22.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 64.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22.0),
                  topRight: Radius.circular(22.0),
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Мои отзывы',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'SF',
                            fontSize: 21.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    FlutterFlowIconButton(
                      borderColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: 54.0,
                      borderWidth: 0.0,
                      buttonSize: 32.0,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      hoverColor: FlutterFlowTheme.of(context).primary,
                      hoverIconColor: FlutterFlowTheme.of(context).primaryText,
                      icon: Icon(
                        FFIcons.kkrestStroke,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 8.0,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<List<ReviewsRecord>>(
              stream: queryReviewsRecord(
                queryBuilder: (reviewsRecord) => reviewsRecord
                    .where(
                      'user_who_wrote_the_review',
                      isEqualTo: currentUserReference,
                    )
                    .orderBy('date', descending: true),
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
                List<ReviewsRecord> listViewReviewsRecordList = snapshot.data!;
                if (listViewReviewsRecordList.isEmpty) {
                  return const SizedBox(
                    height: 900.0,
                    child: RewEmptWidget(),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    50.0,
                  ),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: listViewReviewsRecordList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 5.0),
                  itemBuilder: (context, listViewIndex) {
                    final listViewReviewsRecord =
                        listViewReviewsRecordList[listViewIndex];
                    return OtzivWidget(
                      key: Key(
                          'Keybnb_${listViewIndex}_of_${listViewReviewsRecordList.length}'),
                      rewDoc: listViewReviewsRecord,
                    );
                  },
                );
              },
            ),
          ].divide(const SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
