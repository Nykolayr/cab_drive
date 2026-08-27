import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/driver/create_otklick/create_otklick_widget.dart';
import '/driver/order_page_driver/order_page_driver_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'extra_order_bottom_sheet_model.dart';
export 'extra_order_bottom_sheet_model.dart';

/// Bottom sheet «Дополнительный заказ», показывается водителю когда у него
/// есть активный заказ и появляется новый, идущий «по пути».
///
/// Дизайн: Figma node 3022-4635.
class ExtraOrderBottomSheetWidget extends StatefulWidget {
  const ExtraOrderBottomSheetWidget({
    super.key,
    required this.order,
    required this.currentOrderId,
    this.deltaMin,
  });

  /// Доп.заказ, который предлагается принять.
  final OrderRecord order;

  /// ID активного заказа водителя (для контекста на бэке/логах).
  final String currentOrderId;

  /// Прирост времени маршрута в минутах (если посчитан).
  final double? deltaMin;

  @override
  State<ExtraOrderBottomSheetWidget> createState() =>
      _ExtraOrderBottomSheetWidgetState();
}

class _ExtraOrderBottomSheetWidgetState
    extends State<ExtraOrderBottomSheetWidget> {
  late ExtraOrderBottomSheetModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ExtraOrderBottomSheetModel());
    print(
      '[ExtraOrderBottomSheet.build] order_id=${widget.order.reference.id} '
      'current_order_id=${widget.currentOrderId} delta_min=${widget.deltaMin}',
    );
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _onTapAccept() async {
    if (_model.isSending) return;
    final orderId = widget.order.reference.id;
    final driverRef = currentUserReference;
    print('[ExtraOrderBottomSheet.respond] tap order_id=$orderId driver=${driverRef?.id}');

    if (driverRef == null) {
      _showError('Не удалось определить пользователя');
      return;
    }

    // Перед открытием формы отклика — освежаем статус, чтобы не открывать
    // сразу же на «протухшем» заказе.
    setState(() => _model.isSending = true);
    OrderRecord? fresh;
    try {
      fresh = await OrderRecord.getDocumentOnce(widget.order.reference);
    } catch (_) {
      fresh = widget.order;
    }
    if (!mounted) return;
    setState(() => _model.isSending = false);

    if (fresh.status != StatusOrder.newOrder) {
      _showError('Заказ уже принят другим водителем');
      Navigator.of(context).pop();
      return;
    }
    if (fresh.userWhoResponced.contains(driverRef)) {
      _showError('Вы уже откликнулись на этот заказ');
      Navigator.of(context).pop();
      return;
    }

    // Закрываем sheet «Дополнительный заказ» и открываем стандартную форму
    // отклика — там водитель указывает цену, комментарий и ETA.
    Navigator.of(context).pop();
    final rootCtx = Navigator.of(context, rootNavigator: true).context;
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: rootCtx,
      builder: (sheetCtx) {
        return Padding(
          padding: MediaQuery.viewInsetsOf(sheetCtx),
          child: CreateOtklickWidget(order: fresh),
        );
      },
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _onTapDetails() async {
    print('[ExtraOrderBottomSheet.details] tap order_id=${widget.order.reference.id}');
    final navigator = Navigator.of(context);
    navigator.pop();
    await navigator.push(
      MaterialPageRoute(
        builder: (_) => OrderPageDriverWidget(order: widget.order.reference),
      ),
    );
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final dayPart = DateFormat('d MMMM', 'ru').format(local);
    final timePart = DateFormat('HH:mm').format(local);
    return '$dayPart, в $timePart';
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final order = widget.order;
    final priceValue = order.currentPrice > 0 ? order.currentPrice : order.budget;
    final priceText = 'До $priceValue ₽';
    final dateText = _formatDateTime(order.dateTime ?? order.dateTimeCreated);
    final addressA = order.pointA.address.isNotEmpty
        ? order.pointA.address
        : 'Точка подачи';
    final addressB = order.pointB.address.isNotEmpty
        ? order.pointB.address
        : 'Точка назначения';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + close
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Дополнительный заказ',
                        style: theme.headlineSmall.override(
                          fontFamily: 'SF',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F2F4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Time row
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Color(0xFF6B6F76)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateText,
                        style: theme.bodyMedium.override(
                          fontFamily: 'SF',
                          letterSpacing: 0.0,
                          color: const Color(0xFF6B6F76),
                        ),
                      ),
                    ),
                    Text(
                      priceText,
                      style: theme.titleSmall.override(
                        fontFamily: 'SF',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: const Color(0xFFE6E8EC)),
                const SizedBox(height: 16),
                // Address A (blue outlined dot)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFF1574F5),
                          width: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        addressA,
                        style: theme.bodyMedium.override(
                          fontFamily: 'SF',
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Address B (green filled dot)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1FB35A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        addressB,
                        style: theme.bodyMedium.override(
                          fontFamily: 'SF',
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.deltaMin != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '+${widget.deltaMin!.toStringAsFixed(0)} мин к маршруту',
                    style: theme.bodySmall.override(
                      fontFamily: 'SF',
                      letterSpacing: 0.0,
                      color: const Color(0xFF6B6F76),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FFButtonWidget(
                  onPressed: _model.isSending ? null : _onTapAccept,
                  text: 'Откликнуться',
                  showLoadingIndicator: _model.isSending,
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 52,
                    color: const Color(0xFF1574F5),
                    textStyle: theme.titleSmall.override(
                      fontFamily: 'SF',
                      color: Colors.white,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                const SizedBox(height: 10),
                FFButtonWidget(
                  onPressed: _model.isSending ? null : _onTapDetails,
                  text: 'Детали',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 52,
                    color: const Color(0xFFF1F2F4),
                    textStyle: theme.titleSmall.override(
                      fontFamily: 'SF',
                      color: const Color(0xFF1574F5),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
