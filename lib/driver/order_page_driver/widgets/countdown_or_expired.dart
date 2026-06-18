import 'dart:async';
import 'package:flutter/material.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';

/// Widget that shows a countdown starting from [dateUpd].
/// If 10 minutes passed since [dateUpd], shows "Время истекло".
class CountdownOrExpired extends StatefulWidget {
  const CountdownOrExpired({
    Key? key,
    required this.dateUpd,
    this.style,
    this.expiredStyle,
    this.descriptionTextStyle,
    this.durationMinutes = 10,
  }) : super(key: key);

  final dynamic dateUpd;
  final TextStyle? style;
  final TextStyle? expiredStyle;
  final TextStyle? descriptionTextStyle;
  final int durationMinutes;

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
    final end = _start!.add(Duration(minutes: widget.durationMinutes));
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
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
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
      return Text(
        'Время истекло',
        style: widget.expiredStyle ?? FlutterFlowTheme.of(context).bodyMedium.override(color: FlutterFlowTheme.of(context).error),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Осталось до окончания: ${_formatDuration(_remaining!)}',
          style: widget.style ?? FlutterFlowTheme.of(context).bodyMedium.override(color: FlutterFlowTheme.of(context).accent1),
        ),
      ],
    );
  }
}