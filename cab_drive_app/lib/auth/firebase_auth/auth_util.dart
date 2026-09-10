import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/backend/api/app_me_api.dart';
import '/backend/api/file_storage_service.dart';
import '/backend/api/users_record_mapper.dart';
import '/backend/backend.dart';
import 'firebase_auth_manager.dart';

export 'firebase_auth_manager.dart';

final _authManager = FirebaseAuthManager();
FirebaseAuthManager get authManager => _authManager;

String get currentUserEmail =>
    currentUserDocument?.email ?? currentUser?.email ?? '';

String get currentUserUid => currentUser?.uid ?? '';

String get currentUserDisplayName {
  final fromDoc = (currentUserDocument?.displayName ?? '').trim();
  if (fromDoc.isNotEmpty) return fromDoc;
  return (currentUser?.displayName ?? '').trim();
}

String get currentUserPhoto {
  final photoUrl = currentUserDocument?.photoUrl ?? currentUser?.photoUrl ?? '';
  if (photoUrl.isEmpty) return '';
  return FileStorageService.getImageUrl(photoUrl);
}

String get currentPhoneNumber {
  final fromDoc = (currentUserDocument?.phoneNumber ?? '').trim();
  if (fromDoc.isNotEmpty) return fromDoc;
  return (currentUser?.phoneNumber ?? '').trim();
}
String get currentJwtToken => _currentJwtToken ?? '';

bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;

/// Баланс: приоритет API (Postgres), иначе Firestore-документ.
double get effectiveBalance =>
    appMeCache?.balance ?? currentUserDocument?.balance ?? 0.0;

double get effectiveBonusBalance =>
    appMeCache?.bonusBalance ?? currentUserDocument?.bonusBalance ?? 0.0;

bool get effectiveOnShift =>
    appMeCache?.onShift ?? currentUserDocument?.onShift ?? false;

/// Очередь активных заказов водителя: API (Postgres) → FS fallback.
List<String> get effectiveActiveOrdersQueue {
  if (appMeCache != null) {
    return List<String>.from(appMeCache!.activeOrdersQueue);
  }
  final fromFs = currentUserDocument?.activeOrdersQueue;
  if (fromFs == null || fromFs.isEmpty) return const [];
  return fromFs.map((r) => r.id).toList();
}

/// Create a Stream that listens to the current user's JWT Token, since Firebase
/// generates a new token every hour.
String? _currentJwtToken;
final jwtTokenStream = FirebaseAuth.instance
    .idTokenChanges()
    .map((user) async => _currentJwtToken = await user?.getIdToken())
    .asBroadcastStream();

DocumentReference? get currentUserReference =>
    loggedIn ? UsersRecord.collection.doc(currentUser!.uid) : null;

UsersRecord? currentUserDocument;

Map<String, dynamic>? _lastMeRaw;
final _userDocController = StreamController<UsersRecord?>.broadcast();
// ignore: unused_element - keep auth subscription for app lifetime
StreamSubscription<User?>? _authSub;
Timer? _mePollTimer;
bool _sessionWired = false;

void _emitMerged() {
  if (_lastMeRaw != null) {
    // previous = текущий документ (между poll'ами), не Firestore stream
    currentUserDocument = UsersRecordMapper.fromMeApi(
      _lastMeRaw!,
      previous: currentUserDocument,
    );
  }
  if (!_userDocController.isClosed) {
    _userDocController.add(currentUserDocument);
  }
}

void ensureAuthenticatedUserSession() {
  if (_sessionWired) return;
  _sessionWired = true;
  _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
    _mePollTimer?.cancel();
    _mePollTimer = null;
    _lastMeRaw = null;

    if (user == null) {
      currentUserDocument = null;
      appMeCache = null;
      if (!_userDocController.isClosed) {
        _userDocController.add(null);
      }
      return;
    }

    // Сброс профиля предыдущего uid до первого успешного /me.
    currentUserDocument = null;
    appMeCache = null;

    unawaited(refreshAppMeCache());
    _mePollTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => unawaited(refreshAppMeCache()),
    );
  });
}

Future<void> refreshAppMeCache() async {
  try {
    final raw = await AppMeApi.fetchMeMap();
    if (raw == null) return;
    _lastMeRaw = raw;
    appMeCache = AppMe.fromJson(raw);
    ensureAuthenticatedUserSession();
    _emitMerged();
    debugPrint(
      '[refreshAppMeCache] ok uid=${currentUserDocument?.uid} '
      'login_complete=${currentUserDocument?.loginComplete} '
      'name=${currentUserDocument?.displayName}',
    );
  } catch (e, st) {
    debugPrint('[refreshAppMeCache] FAIL $e\n$st');
  }
}

/// PG-first session stream: только /me poll (без FS user stream).
Stream<UsersRecord?> get authenticatedUserStream {
  ensureAuthenticatedUserSession();
  return _userDocController.stream;
}

class AuthUserStreamWidget extends StatelessWidget {
  const AuthUserStreamWidget({Key? key, required this.builder})
      : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    ensureAuthenticatedUserSession();
    return StreamBuilder(
      stream: authenticatedUserStream,
      builder: (context, _) => builder(context),
    );
  }
}
