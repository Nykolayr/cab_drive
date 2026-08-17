import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/driver/order_page_driver/order_page_driver_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Показывает компактный chip «В очереди: N заказ» на странице активного
/// заказа, если у водителя есть дополнительные заказы в active_orders_queue.
class QueueIndicatorWidget extends StatelessWidget {
  const QueueIndicatorWidget({super.key, required this.currentOrderRef});

  /// Reference на текущий заказ (его не показываем как «следующий»).
  final DocumentReference currentOrderRef;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final userRef = currentUserReference;
    if (userRef == null) return const SizedBox.shrink();

    return StreamBuilder<UsersRecord>(
      stream: UsersRecord.getDocument(userRef),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final queue = snapshot.data!.activeOrdersQueue
            .where((r) => r.id != currentOrderRef.id)
            .toList();
        if (queue.isEmpty) return const SizedBox.shrink();
        print('[QueueIndicator.build] queue_size=${queue.length}');

        final nextRef = queue.first;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: InkWell(
            onTap: () => _openNextOrder(context, nextRef),
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
      },
    );
  }

  Future<void> _openNextOrder(BuildContext ctx, DocumentReference ref) async {
    print('[QueueIndicator.openNext] order_id=${ref.id}');
    await Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => OrderPageDriverWidget(order: ref),
      ),
    );
  }
}
