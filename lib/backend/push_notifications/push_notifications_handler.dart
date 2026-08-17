import 'dart:async';
import 'dart:convert';

import 'serialization_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/driver/extra_order_bottom_sheet/extra_order_bottom_sheet_widget.dart';
import '/driver/services/extra_orders_dedup.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../index.dart';
import '../../main.dart';

final _handledMessageIds = <String?>{};

class PushNotificationsHandler extends StatefulWidget {
  const PushNotificationsHandler({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  _PushNotificationsHandlerState createState() =>
      _PushNotificationsHandlerState();
}

class _PushNotificationsHandlerState extends State<PushNotificationsHandler> {
  bool _loading = false;

  StreamSubscription<RemoteMessage>? _foregroundSub;

  Future handleOpenedPushNotification() async {
    if (isWeb) {
      return;
    }

    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      await _handlePushNotification(notification);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushNotification);
    // Foreground messages: маршрутизация data-only push-ов type=additional_order
    _foregroundSub ??= FirebaseMessaging.onMessage.listen(_maybeHandleExtraOrder);
  }

  Future<void> _maybeHandleExtraOrder(RemoteMessage message) async {
    final type = message.data['type'];
    if (type != 'additional_order') return;
    print('[push.additional_order] foreground received data=${message.data}');
    await _showExtraOrderSheet(message.data);
  }

  Future<void> _showExtraOrderSheet(Map<String, dynamic> data) async {
    final orderId = (data['order_id'] ?? '').toString();
    if (orderId.isEmpty) {
      print('[push.additional_order] missing order_id');
      return;
    }
    if (!ExtraOrdersDedup.tryAdd(orderId)) {
      return;
    }
    try {
      final ctx = appNavigatorKey.currentContext;
      if (ctx == null) {
        print('[push.additional_order] no navigator context — skip');
        ExtraOrdersDedup.forget(orderId);
        return;
      }

      final orderRef =
          FirebaseFirestore.instance.collection('order').doc(orderId);
      final order = await OrderRecord.getDocumentOnce(orderRef);
      if (order.status != StatusOrder.newOrder) {
        print('[push.additional_order] order ${orderId} no longer new '
            '(status=${order.status})');
        return;
      }

      String currentOrderId = (data['current_order_id'] ?? '').toString();
      if (currentOrderId.isEmpty) {
        currentOrderId = await _resolveActiveOrderId() ?? '';
      }
      if (currentOrderId.isEmpty) {
        print('[push.additional_order] driver has no active order — skip');
        ExtraOrdersDedup.forget(orderId);
        return;
      }

      final dynamic dm = data['delta_min'];
      final double? deltaMin = dm == null
          ? null
          : (dm is num ? dm.toDouble() : double.tryParse(dm.toString()));

      print('[push.additional_order] showing sheet order=$orderId '
          'current=$currentOrderId');
      await showModalBottomSheet<bool>(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ExtraOrderBottomSheetWidget(
          order: order,
          currentOrderId: currentOrderId,
          deltaMin: deltaMin,
        ),
      );
    } catch (e, st) {
      print('[push.additional_order] ERROR $e\n$st');
      ExtraOrdersDedup.forget(orderId);
    }
  }

  Future<String?> _resolveActiveOrderId() async {
    final uid = currentUserUid;
    if (uid.isEmpty) return null;
    final driverRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    final activeStatuses = [
      StatusOrder.spec_set.serialize(),
      StatusOrder.place_pickup.serialize(),
      StatusOrder.at_work.serialize(),
    ];
    final qs = await FirebaseFirestore.instance
        .collection('order')
        .where('selected_driver', isEqualTo: driverRef)
        .where('status', whereIn: activeStatuses)
        .limit(1)
        .get();
    if (qs.docs.isEmpty) return null;
    return qs.docs.first.id;
  }

  Future _handlePushNotification(RemoteMessage message) async {
    if (_handledMessageIds.contains(message.messageId)) {
      return;
    }
    _handledMessageIds.add(message.messageId);

    // Перехватываем data-сообщения о дополнительных заказах ещё до перехода
    // по initialPageName, чтобы показать bottom sheet вместо навигации.
    if (message.data['type'] == 'additional_order') {
      print('[push.additional_order] background opened, data=${message.data}');
      await _showExtraOrderSheet(message.data);
      return;
    }

    safeSetState(() => _loading = true);
    try {
      final initialPageName = message.data['initialPageName'] as String;
      final initialParameterData = getInitialParameterData(message.data);
      final parametersBuilder = parametersBuilderMap[initialPageName];
      if (parametersBuilder != null) {
        final parameterData = await parametersBuilder(initialParameterData);
        if (mounted) {
          context.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        } else {
          appNavigatorKey.currentContext?.pushNamed(
            initialPageName,
            pathParameters: parameterData.pathParameters,
            extra: parameterData.extra,
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      safeSetState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      handleOpenedPushNotification();
    });
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? Container(
          color: Colors.transparent,
          child: Image.asset(
            'assets/images/wx1aj_.jpg',
            fit: BoxFit.cover,
          ),
        )
      : widget.child;
}

class ParameterData {
  const ParameterData(
      {this.requiredParams = const {}, this.allParams = const {}});
  final Map<String, String?> requiredParams;
  final Map<String, dynamic> allParams;

  Map<String, String> get pathParameters => Map.fromEntries(
        requiredParams.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
  Map<String, dynamic> get extra => Map.fromEntries(
        allParams.entries.where((e) => e.value != null),
      );

  static Future<ParameterData> Function(Map<String, dynamic>) none() =>
      (data) async => ParameterData();
}

final parametersBuilderMap =
    <String, Future<ParameterData> Function(Map<String, dynamic>)>{
  'Onbord': ParameterData.none(),
  'LOGIN': ParameterData.none(),
  'OTP': (data) async => ParameterData(
        allParams: {
          'phone': getParameter<String>(data, 'phone'),
          'otp': getParameter<String>(data, 'otp'),
          'password': getParameter<String>(data, 'password'),
        },
      ),
  'Geo': (data) async => ParameterData(
        allParams: {
          'home': getParameter<int>(data, 'home'),
        },
      ),
  'Vibor': ParameterData.none(),
  'Verif_Driver': (data) async => ParameterData(
        allParams: {
          'home': getParameter<int>(data, 'home'),
        },
      ),
  'MAIN_USER': ParameterData.none(),
  'Detaliy_sozdanie': (data) async => ParameterData(
        allParams: <String, dynamic>{},
      ),
  'order_Page_Customer': (data) async => ParameterData(
        allParams: {
          'index': getParameter<int>(data, 'index'),
          'order': getParameter<DocumentReference>(data, 'order'),
        },
      ),
  'Chat': (data) async => ParameterData(
        allParams: {
          'chat': getParameter<DocumentReference>(data, 'chat'),
          'name': getParameter<String>(data, 'name'),
        },
      ),
  'zakaz_na_karte': (data) async => ParameterData(
        allParams: {
          'order': getParameter<DocumentReference>(data, 'order'),
        },
      ),
  'My_Orders': ParameterData.none(),
  'order_Page_Driver': (data) async => ParameterData(
        allParams: {
          'order': getParameter<DocumentReference>(data, 'order'),
        },
      ),
  'Profile': ParameterData.none(),
  'Nastroiki': ParameterData.none(),
  'Chats': ParameterData.none(),
  'Profil_admin': ParameterData.none(),
  'Detali_zayavki_Admin': (data) async => ParameterData(
        allParams: {
          'docref': getParameter<DocumentReference>(data, 'docref'),
        },
      ),
  'OTP_LOGIN': (data) async => ParameterData(
        allParams: {
          'phone': getParameter<String>(data, 'phone'),
          'otp': getParameter<String>(data, 'otp'),
          'password': getParameter<String>(data, 'password'),
        },
      ),
  'Chat_Admin': ParameterData.none(),
  'Verif_User': (data) async => ParameterData(
        allParams: {
          'home': getParameter<int>(data, 'home'),
        },
      ),
  'verif_admin': ParameterData.none(),
  'LOAD': ParameterData.none(),
  'MAIN_DRIVER': ParameterData.none(),
  'Onbord_driver': ParameterData.none(),
  'Onbord_user': ParameterData.none(),
};

Map<String, dynamic> getInitialParameterData(Map<String, dynamic> data) {
  try {
    final parameterDataStr = data['parameterData'];
    if (parameterDataStr == null ||
        parameterDataStr is! String ||
        parameterDataStr.isEmpty) {
      return {};
    }
    return jsonDecode(parameterDataStr) as Map<String, dynamic>;
  } catch (e) {
    print('Error parsing parameter data: $e');
    return {};
  }
}
