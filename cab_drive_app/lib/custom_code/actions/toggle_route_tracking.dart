// Automatic FlutterFlow imports
import 'package:cab_drive/auth/firebase_auth/auth_util.dart';

import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';

import '/backend/api/app_me_api.dart';
import '/custom_code/services/ors_route_service.dart';

StreamSubscription<Position>? _locationSubscription;
DateTime? _lastLocationUpdate;
Timer? _locationTimer;
bool _alreadyListeningTimer = false;

Future toggleRouteTracking(
  String googleApiKey,
  bool start,
  DocumentReference orderId,
  LatLng pointB,
) async {
  if (!start) {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _lastLocationUpdate = null;
    return;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return;
  }

  await _locationSubscription?.cancel();
  _lastLocationUpdate = null;

  final settings = _buildLocationSettings();

  _locationSubscription =
      Geolocator.getPositionStream(locationSettings: settings).listen(
    (position) async {
      try {
        final now = DateTime.now();
        if (_lastLocationUpdate != null &&
            now.difference(_lastLocationUpdate!) <
                const Duration(seconds: 15)) {
          return;
        }
        _lastLocationUpdate = now;

        final current = LatLng(position.latitude, position.longitude);
        final matrix = await OrsRouteService.fetchDrivingMatrix(
          from: current,
          to: pointB,
        );

        final timeLeft = matrix?.timeLeft;
        final kmLeft = matrix?.kmLeft;

        final ok = await AppMeApi.pingOrderGeo(
          orderId.id,
          lat: position.latitude,
          lng: position.longitude,
          timeLeft: timeLeft?.toString(),
          kmLeft: kmLeft?.toString(),
        );
        if (!ok) {
          // ignore: avoid_print
          print('pingOrderGeo failed for ${orderId.id}');
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error updating location and route info: $e');
      }
    },
  );
}

LocationSettings _buildLocationSettings() {
  if (Platform.isAndroid) {
    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      intervalDuration: const Duration(seconds: 15),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'Cab Drive',
        notificationText: 'Идёт доставка — обновление маршрута',
        enableWakeLock: true,
      ),
    );
  }

  if (Platform.isIOS) {
    return AppleSettings(
      accuracy: LocationAccuracy.high,
      activityType: ActivityType.automotiveNavigation,
      distanceFilter: 0,
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
    );
  }

  return const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );
}

Future toggleDriverPosTracking() async {
  if (_alreadyListeningTimer) return;

  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    throw Exception('Location permission denied');
  }

  _locationTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final ok = await AppMeApi.pingMeLocation(
        lat: position.latitude,
        lng: position.longitude,
      );
      if (!ok) {
        print('pingMeLocation failed');
      }
    } catch (e) {
      print('Error updating location and route info: $e');
    }
  });
  _alreadyListeningTimer = true;
}
