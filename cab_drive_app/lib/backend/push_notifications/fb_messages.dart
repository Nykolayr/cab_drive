import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

void handleNotificationClick(RemoteMessage message) async {
  final data = message.data;
  NotificationController.messageStream.add(data);
}

/// Returns platform-specific sound source path for notifications.
/// iOS: resource://name (awesome_notifications ищет .aiff файл в bundle)
/// Android: resource://raw/name
String _getNotificationSoundSource() {
  if (Platform.isIOS) {
    // iOS: awesome_notifications ищет файл с расширением .aiff в Bundle.main
    // Файл notify.aiff должен быть добавлен в Xcode project (Copy Bundle Resources)
    if (kDebugMode) {
      print('[FCM.sound] Platform: iOS, using resource://notify (will look for notify.aiff)');
    }
    return 'resource://notify';
  }
  if (kDebugMode) {
    print('[FCM.sound] Platform: Android, using resource://raw/notify');
  }
  return 'resource://raw/notify';
}

/// Background message handler for FCM.
/// This MUST be a top-level function (not a class method).
/// Called when app is in background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase (required for background isolate)
  await Firebase.initializeApp();

  print('[FCM.background] Received background message');
  print('[FCM.background] Message ID: ${message.messageId}');
  print('[FCM.background] Data: ${message.data}');

  // Get title and body from data (for data-only messages) or notification
  final data = message.data;
  final title = data['title'] ?? message.notification?.title ?? 'Новое уведомление';
  final body = data['body'] ?? message.notification?.body ?? '';

  print('[FCM.background] Title: $title, Body: $body');

  // Determine channel based on content
  final channelKey = _getBackgroundNotificationChannelKey(title, data);
  print('[FCM.background] Using channel: $channelKey');

  // Initialize AwesomeNotifications in background isolate
  await AwesomeNotifications().initialize(
    'resource://mipmap/launcher_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50B8),
        ledColor: Colors.white,
        playSound: true,
        importance: NotificationImportance.High,
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: 'orders_channel',
        channelName: 'Уведомления о заказах',
        channelDescription: 'Уведомления о новых заказах и изменениях статуса',
        defaultColor: Color(0xFF4CAF50),
        ledColor: Colors.green,
        playSound: true,
        soundSource: _getNotificationSoundSource(),
        importance: NotificationImportance.Max,
        enableVibration: true,
        criticalAlerts: true,
      ),
    ],
  );

  // Create notification with the correct channel
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: channelKey,
      title: title,
      body: body,
      payload: data.map((k, v) => MapEntry(k, v.toString())),
      notificationLayout: NotificationLayout.Default,
      wakeUpScreen: true,
    ),
  );

  print('[FCM.background] Notification created successfully on channel: $channelKey');
}

/// Determines notification channel for background messages
String _getBackgroundNotificationChannelKey(String title, Map<String, dynamic> data) {
  final titleLower = title.toLowerCase();
  final initialPage = data['initial_page_name'] ?? data['initialPageName'] ?? '';

  final isOrderNotification = titleLower.contains('заказ') ||
      titleLower.contains('order') ||
      titleLower.contains('отклик') ||
      titleLower.contains('статус') ||
      initialPage.toString().toLowerCase().contains('order');

  return isOrderNotification ? 'orders_channel' : 'basic_channel';
}

