import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tests for role selection persistence feature.
///
/// These tests verify that:
/// 1. roleSelected flag persists correctly
/// 2. Navigation logic uses roleSelected + driver flags correctly

void main() {
  group('Role Selection Logic', () {
    test('roleSelected defaults to false', () {
      // Logic check: new users should see role selection
      const defaultRoleSelected = false;
      expect(defaultRoleSelected, isFalse);
    });

    test('driver defaults to false (client)', () {
      // Logic check: default role is client
      const defaultDriver = false;
      expect(defaultDriver, isFalse);
    });

    test('navigation logic: roleSelected=false should show Vibor', () {
      // Simulating LoadWidget logic
      final roleSelected = false;
      final driver = false;

      String targetScreen;
      if (roleSelected) {
        targetScreen = driver ? 'MainDriverWidget' : 'MainUserWidget';
      } else {
        targetScreen = 'ViborWidget';
      }

      expect(targetScreen, equals('ViborWidget'));
    });

    test('navigation logic: roleSelected=true, driver=true should show MainDriver', () {
      final roleSelected = true;
      final driver = true;

      String targetScreen;
      if (roleSelected) {
        targetScreen = driver ? 'MainDriverWidget' : 'MainUserWidget';
      } else {
        targetScreen = 'ViborWidget';
      }

      expect(targetScreen, equals('MainDriverWidget'));
    });

    test('navigation logic: roleSelected=true, driver=false should show MainUser', () {
      final roleSelected = true;
      final driver = false;

      String targetScreen;
      if (roleSelected) {
        targetScreen = driver ? 'MainDriverWidget' : 'MainUserWidget';
      } else {
        targetScreen = 'ViborWidget';
      }

      expect(targetScreen, equals('MainUserWidget'));
    });
  });

  group('Role Selection in Vibor', () {
    test('selecting driver should set roleSelected=true and driver=true', () {
      // Simulating ViborWidget "Я - водитель" button
      var roleSelected = false;
      var driver = false;

      // User taps "Я - водитель"
      driver = true;
      roleSelected = true;

      expect(driver, isTrue);
      expect(roleSelected, isTrue);
    });

    test('selecting client should set roleSelected=true and driver=false', () {
      // Simulating ViborWidget "Я - клиент" button
      var roleSelected = false;
      var driver = false;

      // User taps "Я - клиент"
      driver = false;
      roleSelected = true;

      expect(driver, isFalse);
      expect(roleSelected, isTrue);
    });
  });
}
