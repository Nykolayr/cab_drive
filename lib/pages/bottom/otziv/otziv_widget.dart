import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'otziv_model.dart';
export 'otziv_model.dart';

class OtzivWidget extends StatefulWidget {
  const OtzivWidget({
    super.key,
    required this.rewDoc,
  });

  final ReviewsRecord? rewDoc;

  @override
  State<OtzivWidget> createState() => _OtzivWidgetState();
}

class _OtzivWidgetState extends State<OtzivWidget> {
  late OtzivModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OtzivModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 16.0, 24.0, 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                child: Text(
                  widget.rewDoc!.nameUserWhoWrote,
                  maxLines: 1,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 11.0),
                child: Text(
                  dateTimeFormat(
                    "relative",
                    widget.rewDoc!.date!,
                    locale: FFLocalizations.of(context).languageCode,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'SF',
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 7.0),
                child: RatingBarIndicator(
                  itemBuilder: (context, index) => Icon(
                    Icons.star_rounded,
                    color: () {
                      if (widget.rewDoc?.rating == 5) {
                        return const Color(0xFFFFB800);
                      } else if (widget.rewDoc?.rating == 4) {
                        return const Color(0xFFF68512);
                      } else if (widget.rewDoc?.rating == 3) {
                        return const Color(0xFFF0671C);
                      } else if (widget.rewDoc?.rating == 2) {
                        return const Color(0xFFE94627);
                      } else {
                        return const Color(0xFFE01935);
                      }
                    }(),
                  ),
                  direction: Axis.horizontal,
                  rating: widget.rewDoc!.rating.toDouble(),
                  unratedColor: const Color(0xFFE7E7E7),
                  itemCount: 5,
                  itemSize: 13.0,
                ),
              ),
              Text(
                widget.rewDoc!.text,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'SF',
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
