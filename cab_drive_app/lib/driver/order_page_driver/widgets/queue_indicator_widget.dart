import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/driver/order_page_driver/order_page_driver_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Показывает компактный chip «В очереди: N заказ» на странице активного
/// заказа, если у водителя есть дополнительные заказы в active_orders_queue.
class QueueIndicatorWidget extends StatefulWidget {
  const QueueIndicatorWidget({super.key, required this.currentOrderRef});

  /// Reference на текущий заказ (его не показываем как «следующий»).
  final DocumentReference currentOrderRef;

  @override
  State<QueueIndicatorWidget> createState() => _QueueIndicatorWidgetState();
}

class _QueueIndicatorWidgetState extends State<QueueIndicatorWidget> {
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    unawaited(refreshAppMeCache());
    _poll = Timer.periodic(const Duration(seconds: 5), (_) async {
      await refreshAppMeCache();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final queue = effectiveActiveOrdersQueue
        .where((id) => id != widget.currentOrderRef.id)
        .toList();
    if (queue.isEmpty) return const SizedBox.shrink();
    print('[QueueIndicator.build] queue_size=${queue.length}');

    final nextId = queue.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: InkWell(
        onTap: () => _openNextOrder(context, nextId),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCFE3FE)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.queue_play_next,
                size: 20,
                color: Color(0xFF1574F5),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'В очереди: ${queue.length} заказ',
                  style: theme.bodyMedium.override(
                    fontFamily: 'SF',
                    letterSpacing: 0.0,
                    color: const Color(0xFF1574F5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF1574F5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNextOrder(BuildContext ctx, String orderId) async {
    print('[QueueIndicator.openNext] order_id=$orderId');
    await Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => OrderPageDriverWidget(
          order: OrderRecord.collection.doc(orderId),
        ),
      ),
    );
  }
}