/// Initialize notification channels at app startup.
/// This is required for background notifications to have sound and vibration.
Future<void> initializeNotificationChannels() async {
  if (kDebugMode) {
    print('[FCM.init] Initializing notification channels at app startup...');
  }

  await AwesomeNotifications().initialize(
    'resource://mipmap/launcher_icon',
    [
      // Канал для обычных уведомлений
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50B8),
        ledColor: Colors.white,
        playSound: true,
        importance: NotificationImportance.High,
        enableVibration: true,
      ),
      // Канал для уведомлений о новых заказах (максимальный приоритет)
      NotificationChannel(
        channelKey: 'orders_channel',
        channelName: 'Уведомления о заказах',
        channelDescription: 'Уведомления о новых заказах и изменениях статуса',
        defaultColor: Color(0xFF4CAF50),
        ledColor: Colors.green,
        playSound: true,
        soundSource: _getNotificationSoundSource(),
        importance: NotificationImportance.Max,
        enableVibration: true,
        criticalAlerts: true,
      ),
    ],
  );

  // Set up notification listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
  );

  // Request notification permissions (especially important for iOS)
  final isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (kDebugMode) {
    print('[FCM.init] Notification permission allowed: $isAllowed');
  }

  if (!isAllowed) {
    if (kDebugMode) {
      print('[FCM.init] Requesting notification permission...');
    }
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  if (kDebugMode) {
    print('[FCM.init] Notification channels initialized successfully');
    print('[FCM.init] orders_channel configured with custom sound: ${_getNotificationSoundSource()}');
    print('[FCM.init] Platform: ${Platform.isIOS ? "iOS" : "Android"}');
  }
}

/// Определяет канал уведомления по заголовку и данным сообщения
/// Поддерживает как notification messages, так и data-only messages
String _getNotificationChannelKey(RemoteMessage message) {
  // Берём title из data (data-only) или из notification (legacy)
  final data = message.data;
  final title = (data['title'] ?? message.notification?.title ?? '').toString().toLowerCase();
  final initialPage = data['initial_page_name'] ?? data['initialPageName'] ?? '';

  // Уведомления о заказах используют канал orders_channel
  final isOrderNotification = title.contains('заказ') ||
      title.contains('order') ||
      title.contains('отклик') ||
      title.contains('статус') ||
      initialPage.toString().toLowerCase().contains('order');

  final channelKey = isOrderNotification ? 'orders_channel' : 'basic_channel';

  if (kDebugMode) {
    print('[FCM.channel] Title: "$title", InitialPage: "$initialPage" -> Channel: $channelKey');
  }

  return channelKey;
}

/// Показывает уведомление из FCM сообщения (foreground)
/// Поддерживает как notification messages, так и data-only messages
void showFlutterNotificationFromFirebase(RemoteMessage message) async {
  if (kIsWeb) return;

  final data = message.data;

  if (kDebugMode) {
    print('[FCM.show] Platform: ${Platform.isIOS ? "iOS" : "Android"}');
    print('[FCM.show] Has notification field: ${message.notification != null}');
    print('[FCM.show] Notification title: ${message.notification?.title}');
    print('[FCM.show] Data title: ${data['title']}');
  }

  // На iOS: если FCM отправил notification message (не data-only),
  // система покажет его через presentationOptions - не дублируем
  if (Platform.isIOS && message.notification != null) {
    if (kDebugMode) {
      print('[FCM.show] iOS: Skipping - system will show notification via presentationOptions');
    }
    return;
  }

  // Получаем title и body из data (data-only) или из notification (legacy)
  final title = data['title'] ?? message.notification?.title;
  final body = data['body'] ?? message.notification?.body;

  // Если нет ни title ни body - пропускаем
  if (title == null && body == null) {
    if (kDebugMode) {
      print('[FCM.show] Skipping: no title or body in message. Data: $data');
    }
    return;
  }

  final channelKey = _getNotificationChannelKey(message);

  if (kDebugMode) {
    print('[FCM.show] Creating notification: title="$title", body="$body", channel=$channelKey');
    print('[FCM.show] Data payload: $data');
  }

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      channelKey: channelKey,
      title: title,
      body: body,
      payload: data.map((a, b) => MapEntry(a, b.toString())),
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      notificationLayout: NotificationLayout.Default,
      wakeUpScreen: true,
    ),
  );

  if (kDebugMode) {
    print('[FCM.show] Notification created successfully on channel: $channelKey');
  }
}


class NotificationController {


  static StreamController<Map<String, dynamic>> messageStream = StreamController<Map<String, dynamic>>.broadcast();

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
    final data = receivedAction.payload;

    messageStream.add(data!);

  }
}