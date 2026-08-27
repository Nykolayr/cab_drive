import 'package:cab_drive/auth/firebase_auth/auth_util.dart';
import 'package:cab_drive/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../backend/schema/order_record.dart';
import '../../../../flutter_flow/flutter_flow_theme.dart';
import '../data/payment_history_data.dart';

class PaymentHistoryWidget extends StatefulWidget {
  const PaymentHistoryWidget({Key? key}) : super(key: key);

  @override
  _PaymentHistoryWidgetState createState() => _PaymentHistoryWidgetState();

  static show(BuildContext context) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => PaymentHistoryWidget(),
      );
}

class _PaymentHistoryWidgetState extends State<PaymentHistoryWidget> {
  final PaymentHistoryData _data = PaymentHistoryData();
  late DateTime _currentMonth;
  double _totalEarnings = 0.0;
  double _totalCommission = 0.0;
  List<OrderRecord> _transactions = [];
  final NumberFormat _moneyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _loadTransactions();
  }

  DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _startOfNextMonth(DateTime d) => DateTime(d.year, d.month + 1, 1);

  Future<void> _loadTransactions() async {
    final start = _startOfMonth(_currentMonth);
    final end = _startOfNextMonth(_currentMonth);
    final orders = await _data.fetchUserOrders(start, end);

    // sort descending by date
    final sorted = List<OrderRecord>.from(orders)
      ..sort((a, b) {
        final da = _extractDate(a);
        final db = _extractDate(b);
        return db.compareTo(da); // descending
      });

    final earnings = sorted.fold<double>(
      0.0,
      (sum, o) => sum + (_safeDouble(o.currentPrice)),
    );

    final commission = sorted.fold<double>(
      0.0,
      (sum, o) => sum + (_safeDouble(o.currentPrice) * ((_safeDouble(o.commissionPercent)) / 100.0)),
    );

    if (!mounted) return;
    setState(() {
      _transactions = List.unmodifiable(sorted);
      _totalEarnings = double.parse(earnings.toStringAsFixed(2));
      _totalCommission = double.parse(commission.toStringAsFixed(2));
    });
  }

  double _safeDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  DateTime _extractDate(OrderRecord o) {
    try {
      final dt = o.dateTimeCreated;
      if (dt == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (dt is DateTime) return dt;
      // assume Timestamp-like
      return dt;
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  Future<void> _loadPreviousMonth() async {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    await _loadTransactions();
  }

  Future<void> _loadNextMonth() async {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    await _loadTransactions();
  }

  String _monthTitle(DateTime d) => DateFormat.yMMMM('ru').format(d);

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _monthTitle(_currentMonth),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_transactions.length} транзакций',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _loadPreviousMonth,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _loadNextMonth,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF4FC3F7), FlutterFlowTheme.of(context).tertiary,]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Заработано', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    '${_moneyFormat.format(_totalEarnings)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Комиссия', style: TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    '${_moneyFormat.format(_totalCommission)}',
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(OrderRecord order) {
    final date = _extractDate(order);
    final title = (_safeDouble(order.currentPrice) == 0.0)
        ? 'Без оплаты'
        : '${_moneyFormat.format(_safeDouble(order.currentPrice))}';
    final commission = _safeDouble(order.commissionPercent);
    final commissionText = commission > 0 ? '${commission.toStringAsFixed(0)}%' : '—';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).tertiary,

              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.local_taxi, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ком ${commissionText}',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd MMM, HH:mm', 'ru').format(date),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                _buildHandle(),
                _buildHeader(),
                _buildTotals(),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                     /* if (!scrollInfo.metrics.atEdge) return false;
                      final atBottom = scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent;
                      if (atBottom) {
                        _loadPreviousMonth();
                        return true;
                      }*/
                      return false;
                    },
                    child: _transactions.isEmpty
                        ? ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            children: [
                              SizedBox(
                                height: 120,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.receipt_long, size: 48, color: Colors.blue[200]),
                                      const SizedBox(height: 12),
                                      Text('Транзакций нет', style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(bottom: 24, top: 8),
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final order = _transactions[index];
                              return _buildTransactionItem(order);
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}