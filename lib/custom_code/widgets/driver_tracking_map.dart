// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart'; // Для compute()
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:math';

class DriverTrackingMap extends StatefulWidget {
  const DriverTrackingMap({
    super.key,
    this.width,
    this.height,
    required this.startLatLng,
    required this.endLatLng,
    required this.driverLocation,
    required this.googleApiKey,
  });

  final double? width;
  final double? height;
  final LatLng startLatLng;
  final LatLng endLatLng;
  final LatLng driverLocation;
  final String googleApiKey;

  @override
  State<DriverTrackingMap> createState() => _DriverTrackingMapState();
}

class _DriverTrackingMapState extends State<DriverTrackingMap> {
  late google_maps.GoogleMapController mapController;
  Set<google_maps.Marker> markers = {};
  Set<google_maps.Polyline> polylines = {};

  final String markerAUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/A.png?alt=media&token=95ee70e6-3fdd-49c5-b6e0-6cc623de875a';
  final String markerBUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/B.png?alt=media&token=8ffa7336-d581-48a1-b41f-198e817375b6';
  final String driverMarkerUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/driver%201.png?alt=media&token=866b3567-60ea-4751-a7de-c0214fbb83e8';

  final cacheManager = DefaultCacheManager();

  // Флаг для ограничения частоты обновлений полилиний
  bool _isUpdatingPolyline = false;

  @override
  void initState() {
    super.initState();
    _setupMarkers();
    _getPolyline();
  }

