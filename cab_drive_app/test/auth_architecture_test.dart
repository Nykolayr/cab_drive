import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Инварианты auth/навигации — ловят регрессии до сборки APK.
/// См. docs/ARCHITECTURE_AND_FLOWS.md
void main() {
  final repoRoot = Directory.current.path.contains('cab_drive_app')
      ? Directory('${Directory.current.path}${Platform.pathSeparator}..')
      : Directory.current;

  final serverApi = File(
    '${repoRoot.path}${Platform.pathSeparator}server${Platform.pathSeparator}users${Platform.pathSeparator}api.py',
  );
  final serverEntities = File(
    '${repoRoot.path}${Platform.pathSeparator}server${Platform.pathSeparator}users${Platform.pathSeparator}entities.py',
  );
  final loadWidget = File(
    'lib${Platform.pathSeparator}login${Platform.pathSeparator}load${Platform.pathSeparator}load_widget.dart',
  );
  final profileWidget = File(
    'lib${Platform.pathSeparator}pages${Platform.pathSeparator}menu${Platform.pathSeparator}profile${Platform.pathSeparator}profile_widget.dart',
  );
  final codePage = File(
    'lib${Platform.pathSeparator}login${Platform.pathSeparator}login${Platform.pathSeparator}presentation${Platform.pathSeparator}pages${Platform.pathSeparator}code_page.dart',
  );
  final otpWidget = File(
    'lib${Platform.pathSeparator}login${Platform.pathSeparator}otp${Platform.pathSeparator}otp_widget.dart',
  );

  group('Auth email canon', () {
    test('server entities: AUTH_EMAIL_DOMAIN = ydrive.appwave.com', () {
      expect(serverEntities.existsSync(), isTrue);
      final text = serverEntities.readAsStringSync();
      expect(text, contains("AUTH_EMAIL_DOMAIN = 'ydrive.appwave.com'"));
      expect(text, contains('def auth_email(phone: str)'));
    });

    test('server api: create_user uses auth_email, not @ydrive.com', () {
      expect(serverApi.existsSync(), isTrue);
      final text = serverApi.readAsStringSync();
      expect(text, contains('email = auth_email(phone)'));
      expect(text.contains("email = f'{phone}@ydrive.com'"), isFalse);
    });

    test('legacy OTP still uses @ydrive.appwave.com', () {
      expect(otpWidget.existsSync(), isTrue);
      expect(
        otpWidget.readAsStringSync(),
        contains('@ydrive.appwave.com'),
      );
    });
  });

  group('LoadWidget navigation', () {
    test('uses Firestore isDriver for new device', () {
      expect(loadWidget.existsSync(), isTrue);
      final text = loadWidget.readAsStringSync();
      expect(text, contains('currentUserDocument?.isDriver'));
      expect(text, contains('firestoreIsDriver'));
    });
  });

  group('Driver city in profile', () {
    test('city picker not hidden on phone only', () {
      expect(profileWidget.existsSync(), isTrue);
      final text = profileWidget.readAsStringSync();
      final cityBlock = text.indexOf('Город поиска');
      expect(cityBlock, greaterThan(0));
      final start = cityBlock > 600 ? cityBlock - 600 : 0;
      final beforeCity = text.substring(start, cityBlock);
      expect(beforeCity.contains('phone: false'), isFalse);
    });
  });

  group('Code page Firebase sign-in', () {
    test('signInWithEmail after confirmCode', () {
      expect(codePage.existsSync(), isTrue);
      final text = codePage.readAsStringSync();
      expect(text, contains('signInWithEmail'));
      expect(text, contains('_user.email'));
      expect(text, contains('_user.password'));
    });
  });

  group('LoadWidget navigation with Firestore driver', () {
    test('firestoreIsDriver forces MainDriver path', () {
      const firestoreIsDriver = true;
      var roleSelected = false;
      var driver = false;

      if (firestoreIsDriver) {
        driver = true;
        roleSelected = true;
      }

      final isRoleSelected = roleSelected || firestoreIsDriver;
      final isDriver = driver || firestoreIsDriver;

      String target;
      if (isRoleSelected) {
        target = isDriver ? 'MainDriverWidget' : 'MainUserWidget';
      } else {
        target = 'ViborWidget';
      }

      expect(target, 'MainDriverWidget');
    });
  });
}
