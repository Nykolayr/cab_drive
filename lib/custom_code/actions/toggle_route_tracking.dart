// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Timer? _locationTimer;

Future toggleRouteTracking(
  String googleApiKey,
  bool start,
  DocumentReference orderId,
  LatLng pointB,
) async {
  // Add your function code here!
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stop tracking
  if (!start) {
    _locationTimer?.cancel();
    return;
  }

  // Request location permission
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    throw Exception('Location permission denied');
  }

  // Start periodic location updates
  _locationTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Build API request URL with "language=ru"
      final url = 'https://maps.googleapis.com/maps/api/distancematrix/json'
          '?origins=${position.latitude},${position.longitude}'
          '&destinations=${pointB.latitude},${pointB.longitude}'
          '&language=ru'
          '&key=$googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final element = data['rows'][0]['elements'][0];
          final timeLeft = element['duration']['text'];
          final kmLeft = element['distance']['text'];

          // Update order document with the location and route information
          await orderId.update({
            'driver_location': GeoPoint(position.latitude, position.longitude),
            'time_left': timeLeft,
            'km_left': kmLeft,
          });
        }
      }
    } catch (e) {
      print('Error updating location and route info: $e');
    }
  });
}
