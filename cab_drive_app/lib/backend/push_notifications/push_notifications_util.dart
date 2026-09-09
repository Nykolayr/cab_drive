import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference;

import 'serialization_util.dart';
import '../../auth/firebase_auth/auth_util.dart';
import '../api/app_me_api.dart';
import '../cloud_functions/cloud_functions.dart';
import '../../core/utils/app_dio.dart';

import 'package:flutter/foundation.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

export 'push_notifications_handler.dart';
export 'serialization_util.dart';

const kUserPushNotificationsCollectionName = 'ff_user_push_notifications';

class UserTokenInfo {
  const UserTokenInfo(this.userPath, this.fcmToken);
  final String userPath;
  final String fcmToken;
}

Stream<UserTokenInfo> getFcmTokenStream(String userPath) =>
    Stream.value(!kIsWeb && (Platform.isIOS || Platform.isAndroid))
        .where((shouldGetToken) => shouldGetToken)
        .asyncMap<String?>((_) async {
          print('[FCM] Requesting notification permission...');
          final settings = await FirebaseMessaging.instance.requestPermission();
          print('[FCM] Permission status: ${settings.authorizationStatus}');
          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            final token = await FirebaseMessaging.instance.getToken();
            print('[FCM] Got token: ${token?.substring(0, 20)}...');
            return token;
          }
          print('[FCM] Permission not authorized, skipping token');
          return null;
        })
        .switchMap((fcmToken) => Stream.value(fcmToken)
            .merge(FirebaseMessaging.instance.onTokenRefresh))
        .where((fcmToken) => fcmToken != null && fcmToken.isNotEmpty)
        .map((token) => UserTokenInfo(userPath, token!));

final fcmTokenUserStream = authenticatedUserStream
    .where((user) => user != null)
    .map((user) {
      print('[FCM] User authenticated: ${user!.reference.path}');
      return user.reference.path;
    })
    .distinct()
    .switchMap(getFcmTokenStream)
    .asyncMap((userTokenInfo) async {
      print('[FCM] Registering token (PG + optional CF)...');
      print('[FCM] userDocPath: ${userTokenInfo.userPath}');
      print('[FCM] fcmToken: ${userTokenInfo.fcmToken.substring(0, 20)}...');
      print('[FCM] deviceType: ${Platform.isIOS ? 'iOS' : 'Android'}');

      // Primary: Postgres via /api/app/me/fcm
      try {
        final ok = await AppMeApi.registerFcm(userTokenInfo.fcmToken);
        print('[FCM] AppMeApi.registerFcm: $ok');
      } catch (e) {
        print('[FCM] ERROR AppMeApi.registerFcm: $e');
      }

      // Soft: keep CF for older builds / FS mirror until cutover complete
      try {
        final result = await makeCloudCall(
          'addFcmToken',
          {
            'userDocPath': userTokenInfo.userPath,
            'fcmToken': userTokenInfo.fcmToken,
            'deviceType': Platform.isIOS ? 'iOS' : 'Android',
          },
        );
        print('[FCM] Cloud Function result: $result');
        return result;
      } catch (e) {
        print('[FCM] ERROR calling addFcmToken: $e');
        return null;
      }
    });

void triggerPushNotification({
  required String? notificationTitle,
  required String? notificationText,
  String? notificationImageUrl,
  DateTime? scheduledTime,
  String? notificationSound,
  required List<DocumentReference> userRefs,
  required String initialPageName,
  required Map<String, dynamic> parameterData,
}) async {
  print('[PushNotification] triggerPushNotification called');
  print('[PushNotification] title: $notificationTitle');
  print('[PushNotification] userRefs count: ${userRefs.length}');
  print('[PushNotification] userRefs: ${userRefs.map((u) => u.path).toList()}');

  if ((notificationTitle ?? '').isEmpty || (notificationText ?? '').isEmpty) {
    print('[PushNotification] WARNING: Empty title or text, skipping');
    return;
  }
  if (userRefs.isEmpty) {
    print('[PushNotification] WARNING: No user refs, skipping');
    return;
  }
  final serializedParameterData = serializeParameterData(parameterData);
  final userIds = userRefs
      .map((u) => u.id)
      .where((id) => id.isNotEmpty)
      .toList();
  print('[PushNotification] Sending via AppMeApi.sendPush to $userIds');

  try {
    final ok = await AppMeApi.sendPush(
      title: notificationTitle!,
      text: notificationText!,
      userIds: userIds,
      initialPageName: initialPageName,
      parameterData: serializedParameterData,
    );
    print('[PushNotification] AppMeApi.sendPush: $ok');
    if (ok) return;
  } catch (e) {
    print('[PushNotification] ERROR AppMeApi.sendPush: $e');
  }
}

/// Отправляет push через /api/app/push (PG tokens). Legacy Dio path — fallback.
Future<void> sendPushToUsers({
  required String title,
  required String text,
  required List<String> userIds,
  Map<String, dynamic>? data,
}) async {
  print('[PushNotification] sendPushToUsers called');
  print('[PushNotification] title: $title');
  print('[PushNotification] userIds count: ${userIds.length}');
  print('[PushNotification] userIds: $userIds');

  if (userIds.isEmpty) {
    print('[PushNotification] WARNING: No user IDs provided, skipping');
    return;
  }

  try {
    final ok = await AppMeApi.sendPush(
      title: title,
      text: text,
      userIds: userIds,
      data: data,
      initialPageName: data?['initialPageName']?.toString(),
      parameterData: data?['parameterData']?.toString(),
    );
    print('[PushNotification] AppMeApi.sendPush: $ok');
    if (ok) return;
  } catch (e) {
    print('[PushNotification] ERROR AppMeApi.sendPush: $e');
  }

  // Legacy Dio → users/send_push_to_users (also PG-first on server now)
  try {
    final response = await AppDio.dio.post(
      'users/send_push_to_users',
      data: {
        'user_ids': userIds,
        'title': title,
        'text': text,
        if (data != null) 'data': data,
      },
    );
    print('[PushNotification] Legacy backend response: ${response.data}');
  } catch (e) {
    print('[PushNotification] ERROR legacy backend: $e');
  }
}
