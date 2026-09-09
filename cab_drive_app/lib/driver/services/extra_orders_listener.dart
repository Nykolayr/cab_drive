import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/api/app_me_api.dart';
import '/backend/api/order_record_mapper.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/driver/extra_order_bottom_sheet/extra_order_bottom_sheet_widget.dart';
import '/driver/services/extra_orders_dedup.dart';

/// Резервный канал доставки доп.заказов при потере FCM:
/// poll `orders/feed` (Postgres API), без Firestore stream/writes.
/// Dedup meta пишет сервер (`extra_notified_*` в PG).
class ExtraOrdersListener {
  ExtraOrdersListener._();

  static final ExtraOrdersListener instance = ExtraOrdersListener._();

  /// Радиус поиска подходящего pointA относительно текущей позиции водителя.
  /// Синхронизировано с settings.extra_order_search_radius_km на backend.
  static double searchRadiusKm = 5.0;

  /// Максимальный размер очереди активных заказов на водителя.
  /// Синхронизировано с settings.driver_max_queue_size на backend.
  static int maxQueueSize = 2;

  static const Duration _pollInterval = Duration(seconds: 25);

  Timer? _pollTimer;
  String? _activeOrderId;
  String _driverUid = '';
  String? _driverMark;
  LatLng? _driverLocation;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _tickBusy = false;

  /// Обновляет текущую позицию водителя (вызывается из main_driver_widget
  /// при изменении geolocation).
  void updateDriverLocation(LatLng? loc) {
    _driverLocation = loc;
  }

  /// Запускается из main_driver_widget при наличии активного заказа.
  /// idempotent — повторный start() с теми же параметрами не пересоздаст poll.
  void start({
    required String activeOrderId,
    required String driverUid,
    required String? driverMark,
    required LatLng? driverLocation,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    _driverLocation = driverLocation;
    if (_pollTimer != null &&
        _activeOrderId == activeOrderId &&
        _driverUid == driverUid) {
      return;
    }
    stop();
    _activeOrderId = activeOrderId;
    _driverUid = driverUid;
    _driverMark = driverMark;
    _navigatorKey = navigatorKey;
    print('[ExtraOrdersListener.start] driver_uid=$driverUid '
        'current_order=$activeOrderId mark=$driverMark poll=api');

    _pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(_tick()));
    unawaited(_tick());
  }

  void stop() {
    if (_pollTimer != null) {
      _pollTimer?.cancel();
      _pollTimer = null;
      print('[ExtraOrdersListener.stop] driver_uid=$_driverUid');
    }
    _activeOrderId = null;
    _driverUid = '';
    _driverMark = null;
    _navigatorKey = null;
    _tickBusy = false;
  }

  Future<void> _tick() async {
    if (_tickBusy || _activeOrderId == null) return;
    _tickBusy = true;
    try {
      final navContext = _navigatorKey?.currentContext;
      if (navContext == null) return;

      final queue = effectiveActiveOrdersQueue;
      if (queue.length >= maxQueueSize) return;

      final rows = await AppMeApi.ordersFeed(status: 'newOrder');
      if (rows.isEmpty || _activeOrderId == null) return;

      final driverLoc = _driverLocation;
      for (final raw in rows) {
        final id = (raw['id'] ?? '').toString();
        if (id.isEmpty) continue;
        final order = OrderRecordMapper.fromApi(raw, id);
        if (order.status != StatusOrder.newOrder) continue;
        if (order.userCustomer?.id == _driverUid) continue;
        if (order.selectedDriver != null) continue;

        if (_driverMark != null && _driverMark!.isNotEmpty) {
          if (order.car != null && order.car!.name != _driverMark) continue;
        }

        if (driverLoc != null) {
          final pa = order.pointA;
          final lat = pa.latlng?.latitude;
          final lng = pa.latlng?.longitude;
          if (lat != null && lng != null) {
            final km = _haversineKm(
              driverLoc.latitude,
              driverLoc.longitude,
              lat,
              lng,
            );
            if (km > searchRadiusKm) continue;
          }
        }

        // Серверный dedup (PG raw_json); клиент — только in-memory с FCM.
        final notifiedDrivers =
            (order.snapshotData['extra_notified_drivers'] as List?) ?? const [];
        final alreadyNotified = _driverUid.isNotEmpty &&
            notifiedDrivers.any((e) => e?.toString() == _driverUid);
        if (alreadyNotified) {
          ExtraOrdersDedup.tryAdd(id);
          continue;
        }

        if (!ExtraOrdersDedup.tryAdd(id)) continue;

        print('[ExtraOrdersListener.match] order_id=$id');
        _showSheet(navContext, order);
        return;
      }
    } catch (e) {
      print('[ExtraOrdersListener.tick] error: $e');
    } finally {
      _tickBusy = false;
    }
  }

  void _showSheet(BuildContext ctx, OrderRecord order) {
    final currentOrderId = _activeOrderId ?? '';
    showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExtraOrderBottomSheetWidget(
        order: order,
        currentOrderId: currentOrderId,
      ),
    );
  }

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRad(double deg) => deg * (math.pi / 180.0);
}
