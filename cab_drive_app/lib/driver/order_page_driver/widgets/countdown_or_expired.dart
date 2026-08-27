import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app_state.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';

/// Widget that shows a countdown starting from [dateUpd].
/// If [durationMinutes] (or `FFAppState().minutesForDeleteOrder` when null) passed since [dateUpd], shows "Время истекло".
class CountdownOrExpired extends StatefulWidget {
  const CountdownOrExpired({
    Key? key,
    required this.dateUpd,
    this.style,
    this.expiredStyle,
    this.descriptionTextStyle,
    this.durationMinutes,
    this.label,
    this.expiredText,
    this.hideWhenExpired = false,
  }) : super(key: key);

  final dynamic dateUpd;
  final TextStyle? style;
  final TextStyle? expiredStyle;
  final TextStyle? descriptionTextStyle;
  final int? durationMinutes;
  final String? label;
  final String? expiredText;
  final bool hideWhenExpired;

  int get effectiveDurationMinutes =>
      durationMinutes ?? FFAppState().minutesForDeleteOrder;

  @override
  State<CountdownOrExpired> createState() => _CountdownOrExpiredState();
}

class _CountdownOrExpiredState extends State<CountdownOrExpired> {
  Timer? _timer;
  Duration? _remaining;
  DateTime? _start;

  @override
  void initState() {
    super.initState();
    _start = _toDateTime(widget.dateUpd);
    _calculate();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant CountdownOrExpired oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newStart = _toDateTime(widget.dateUpd);
    if (newStart != _start) {
      _start = newStart;
      _calculate();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _calculate();
    });
  }

  void _calculate() {
    if (_start == null) {
      _remaining = null;
      return;
    }
    final end = _start!.add(Duration(minutes: widget.effectiveDurationMinutes));
    final now = DateTime.now();
    final diff = end.difference(now);
    _remaining = diff.isNegative ? Duration.zero : diff;
    if (_remaining == Duration.zero) {
      _timer?.cancel();
      _timer = null;
    }
  }

  DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try {
      final toDate = (v as dynamic).toDate;
      if (toDate is Function) {
        final res = (v as dynamic).toDate();
        if (res is DateTime) return res;
      }
    } catch (_) {}
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _formatDuration(Duration d) {
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    if (d.inDays >= 1) {
      final hours = d.inHours.remainder(24).toString().padLeft(2, '0');
      return '${d.inDays}д $hours:$minutes:$seconds';
    }
    if (d.inHours >= 1) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_start == null) {
      return Text(
        'Нет времени обновления',
        style: widget.descriptionTextStyle ?? FlutterFlowTheme.of(context).bodyMedium.override(color: FlutterFlowTheme.of(context).error),
      );
    }

    if (_remaining == null) {
      return SizedBox.shrink();
    }

    if (_remaining == Duration.zero) {
      if (widget.hideWhenExpired) return SizedBox.shrink();
      return Text(
        widget.expiredText ?? 'Время истекло',
        style: widget.expiredStyle ?? FlutterFlowTheme.of(context).bodyMedium.override(color: FlutterFlowTheme.of(context).error),
      );
    }

    final prefix = widget.label ?? 'Осталось до окончания:';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$prefix ${_formatDuration(_remaining!)}',
          style: widget.style ?? FlutterFlowTheme.of(context).bodyMedium.override(color: FlutterFlowTheme.of(context).accent1),
        ),
      ],
    );
  }
}