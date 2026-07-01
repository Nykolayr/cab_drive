// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '/custom_code/services/ors_route_service.dart';

StreamSubscription<Position>? _locationSubscription;
DateTime? _lastLocationUpdate;

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

        final update = <String, dynamic>{
          'driver_location':
              GeoPoint(position.latitude, position.longitude),
        };
        if (matrix != null) {
          update['time_left'] = matrix.timeLeft;
          update['km_left'] = matrix.kmLeft;
        }

        await orderId.update(update);
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
