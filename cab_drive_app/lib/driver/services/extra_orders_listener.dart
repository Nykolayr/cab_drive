import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/driver/extra_order_bottom_sheet/extra_order_bottom_sheet_widget.dart';
import '/driver/services/extra_orders_dedup.dart';

/// Резервный канал доставки доп.заказов на случай потери FCM push:
/// слушает Firestore стрим newOrder, фильтрует «по пути» приближённо
/// (radius + tariff + queue) и сам показывает bottom sheet.
class ExtraOrdersListener {
  ExtraOrdersListener._();

  static final ExtraOrdersListener instance = ExtraOrdersListener._();

  /// Радиус поиска подходящего pointA относительно текущей позиции водителя.
  /// Синхронизировано с settings.extra_order_search_radius_km на backend.
  static double searchRadiusKm = 5.0;

  /// Максимальный размер очереди активных заказов на водителя.
  /// Синхронизировано с settings.driver_max_queue_size на backend.
  static int maxQueueSize = 2;

  StreamSubscription<List<OrderRecord>>? _sub;
  String? _activeOrderId;
  String _driverUid = '';
  String? _driverMark;
  LatLng? _driverLocation;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Обновляет текущую позицию водителя (вызывается из main_driver_widget
  /// при изменении geolocation).
  void updateDriverLocation(LatLng? loc) {
    _driverLocation = loc;
  }

  /// Запускается из main_driver_widget при наличии активного заказа.
  /// idempotent — повторный start() с теми же параметрами не пересоздаст стрим.
  void start({
    required String activeOrderId,
    required String driverUid,
    required String? driverMark,
    required LatLng? driverLocation,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    _driverLocation = driverLocation;
    if (_sub != null && _activeOrderId == activeOrderId && _driverUid == driverUid) {
      return;
    }
    stop();
    _activeOrderId = activeOrderId;
    _driverUid = driverUid;
    _driverMark = driverMark;
    _navigatorKey = navigatorKey;
    print('[ExtraOrdersListener.start] driver_uid=$driverUid '
        'current_order=$activeOrderId mark=$driverMark');

    _sub = queryOrderRecord(
      queryBuilder: (q) => q
          .where('status', isEqualTo: StatusOrder.newOrder.serialize())
          .orderBy('dateTime_created', descending: true),
      limit: 20,
    ).listen(_onSnapshot);
  }

  void stop() {
    if (_sub != null) {
      _sub?.cancel();
      _sub = null;
      print('[ExtraOrdersListener.stop] driver_uid=$_driverUid');
    }
    _activeOrderId = null;
    _driverUid = '';
    _driverMark = null;
    _navigatorKey = null;
  }

  Future<void> _onSnapshot(List<OrderRecord> orders) async {
    if (_activeOrderId == null) return;
    final navContext = _navigatorKey?.currentContext;
    if (navContext == null) return;

    final driverLoc = _driverLocation;
    final queue = currentUserDocument?.activeOrdersQueue ?? const [];
    if (queue.length >= maxQueueSize) {
      // очередь уже заполнена — ничего не предлагаем
      return;
    }

    for (final order in orders) {
      final id = order.reference.id;
      // Базовые быстрые фильтры
      if (order.userCustomer == currentUserReference) continue;
      if (order.selectedDriver != null) continue;
      // Совпадение тарифа
      if (_driverMark != null && _driverMark!.isNotEmpty) {
        if (order.car != null && order.car!.name != _driverMark) continue;
      }
      // Радиус по pointA
      if (driverLoc != null) {
        final pa = order.pointA;
        final lat = pa.latlng?.latitude;
        final lng = pa.latlng?.longitude;
        if (lat != null && lng != null) {
          final km = _haversineKm(
              driverLoc.latitude, driverLoc.longitude, lat, lng);
          if (km > searchRadiusKm) continue;
        }
      }
      // Persisted dedup: бэк/прошлая сессия уже уведомляли этого водителя по
      // этому заказу — повторно не показываем. Источник правды — Firestore-поле
      // extra_notified_drivers, оно переживает рестарт приложения и бэка.
      final notifiedDrivers = (order.snapshotData['extra_notified_drivers'] as List?) ?? const [];
      final alreadyNotified = _driverUid.isNotEmpty &&
          notifiedDrivers.any((e) => e?.toString() == _driverUid);
      if (alreadyNotified) {
        // подменяем в local dedup чтобы не пересчитывать на каждом тике стрима
        ExtraOrdersDedup.tryAdd(id);
        print('[ExtraOrdersListener.skip] persisted dedup hit '
            'order_id=$id driver=$_driverUid');
        continue;
      }

      // In-memory dedup общий с FCM-каналом
      if (!ExtraOrdersDedup.tryAdd(id)) continue;

      // Сразу пишем в Firestore чтобы при гонке backend / другая сессия
      // тоже видели нас в списке и не дублировали push.
      _persistNotified(order.reference, _driverUid);

      print('[ExtraOrdersListener.match] order_id=$id');
      _showSheet(navContext, order);
      // Показываем только один — следующий покажем на новом снапшоте, если останется в очереди.
      return;
    }
  }

  Future<void> _persistNotified(DocumentReference ref, String uid) async {
    if (uid.isEmpty) return;
    try {
      await ref.update({
        'extra_notified_drivers': FieldValue.arrayUnion([uid]),
        'extra_notified_at': FieldValue.serverTimestamp(),
      });
      print('[ExtraOrdersListener.persist] order_id=${ref.id} driver=$uid');
    } catch (e) {
      print('[ExtraOrdersListener.persist] failed order_id=${ref.id}: $e');
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

  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
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
