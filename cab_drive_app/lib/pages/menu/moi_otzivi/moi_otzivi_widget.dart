import 'dart:async';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/reviews_record_mapper.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/pages/bottom/otziv/otziv_widget.dart';
import '/pages/bottom/rew_empt/rew_empt_widget.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'moi_otzivi_model.dart';
export 'moi_otzivi_model.dart';

class MoiOtziviWidget extends StatefulWidget {
  const MoiOtziviWidget({super.key});

  @override
  State<MoiOtziviWidget> createState() => _MoiOtziviWidgetState();
}

class _MoiOtziviWidgetState extends State<MoiOtziviWidget> {
  late MoiOtziviModel _model;
  Timer? _poll;
  List<ReviewsRecord>? _reviews;
  bool _loading = true;
  bool _useFsFallback = false;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MoiOtziviModel());
    unawaited(_reload());
    _poll = Timer.periodic(const Duration(seconds: 8), (_) => _reload());
  }

  Future<void> _reload() async {
    try {
      final rows = await AppMeApi.listReviews(mine: true);
      if (!mounted) return;
      setState(() {
        _reviews = rows.map(ReviewsRecordMapper.fromApi).toList();
        _loading = false;
        _useFsFallback = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reviews = const [];
        _useFsFallback = false;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _model.maybeDispose();

    super.dispose();
  }

  Widget _buildList(List<ReviewsRecord> listViewReviewsRecordList) {
    if (listViewReviewsRecordList.isEmpty) {
      return Container(
        height: 900.0,
        child: RewEmptWidget(),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        50.0,
      ),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: listViewReviewsRecordList.length,
      separatorBuilder: (_, __) => SizedBox(height: 5.0),
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
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
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                  topLeft: Radius.circular(22.0),
                  topRight: Radius.circular(22.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
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
            Expanded(
              child: _loading
                  ? Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                    )
                  : _buildList(_reviews ?? const []),
            ),
          ].divide(SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
