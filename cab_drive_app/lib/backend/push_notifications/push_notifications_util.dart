import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart' show DocumentReference;

import 'serialization_util.dart';
import '../../auth/firebase_auth/auth_util.dart';
import '../api/app_me_api.dart';
import '../api/client_error_reporter.dart';
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

/// iOS: `getToken()` падает с `apns-token-not-set`, пока APNs-токен не пришёл.
/// Сначала ждём APNs-токен, затем берём FCM-токен с ретраями.
Future<String?> getFcmTokenSafe() async {
  final reporter = ClientErrorReporter.instance;
  if (Platform.isIOS) {
    String? apns;
    for (var i = 0; i < 20 && (apns == null || apns.isEmpty); i++) {
      try {
        apns = await FirebaseMessaging.instance.getAPNSToken();
      } catch (_) {}
      if (apns == null || apns.isEmpty) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    final got = apns != null && apns.isNotEmpty;
    reporter?.crumb('fcm', got ? 'apns_ok' : 'apns_timeout_20s');
    if (!got) return null;
  }
  for (var i = 0; i < 4; i++) {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        reporter?.crumb('fcm', 'fcm_token_ok');
        return token;
      }
    } catch (e) {
      reporter?.crumb('fcm', 'getToken_err_$i: $e');
    }
    if (i < 3) {
      await Future.delayed(const Duration(seconds: 3));
    }
  }
  reporter?.crumb('fcm', 'fcm_token_null');
  return null;
}

Stream<UserTokenInfo> getFcmTokenStream(String userPath) =>
    Stream.value(!kIsWeb && (Platform.isIOS || Platform.isAndroid))
        .where((shouldGetToken) => shouldGetToken)
        .asyncMap<String?>((_) async {
          print('[FCM] Requesting notification permission...');
          final settings = await FirebaseMessaging.instance.requestPermission();
          print('[FCM] Permission status: ${settings.authorizationStatus}');
          ClientErrorReporter.instance
              ?.crumb('fcm', 'perm=${settings.authorizationStatus}');
          if (settings.authorizationStatus == AuthorizationStatus.authorized) {
            final token = await getFcmTokenSafe();
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
        ClientErrorReporter.instance?.crumb('fcm', 'register=$ok');
        return ok;
      } catch (e) {
        print('[FCM] ERROR AppMeApi.registerFcm: $e');
        ClientErrorReporter.instance?.crumb('fcm', 'register_err: $e');
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
  final userIds =
      userRefs.map((u) => u.id).where((id) => id.isNotEmpty).toList();
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
