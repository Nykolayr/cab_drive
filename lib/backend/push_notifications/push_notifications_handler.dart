import 'dart:async';
import 'dart:convert';

import 'serialization_util.dart';
import '/backend/backend.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


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

  Future handleOpenedPushNotification() async {
    if (isWeb) {
      return;
    }

    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      await _handlePushNotification(notification);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushNotification);
  }

  Future _handlePushNotification(RemoteMessage message) async {
    if (_handledMessageIds.contains(message.messageId)) {
      return;
    }
    _handledMessageIds.add(message.messageId);

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
