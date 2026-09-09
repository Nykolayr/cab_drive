import 'dart:async';

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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ratting_model.dart';
export 'ratting_model.dart';

class RattingWidget extends StatefulWidget {
  const RattingWidget({
    super.key,
    required this.user,
    required this.index,
  });

  final DocumentReference? user;
  final int? index;

  @override
  State<RattingWidget> createState() => _RattingWidgetState();
}

class _RattingWidgetState extends State<RattingWidget> {
  late RattingModel _model;
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
    _model = createModel(context, () => RattingModel());
    unawaited(_reload());
    _poll = Timer.periodic(const Duration(seconds: 8), (_) => _reload());
  }

  Future<void> _reload() async {
    final uid = widget.user?.id;
    if (uid == null || uid.isEmpty) return;
    try {
      final rows = await AppMeApi.listReviews(aboutUserId: uid);
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

  Widget _buildReviewsBody(List<ReviewsRecord> containerReviewsRecordList) {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(),
        child: SingleChildScrollView(
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                RatingBarIndicator(
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFB800),
                                  ),
                                  direction: Axis.horizontal,
                                  rating: 5.0,
                                  unratedColor: Color(0xFFE7E7E7),
                                  itemCount: 5,
                                  itemPadding: EdgeInsets.fromLTRB(
                                      1.0, 0.0, 1.0, 0.0),
                                  itemSize: 14.0,
                                ),
                                Text(
                                  containerReviewsRecordList
                                      .where((e) => e.rating == 5)
                                      .toList()
                                      .length
                                      .toString(),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                RatingBarIndicator(
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFF68512),
                                  ),
                                  direction: Axis.horizontal,
                                  rating: 4.0,
                                  unratedColor: Color(0xFFE7E7E7),
                                  itemCount: 5,
                                  itemPadding: EdgeInsets.fromLTRB(
                                      1.0, 0.0, 1.0, 0.0),
                                  itemSize: 14.0,
                                ),
                                Text(
                                  valueOrDefault<String>(
                                    containerReviewsRecordList
                                        .where((e) => e.rating == 4)
                                        .toList()
                                        .length
                                        .toString(),
                                    '0',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                RatingBarIndicator(
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFF0671C),
                                  ),
                                  direction: Axis.horizontal,
                                  rating: 3.0,
                                  unratedColor: Color(0xFFE7E7E7),
                                  itemCount: 5,
                                  itemPadding: EdgeInsets.fromLTRB(
                                      1.0, 0.0, 1.0, 0.0),
                                  itemSize: 14.0,
                                ),
                                Text(
                                  valueOrDefault<String>(
                                    containerReviewsRecordList
                                        .where((e) => e.rating == 3)
                                        .toList()
                                        .length
                                        .toString(),
                                    '0',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                RatingBarIndicator(
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFE94627),
                                  ),
                                  direction: Axis.horizontal,
                                  rating: 2.0,
                                  unratedColor: Color(0xFFE7E7E7),
                                  itemCount: 5,
                                  itemPadding: EdgeInsets.fromLTRB(
                                      1.0, 0.0, 1.0, 0.0),
                                  itemSize: 14.0,
                                ),
                                Text(
                                  valueOrDefault<String>(
                                    containerReviewsRecordList
                                        .where((e) => e.rating == 2)
                                        .toList()
                                        .length
                                        .toString(),
                                    '0',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                RatingBarIndicator(
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFE01935),
                                  ),
                                  direction: Axis.horizontal,
                                  rating: 1.0,
                                  unratedColor: Color(0xFFE7E7E7),
                                  itemCount: 5,
                                  itemPadding: EdgeInsets.fromLTRB(
                                      1.0, 0.0, 1.0, 0.0),
                                  itemSize: 14.0,
                                ),
                                Text(
                                  valueOrDefault<String>(
                                    containerReviewsRecordList
                                        .where((e) => e.rating == 1)
                                        .toList()
                                        .length
                                        .toString(),
                                    '0',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          ].divide(SizedBox(height: 10.0)),
                        ),
                      ),
                    ].divide(SizedBox(height: 12.0)),
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  final rews = containerReviewsRecordList.toList();
                  if (rews.isEmpty) {
                    return Center(
                      child: Container(
                        height: 650.0,
                        child: RewEmptWidget(),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    primary: false,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: rews.length,
                    separatorBuilder: (_, __) => SizedBox(height: 5.0),
                    itemBuilder: (context, rewsIndex) {
                      final rewsItem = rews[rewsIndex];
                      return OtzivWidget(
                        key: Key(
                            'Keypik_${rewsIndex}_of_${rews.length}'),
                        rewDoc: rewsItem,
                      );
                    },
                  );
                },
              ),
            ].divide(SizedBox(height: 5.0)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
      child: Container(
        width: double.infinity,
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
                      () {
                        if (widget!.index == 1) {
                          return 'Отзывы о водителе';
                        } else if (widget!.index == 2) {
                          return 'Отзывы о заказчике';
                        } else {
                          return 'Отзывы';
                        }
                      }(),
                      textAlign: TextAlign.start,
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
                      hoverColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
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
                  : _buildReviewsBody(_reviews ?? const []),
            ),
          ].divide(SizedBox(height: 5.0)),
        ),
      ),
    );
  }
}
