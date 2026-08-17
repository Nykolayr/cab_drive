import 'dart:async';

import '/backend/api/file_storage_service.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'response_model.dart';
export 'response_model.dart';

class ResponseWidget extends StatefulWidget {
  const ResponseWidget({
    super.key,
    required this.responseDT,
    this.order,
    this.onAccept,
    this.onReject,
  });

  final ResponsesRecord? responseDT;
  final OrderRecord? order;
  final Future<void> Function()? onAccept;
  final Future<void> Function()? onReject;

  @override
  State<ResponseWidget> createState() => _ResponseWidgetState();
}

class _ResponseWidgetState extends State<ResponseWidget> {
  late ResponseModel _model;
  Timer? _ticker;

  // The order is deactivated 20 min after its last update.
  static const Duration _deactivationWindow = Duration(minutes: 20);

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ResponseModel());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _model.maybeDispose();
    super.dispose();
  }

  double get _remainingFraction {
    final reference =
        widget.order?.dateUpd ?? widget.responseDT?.dateCreated;
    if (reference == null) return 1.0;
    final elapsed = DateTime.now().difference(reference);
    final remainingMs =
        _deactivationWindow.inMilliseconds - elapsed.inMilliseconds;
    if (remainingMs <= 0) return 0.0;
    return (remainingMs / _deactivationWindow.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UsersRecord>(
      future: UsersRecord.getDocumentOnce(widget.responseDT!.userDriver!),
      builder: (context, snapshot) {
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

        final driver = snapshot.data!;

        return Container(
          decoration: const BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 57.0,
                    height: 78.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: const Color(0x26969EAB),
                        width: 0.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedNetworkImage(
                        fadeInDuration: const Duration(milliseconds: 5),
                        fadeOutDuration: const Duration(milliseconds: 5),
                        imageUrl: FileStorageService.getImageUrl(
                            driver.photoUrl),
                        width: 57.0,
                        height: 78.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          12.0, 0.0, 0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  driver.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'SF',
                                        color: const Color(0xFF0C0C0C),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              Text(
                                dateTimeFormat(
                                  'Hm',
                                  widget.responseDT!.dateCreated!,
                                  locale:
                                      FFLocalizations.of(context).languageCode,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'SF',
                                      color: const Color(0xFFA4A6B2),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 6.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _StatChip(
                                      icon: const Icon(
                                        Icons.star_rounded,
                                        color: Color(0xFFFFB800),
                                        size: 16.0,
                                      ),
                                      label: formatNumber(
                                        driver.averageRating,
                                        formatType: FormatType.custom,
                                        format: '0.00',
                                        locale: '',
                                      ),
                                    ),
                                    const SizedBox(width: 4.0),
                                    _StatChip(
                                      icon: Image.asset(
                                        'assets/images/chat_feedback.png',
                                        width: 16.0,
                                        height: 16.0,
                                      ),
                                      label:
                                          driver.numberOfReviews.toString(),
                                    ),
                                  ],
                                ),
                                if (!widget.responseDT!.viewed)
                                  Container(
                                    width: 20.0,
                                    height: 20.0,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE01935),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      '1',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'SF',
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 6.0, 0.0, 0.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).tertiary,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  8.0, 2.0, 8.0, 2.0),
                              child: Text(
                                'Стоимость ${widget.responseDT!.price} руб',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'SF',
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    0.0, 12.0, 0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _OutlinedActionButton(
                        text: 'Отклонить',
                        onTap: widget.onReject,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: _TimerGradientButton(
                        text: 'Принять',
                        remainingFraction: _remainingFraction,
                        onTap: widget.onAccept,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    0.0, 16.0, 0.0, 0.0),
                child: Container(
                  height: 2.0,
                  color: const Color(0xFFF4F5F8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F8),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(6.0, 0.0, 8.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 2.0),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFFA4A6B2),
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({required this.text, this.onTap});

  final String text;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: onTap == null ? null : () => onTap!(),
        child: Container(
          height: 42.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F8),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF',
              color: FlutterFlowTheme.of(context).tertiary,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerGradientButton extends StatelessWidget {
  const _TimerGradientButton({
    required this.text,
    required this.remainingFraction,
    this.onTap,
  });

  final String text;

  // 1.0 = full time remaining (whole button is the bright blue),
  // 0.0 = expired (whole button is the darker blue).
  final double remainingFraction;
  final Future<void> Function()? onTap;

  static const Color _activeColor = Color(0xFF007AFF);
  static const Color _elapsedColor = Color(0xFF004999);

  @override
  Widget build(BuildContext context) {
    final stop = remainingFraction.clamp(0.0, 1.0);
    final isExpired = stop <= 0.0;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: (onTap == null || isExpired) ? null : () => onTap!(),
        child: Container(
          height: 42.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [stop, stop],
              colors: const [_activeColor, _elapsedColor],
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'SF',
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
