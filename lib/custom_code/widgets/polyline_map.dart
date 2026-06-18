// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PolylineMap extends StatefulWidget {
  const PolylineMap({
    super.key,
    this.width,
    this.height,
    required this.startLatLng,
    required this.endLatLng,
    required this.googleApiKey,
    this.isStatic = false,
  });

  final double? width;
  final double? height;
  final LatLng startLatLng;
  final LatLng endLatLng;
  final String googleApiKey;
  final bool isStatic;

  @override
  State<PolylineMap> createState() => _PolylineMapState();
}

class _PolylineMapState extends State<PolylineMap> {
  late google_maps.GoogleMapController mapController;
  Set<google_maps.Marker> markers = {};
  Set<google_maps.Polyline> polylines = {};

  final String markerAUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/A.png?alt=media&token=95ee70e6-3fdd-49c5-b6e0-6cc623de875a';
  final String markerBUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/B.png?alt=media&token=8ffa7336-d581-48a1-b41f-198e817375b6';

  final cacheManager = DefaultCacheManager();

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
  void initState() {
    super.initState();
    _addMarkers();
    _getPolyline();
  }

  @override
  void didUpdateWidget(PolylineMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startLatLng != widget.startLatLng ||
        oldWidget.endLatLng != widget.endLatLng) {
      setState(() {
        markers.clear();
        polylines.clear();
      });

      _addMarkers();
      _getPolyline();

      try {
        if (mapController != null) {
          mapController.animateCamera(
            google_maps.CameraUpdate.newLatLngBounds(_getBounds(), 50),
          );
        }
      } catch (_) {}
    }
  }

  Future<google_maps.BitmapDescriptor> _getBitmapDescriptorFromUrl(
    String url, {
    int targetWidth = 100,
  }) async {
    try {
      final file = await cacheManager.getSingleFile(url);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
        targetHeight: targetWidth,
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

  Future<void> _addMarkers() async {
    if (!mounted) return;

    try {
      final originDescriptor = await _getBitmapDescriptorFromUrl(
        markerAUrl,
        targetWidth: 200,
      );

      if (!mounted) return;

      final destinationDescriptor = await _getBitmapDescriptorFromUrl(
        markerBUrl,
        targetWidth: 200,
      );

      if (!mounted) return;

      setState(() {
        markers.add(
          google_maps.Marker(
            markerId: const google_maps.MarkerId('origin'),
            position: _convertToGoogleLatLng(widget.startLatLng),
            icon: originDescriptor,
            anchor: const Offset(0.5, 0.5),
          ),
        );

        markers.add(
          google_maps.Marker(
            markerId: const google_maps.MarkerId('destination'),
            position: _convertToGoogleLatLng(widget.endLatLng),
            icon: destinationDescriptor,
            anchor: const Offset(0.5, 0.5),
          ),
        );
      });
    } catch (e) {
      print('Error setting markers: $e');
      if (mounted) {
        setState(() {
          markers.add(
            google_maps.Marker(
              markerId: const google_maps.MarkerId('origin'),
              position: _convertToGoogleLatLng(widget.startLatLng),
              icon: google_maps.BitmapDescriptor.defaultMarker,
              anchor: const Offset(0.5, 0.5),
            ),
          );

          markers.add(
            google_maps.Marker(
              markerId: const google_maps.MarkerId('destination'),
              position: _convertToGoogleLatLng(widget.endLatLng),
              icon: google_maps.BitmapDescriptor.defaultMarker,
              anchor: const Offset(0.5, 0.5),
            ),
          );
        });
      }
    }
  }

  void _getPolyline() async {
    if (!mounted) return;

    try {
      final url = 'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${widget.startLatLng.latitude},${widget.startLatLng.longitude}'
          '&destination=${widget.endLatLng.latitude},${widget.endLatLng.longitude}'
          '&key=${widget.googleApiKey}';

      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['status'] == 'OK') {
          final points = decoded['routes'][0]['overview_polyline']['points'];
          final polylinePoints = PolylinePoints();
          final result = polylinePoints.decodePolyline(points);

          if (!mounted) return;

          final List<google_maps.LatLng> polylineCoordinates = result
              .map((point) =>
                  google_maps.LatLng(point.latitude, point.longitude))
              .toList();

          // Add dotted line from start point to first road point
          final firstRoadPoint = polylineCoordinates.first;
          final startPoint = _convertToGoogleLatLng(widget.startLatLng);

          setState(() {
            // Main route polyline (blue)
            polylines.add(
              google_maps.Polyline(
                polylineId: const google_maps.PolylineId('main_poly'),
                color: Colors.blue,
                points: polylineCoordinates,
                width: 5,
              ),
            );

            // Dotted line to start point (gray)
            polylines.add(
              google_maps.Polyline(
                polylineId: const google_maps.PolylineId('start_connector'),
                color: Colors.grey,
                points: [startPoint, firstRoadPoint],
                width: 3,
                patterns: [
                  google_maps.PatternItem.dot,
                  google_maps.PatternItem.gap(10),
                ],
              ),
            );

            // Dotted line to end point (gray)
            final endPoint = _convertToGoogleLatLng(widget.endLatLng);
            final lastRoadPoint = polylineCoordinates.last;

            polylines.add(
              google_maps.Polyline(
                polylineId: const google_maps.PolylineId('end_connector'),
                color: Colors.grey,
                points: [lastRoadPoint, endPoint],
                width: 3,
                patterns: [
                  google_maps.PatternItem.dot,
                  google_maps.PatternItem.gap(10),
                ],
              ),
            );
          });
        }
      }
    } catch (e) {
      print('Error getting polyline: $e');
    }
  }

  google_maps.LatLngBounds _getBounds() {
    final start = _convertToGoogleLatLng(widget.startLatLng);
    final end = _convertToGoogleLatLng(widget.endLatLng);

    return google_maps.LatLngBounds(
      southwest: google_maps.LatLng(
        start.latitude < end.latitude ? start.latitude : end.latitude,
        start.longitude < end.longitude ? start.longitude : end.longitude,
      ),
      northeast: google_maps.LatLng(
        start.latitude > end.latitude ? start.latitude : end.latitude,
        start.longitude > end.longitude ? start.longitude : end.longitude,
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        child: google_maps.GoogleMap(
          initialCameraPosition: google_maps.CameraPosition(
            target: _convertToGoogleLatLng(widget.startLatLng),
            zoom: 12,
          ),
          onMapCreated: (google_maps.GoogleMapController controller) {
            mapController = controller;
            controller.setMapStyle(_mapStyle);
            controller.animateCamera(
              google_maps.CameraUpdate.newLatLngBounds(_getBounds(), 50),
            );
          },
          markers: markers,
          polylines: polylines,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: !widget.isStatic,
          rotateGesturesEnabled: !widget.isStatic,
          scrollGesturesEnabled: !widget.isStatic,
          tiltGesturesEnabled: !widget.isStatic,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}





class MultiPolylineMap extends StatefulWidget {
  const MultiPolylineMap({
    super.key,
    this.width,
    this.height,
    required this.googleApiKey,
    this.isStatic = false, required this.points,
  });

  final double? width;
  final double? height;
  final List<LatLng> points;
  final String googleApiKey;
  final bool isStatic;

  @override
  State<MultiPolylineMap> createState() => _MultiPolylineMapState();
}

class _MultiPolylineMapState extends State<MultiPolylineMap> {
  late google_maps.GoogleMapController mapController;
  Set<google_maps.Marker> markers = {};
  Set<google_maps.Polyline> polylines = {};

  final String markerAUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/A.png?alt=media&token=95ee70e6-3fdd-49c5-b6e0-6cc623de875a';
  final String markerBUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/B.png?alt=media&token=8ffa7336-d581-48a1-b41f-198e817375b6';

  final cacheManager = DefaultCacheManager();

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
  void initState() {
    super.initState();
    _addMarkers();
    _getPolyline();
  }

  @override
  void didUpdateWidget(MultiPolylineMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.points != widget.points ) {
      setState(() {
        markers.clear();
        polylines.clear();
      });

      _addMarkers();
      _getPolyline();

      try {
        if (mapController != null) {
          mapController.animateCamera(
            google_maps.CameraUpdate.newLatLngBounds(_getBounds(), 50),
          );
        }
      } catch (_) {}
    }
  }

  Future<google_maps.BitmapDescriptor> _getBitmapDescriptorFromUrl(
      String url, {
        int targetWidth = 100,
      }) async {
    try {
      final file = await cacheManager.getSingleFile(url);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
        targetHeight: targetWidth,
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

  Future<void> _addMarkers() async {
    if (!mounted) return;

    try {
      final originDescriptor = await _getBitmapDescriptorFromUrl(
        markerAUrl,
        targetWidth: 200,
      );

      if (!mounted) return;

      final destinationDescriptor = await _getBitmapDescriptorFromUrl(
        markerBUrl,
        targetWidth: 200,
      );

      if (!mounted) return;

      setState(() {

        markers.addAll(List.generate((widget.points.length), (index) => google_maps.Marker(
          markerId: google_maps.MarkerId(  index.toString()),
          position: _convertToGoogleLatLng(widget.points[index]),
          icon: index == 0 ? originDescriptor : destinationDescriptor,
          anchor: const Offset(0.5, 0.5),
        )));

      });
    } catch (e) {
      print('Error setting markers: $e');
      if (mounted) {
        setState(() {


        });
      }
    }
  }

  void _getPolyline() async {
    if (!mounted) return;

    try {
      final waypoints = widget.points.map((point) => '${point.latitude},${point.longitude}').join('|');
final url = 'https://maps.googleapis.com/maps/api/directions/json'
    '?origin=${widget.points.first.latitude},${widget.points.first.longitude}'
    '&destination=${widget.points.last.latitude},${widget.points.last.longitude}'

    '&waypoints=$waypoints'
      '&key=${widget.googleApiKey}';

      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['status'] == 'OK') {
          final points = decoded['routes'][0]['overview_polyline']['points'];
          final polylinePoints = PolylinePoints();
          final result = polylinePoints.decodePolyline(points);

          if (!mounted) return;

          final List<google_maps.LatLng> polylineCoordinates = result
              .map((point) =>
              google_maps.LatLng(point.latitude, point.longitude))
              .toList();

          // Add dotted line from start point to first road point
          final firstRoadPoint = polylineCoordinates.first;
          final startPoint = _convertToGoogleLatLng(widget.points[0]);

          setState(() {
            // Main route polyline (blue)
            polylines.add(
              google_maps.Polyline(
                polylineId: const google_maps.PolylineId('main_poly'),
                color: Colors.blue,
                points: polylineCoordinates,
                width: 5,
              ),
            );

            // Dotted line to start point (gray)
            polylines.add(
              google_maps.Polyline(
                polylineId: const google_maps.PolylineId('start_connector'),
                color: Colors.grey,
                points: [startPoint, firstRoadPoint],
                width: 3,
                patterns: [
                  google_maps.PatternItem.dot,
                  google_maps.PatternItem.gap(10),
                ],
              ),
            );

            // Dotted line to end point (gray)
            final endPoint = _convertToGoogleLatLng(widget.points.last);
            final lastRoadPoint = polylineCoordinates.last;

            polylines.add(
              google_maps.Polyline(
                polylineId: const google_maps.PolylineId('end_connector'),
                color: Colors.grey,
                points: [lastRoadPoint, endPoint],
                width: 3,
                patterns: [
                  google_maps.PatternItem.dot,
                  google_maps.PatternItem.gap(10),
                ],
              ),
            );
          });
        }
      }
    } catch (e) {
      print('Error getting polyline: $e');
    }
  }

  google_maps.LatLngBounds _getBounds() {
    final start = _convertToGoogleLatLng(widget.points.first);
    final end = _convertToGoogleLatLng(widget.points.last);

    return google_maps.LatLngBounds(
      southwest: google_maps.LatLng(
        start.latitude < end.latitude ? start.latitude : end.latitude,
        start.longitude < end.longitude ? start.longitude : end.longitude,
      ),
      northeast: google_maps.LatLng(
        start.latitude > end.latitude ? start.latitude : end.latitude,
        start.longitude > end.longitude ? start.longitude : end.longitude,
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height ?? double.infinity,
        child: google_maps.GoogleMap(
          initialCameraPosition: google_maps.CameraPosition(
            target: _convertToGoogleLatLng(widget.points.first),
            zoom: 12,
          ),
          onMapCreated: (google_maps.GoogleMapController controller) {
            mapController = controller;
            controller.setMapStyle(_mapStyle);
            controller.animateCamera(
              google_maps.CameraUpdate.newLatLngBounds(_getBounds(), 50),
            );
          },
          markers: markers,
          polylines: polylines,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: !widget.isStatic,
          rotateGesturesEnabled: !widget.isStatic,
          scrollGesturesEnabled: !widget.isStatic,
          tiltGesturesEnabled: !widget.isStatic,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}