  @override
  void didUpdateWidget(DriverTrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.driverLocation != widget.driverLocation ||
        oldWidget.startLatLng != widget.startLatLng ||
        oldWidget.endLatLng != widget.endLatLng) {
      _updateMarkers();
      _getPolyline();
      _updateCamera();
    }
  }

  Future<google_maps.BitmapDescriptor> _getBitmapDescriptorFromUrl(
    String url, {
    int? targetWidth,
    int? targetHeight,
  }) async {
    try {
      final file = await cacheManager.getSingleFile(url);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (data != null) {
        return google_maps.BitmapDescriptor.fromBytes(
            data.buffer.asUint8List());
      } else {
        throw Exception('Failed to convert image to bytes');
      }
    } catch (e) {
      print('Error creating BitmapDescriptor: $e');
      return google_maps.BitmapDescriptor.defaultMarker;
    }
  }

  Future<void> _setupMarkers() async {
    try {
      final markerA = await _getBitmapDescriptorFromUrl(
        markerAUrl,
        targetWidth: 200,
      );

      final markerB = await _getBitmapDescriptorFromUrl(
        markerBUrl,
        targetWidth: 200,
      );

      final driverIcon = await _getBitmapDescriptorFromUrl(
        driverMarkerUrl,
        targetWidth: 158,
        targetHeight: 90,
      );

      if (!mounted) return;

      setState(() {
        markers.clear();

        // Marker A
        markers.add(
          google_maps.Marker(
            markerId: const google_maps.MarkerId('start'),
            position: _convertToGoogleLatLng(widget.startLatLng),
            icon: markerA,
            anchor: const Offset(0.5, 1.0),
          ),
        );

        // Marker B
        markers.add(
          google_maps.Marker(
            markerId: const google_maps.MarkerId('end'),
            position: _convertToGoogleLatLng(widget.endLatLng),
            icon: markerB,
            anchor: const Offset(0.5, 1.0),
          ),
        );

        // Driver marker
        markers.add(
          google_maps.Marker(
            markerId: const google_maps.MarkerId('driver'),
            position: _convertToGoogleLatLng(widget.driverLocation),
            icon: driverIcon,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            rotation: _calculateBearing(),
          ),
        );
      });
    } catch (e) {
      print('Error setting up markers: $e');
    }
  }

  Future<void> _updateMarkers() async {
    try {
      final markerA = await _getBitmapDescriptorFromUrl(
        markerAUrl,
        targetWidth: 80,
      );

      final markerB = await _getBitmapDescriptorFromUrl(
        markerBUrl,
        targetWidth: 80,
      );

      final driverIcon = await _getBitmapDescriptorFromUrl(
        driverMarkerUrl,
        targetWidth: 79,
        targetHeight: 45,
      );

      if (!mounted) return;

      setState(() {
        markers.clear();

        markers.add(
          google_maps.Marker(
            markerId: const google_maps.MarkerId('start'),
            position: _convertToGoogleLatLng(widget.startLatLng),
            icon: markerA,
            anchor: const Offset(0.5, 1.0),
          ),
        );

        markers.add(
          google_maps.Marker(
            markerId: const google_maps.MarkerId('end'),
            position: _convertToGoogleLatLng(widget.endLatLng),
            icon: markerB,
            anchor: const Offset(0.5, 1.0),
          ),
        );

        markers.add(
          google_maps.Marker(
            markerId: const google_maps.MarkerId('driver'),
            position: _convertToGoogleLatLng(widget.driverLocation),
            icon: driverIcon,
            flat: true,
            anchor: const Offset(0.5, 0.5),
            rotation: _calculateBearing(),
          ),
        );
      });
    } catch (e) {
      print('Error updating markers: $e');
    }
  }

  double _calculateBearing() {
    final nextPoint = _getNextRoutePoint();
    if (nextPoint == null) return 0;

    final startLatitude = widget.driverLocation.latitude * pi / 180;
    final startLongitude = widget.driverLocation.longitude * pi / 180;
    final endLatitude = nextPoint.latitude * pi / 180;
    final endLongitude = nextPoint.longitude * pi / 180;

    final dLong = endLongitude - startLongitude;

    final y = sin(dLong) * cos(endLatitude);
    final x = cos(startLatitude) * sin(endLatitude) -
        sin(startLatitude) * cos(endLatitude) * cos(dLong);

    var bearing = atan2(y, x);
    bearing = bearing * 180 / pi;
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  LatLng? _getNextRoutePoint() {
    final distanceToStart = _calculateDistance(
      widget.driverLocation,
      widget.startLatLng,
    );
    // Если водитель не достиг точки А, возвращаем startLatLng, иначе endLatLng.
    if (distanceToStart > 0.1) {
      return widget.startLatLng;
    }
    return widget.endLatLng;
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const R = 6371e3; // Радиус Земли в метрах
    final phi1 = start.latitude * pi / 180;
    final phi2 = end.latitude * pi / 180;
    final deltaPhi = (end.latitude - start.latitude) * pi / 180;
    final deltaLambda = (end.longitude - start.longitude) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  // Функция для декодирования полилинии в отдельном изоляте
  static List<google_maps.LatLng> _decodePolylineWorker(String encoded) {
    final polylinePoints = PolylinePoints();
    final result = polylinePoints.decodePolyline(encoded);
    return result
        .map((point) => google_maps.LatLng(point.latitude, point.longitude))
        .toList();
  }

  Future<List<google_maps.LatLng>> _decodePolyline(String encoded) async {
    return await compute(_decodePolylineWorker, encoded);
  }

  Future<void> _getPolyline() async {
    if (_isUpdatingPolyline) return;
    _isUpdatingPolyline = true;
    try {
      final driverToStartUrl =
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${widget.driverLocation.latitude},${widget.driverLocation.longitude}'
          '&destination=${widget.startLatLng.latitude},${widget.startLatLng.longitude}'
          '&key=${widget.googleApiKey}';

      final driverToStartResponse = await http.get(Uri.parse(driverToStartUrl));

      if (!mounted) return;

      if (driverToStartResponse.statusCode == 200) {
        final decoded = json.decode(driverToStartResponse.body);
        if (decoded['status'] == 'OK') {
          final driverPointsEncoded =
              decoded['routes'][0]['overview_polyline']['points'] as String;
          final driverToStartCoordinates =
              await _decodePolyline(driverPointsEncoded);

          final mainRouteUrl =
              'https://maps.googleapis.com/maps/api/directions/json'
              '?origin=${widget.startLatLng.latitude},${widget.startLatLng.longitude}'
              '&destination=${widget.endLatLng.latitude},${widget.endLatLng.longitude}'
              '&key=${widget.googleApiKey}';

          final mainRouteResponse = await http.get(Uri.parse(mainRouteUrl));

          if (mainRouteResponse.statusCode == 200) {
            final mainDecoded = json.decode(mainRouteResponse.body);
            if (mainDecoded['status'] == 'OK') {
              final mainPointsEncoded = mainDecoded['routes'][0]
                  ['overview_polyline']['points'] as String;
              final mainRouteCoordinates =
                  await _decodePolyline(mainPointsEncoded);

              // Определяем, достиг ли водитель точки А
              final distanceToStart = _calculateDistance(
                widget.driverLocation,
                widget.startLatLng,
              );
              final isDriverAtStart = distanceToStart < 50; // порог 50 метров

              setState(() {
                final updatedPolylines =
                    Set<google_maps.Polyline>.from(polylines);

                // Обновляем polyline от водителя до точки А (сплошная линия, чуть светлее серого)
                updatedPolylines.removeWhere(
                    (p) => p.polylineId.value == 'driver_to_start');
                if (!isDriverAtStart) {
                  updatedPolylines.add(
                    google_maps.Polyline(
                      polylineId:
                          const google_maps.PolylineId('driver_to_start'),
                      color: Colors.grey[400]!, // светлее, чем основной серый
                      points: driverToStartCoordinates,
                      width: 5,
                    ),
                  );
                }

                // Обновляем основной маршрут (от А до Б)
                updatedPolylines
                    .removeWhere((p) => p.polylineId.value == 'main_route');
                updatedPolylines.add(
                  google_maps.Polyline(
                    polylineId: const google_maps.PolylineId('main_route'),
                    color: isDriverAtStart ? Colors.blue : Colors.grey,
                    points: mainRouteCoordinates,
                    width: 5,
                  ),
                );

                polylines = updatedPolylines;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error getting polyline: $e');
    } finally {
      // Позволяем следующее обновление через 2 секунды
      Future.delayed(const Duration(seconds: 2), () {
        _isUpdatingPolyline = false;
      });
    }
  }

  void _updateCamera() {
    final bounds = _calculateBounds();
    mapController.animateCamera(
      google_maps.CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  google_maps.LatLngBounds _calculateBounds() {
    final points = [
      _convertToGoogleLatLng(widget.startLatLng),
      _convertToGoogleLatLng(widget.endLatLng),
      _convertToGoogleLatLng(widget.driverLocation),
    ];

    double southwestLat = points[0].latitude;
    double southwestLng = points[0].longitude;
    double northeastLat = points[0].latitude;
    double northeastLng = points[0].longitude;

    for (final point in points) {
      if (point.latitude < southwestLat) southwestLat = point.latitude;
      if (point.longitude < southwestLng) southwestLng = point.longitude;
      if (point.latitude > northeastLat) northeastLat = point.latitude;
      if (point.longitude > northeastLng) northeastLng = point.longitude;
    }

    return google_maps.LatLngBounds(
      southwest: google_maps.LatLng(southwestLat, southwestLng),
      northeast: google_maps.LatLng(northeastLat, northeastLng),
    );
  }

  google_maps.LatLng _convertToGoogleLatLng(LatLng latLng) {
    return google_maps.LatLng(latLng.latitude, latLng.longitude);
  }

  final _mapStyle = '''
    [
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "poi.business",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      }
    ]
  ''';

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: google_maps.GoogleMap(
        initialCameraPosition: google_maps.CameraPosition(
          target: _convertToGoogleLatLng(widget.driverLocation),
          zoom: 12,
        ),
        onMapCreated: (google_maps.GoogleMapController controller) {
          mapController = controller;
          controller.setMapStyle(_mapStyle);
          controller.animateCamera(
            google_maps.CameraUpdate.newLatLngBounds(_calculateBounds(), 50),
          );
        },
        markers: markers,
        polylines: polylines,
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        tiltGesturesEnabled: true,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }
}
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
