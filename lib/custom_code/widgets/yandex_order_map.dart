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

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '/custom_code/services/ors_route_service.dart';

/// Яндекс-карта заказа: A/B, маршрут ORS, опционально позиция водителя.
class YandexOrderMap extends StatefulWidget {
  const YandexOrderMap({
    super.key,
    this.width,
    this.height,
    required this.startLatLng,
    required this.endLatLng,
    this.driverLocation,
    this.showDriver = false,
    this.isStatic = false,
  });

  final double? width;
  final double? height;
  final LatLng startLatLng;
  final LatLng endLatLng;
  final LatLng? driverLocation;
  final bool showDriver;
  final bool isStatic;

  @override
  State<YandexOrderMap> createState() => _YandexOrderMapState();
}

class _YandexOrderMapState extends State<YandexOrderMap> {
  YandexMapController? _mapController;
  final List<MapObject> _mapObjects = [];
  final _cacheManager = DefaultCacheManager();
  bool _isLoadingRoute = true;

  BitmapDescriptor? _iconStart;
  BitmapDescriptor? _iconEnd;
  BitmapDescriptor? _iconDriver;

  static const _markerAbWidth = 200;
  static const _driverMarkerWidth = 158;
  static const _driverMarkerHeight = 90;
  static const _driverTintColor = Color(0xFFE53935);

  static const _markerAUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/A.png?alt=media&token=95ee70e6-3fdd-49c5-b6e0-6cc623de875a';
  static const _markerBUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/B.png?alt=media&token=8ffa7336-d581-48a1-b41f-198e817375b6';
  static const _driverMarkerUrl =
      'https://firebasestorage.googleapis.com/v0/b/ydrive-a35d2.firebasestorage.app/o/driver%201.png?alt=media&token=866b3567-60ea-4751-a7de-c0214fbb83e8';

  @override
  void initState() {
    super.initState();
    _reloadMap();
  }

  @override
  void didUpdateWidget(YandexOrderMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startLatLng != widget.startLatLng ||
        oldWidget.endLatLng != widget.endLatLng ||
        oldWidget.driverLocation != widget.driverLocation ||
        oldWidget.showDriver != widget.showDriver) {
      _reloadMap();
    }
  }

  Future<void> _reloadMap() async {
    if (!mounted) return;
    setState(() => _isLoadingRoute = true);

    try {
      await _ensureMarkerIcons();
      final objects = <MapObject>[];

      final mainRoute = await OrsRouteService.fetchDrivingRoute(
        from: widget.startLatLng,
        to: widget.endLatLng,
      );
      objects.add(_buildPolyline(
        id: 'main_route',
        points: mainRoute,
        color: Colors.blue,
      ));

      final driver = widget.showDriver ? widget.driverLocation : null;
      if (driver != null) {
        final distanceToStart = _distanceMeters(driver, widget.startLatLng);
        if (distanceToStart > 50) {
          final driverRoute = await OrsRouteService.fetchDrivingRoute(
            from: driver,
            to: widget.startLatLng,
          );
          objects.add(_buildPolyline(
            id: 'driver_to_start',
            points: driverRoute,
            color: Colors.grey,
          ));
        }
      }

      final iconStart = _iconStart;
      final iconEnd = _iconEnd;
      final iconDriver = _iconDriver;
      if (iconStart != null && iconEnd != null) {
        objects.add(_buildPlacemark(
          id: 'point_a',
          latLng: widget.startLatLng,
          icon: iconStart,
          anchor: const Offset(0.5, 0.5),
        ));
        objects.add(_buildPlacemark(
          id: 'point_b',
          latLng: widget.endLatLng,
          icon: iconEnd,
          anchor: const Offset(0.5, 0.5),
        ));
      }

      if (driver != null && iconDriver != null) {
        objects.add(_buildPlacemark(
          id: 'driver',
          latLng: driver,
          icon: iconDriver,
          anchor: const Offset(0.5, 0.5),
        ));
      }

      if (!mounted) return;
      setState(() {
        _mapObjects
          ..clear()
          ..addAll(objects);
        _isLoadingRoute = false;
      });

      await _fitCamera();
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  Future<void> _ensureMarkerIcons() async {
    if (_iconStart != null && _iconEnd != null && _iconDriver != null) {
      return;
    }

    final results = await Future.wait([
      _markerFromUrl(_markerAUrl, width: _markerAbWidth),
      _markerFromUrl(_markerBUrl, width: _markerAbWidth),
      _markerFromUrl(
        _driverMarkerUrl,
        width: _driverMarkerWidth,
        height: _driverMarkerHeight,
        tintColor: _driverTintColor,
      ),
    ]);

    _iconStart = results[0];
    _iconEnd = results[1];
    _iconDriver = results[2];
  }

  PolylineMapObject _buildPolyline({
    required String id,
    required List<LatLng> points,
    required Color color,
  }) {
    return PolylineMapObject(
      mapId: MapObjectId(id),
      polyline: Polyline(
        points: points
            .map(
              (p) => Point(latitude: p.latitude, longitude: p.longitude),
            )
            .toList(growable: false),
      ),
      strokeColor: color,
      strokeWidth: 5,
    );
  }

  PlacemarkMapObject _buildPlacemark({
    required String id,
    required LatLng latLng,
    required BitmapDescriptor icon,
    required Offset anchor,
  }) {
    return PlacemarkMapObject(
      mapId: MapObjectId(id),
      point: Point(latitude: latLng.latitude, longitude: latLng.longitude),
      opacity: 1,
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
          image: icon,
          anchor: anchor,
        ),
      ),
    );
  }

  Future<BitmapDescriptor> _markerFromUrl(
    String url, {
    required int width,
    int? height,
    Color? tintColor,
  }) async {
    try {
      final file = await _cacheManager.getSingleFile(url);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: width,
        targetHeight: height ?? width,
      );
      final frame = await codec.getNextFrame();
      ui.Image image = frame.image;

      if (tintColor != null) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final paint = Paint()
          ..colorFilter = ColorFilter.mode(tintColor, BlendMode.modulate);
        canvas.drawImage(image, Offset.zero, paint);
        final picture = recorder.endRecording();
        image = await picture.toImage(image.width, image.height);
      }

      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data != null) {
        return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
      }
    } catch (_) {}
    return _defaultMarkerIcon();
  }

  Future<BitmapDescriptor> _defaultMarkerIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(const Offset(12, 12), 10, paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(24, 24);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// Доля расширения вида после fit (log₂(1+x) к zoom).
  static const _zoomMarginFull = 0.15;
  static const _zoomMarginPreview = 0.18;

  Future<void> _fitCamera() async {
    final controller = _mapController;
    if (controller == null) return;

    final points = <Point>[
      Point(
        latitude: widget.startLatLng.latitude,
        longitude: widget.startLatLng.longitude,
      ),
      Point(
        latitude: widget.endLatLng.latitude,
        longitude: widget.endLatLng.longitude,
      ),
    ];
    final driver = widget.showDriver ? widget.driverLocation : null;
    if (driver != null) {
      points.add(Point(latitude: driver.latitude, longitude: driver.longitude));
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final point in points.skip(1)) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    await controller.moveCamera(
      CameraUpdate.newGeometry(
        Geometry.fromBoundingBox(
          BoundingBox(
            northEast: Point(latitude: maxLat, longitude: maxLng),
            southWest: Point(latitude: minLat, longitude: minLng),
          ),
        ),
      ),
    );

    final margin = widget.isStatic ? _zoomMarginPreview : _zoomMarginFull;
    final pos = await controller.getCameraPosition();
    final newZoom = pos.zoom - log(1 + margin) / ln2;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pos.target,
          zoom: newZoom,
          azimuth: pos.azimuth,
          tilt: pos.tilt,
        ),
      ),
    );
  }

  double _distanceMeters(LatLng start, LatLng end) {
    const r = 6371e3;
    final phi1 = start.latitude * pi / 180;
    final phi2 = end.latitude * pi / 180;
    final deltaPhi = (end.latitude - start.latitude) * pi / 180;
    final deltaLambda = (end.longitude - start.longitude) * pi / 180;
    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  @override
  Widget build(BuildContext context) {
    final gesturesEnabled = !widget.isStatic;

    final map = YandexMap(
      mapObjects: _mapObjects,
      zoomGesturesEnabled: gesturesEnabled,
      scrollGesturesEnabled: gesturesEnabled,
      rotateGesturesEnabled: gesturesEnabled,
      tiltGesturesEnabled: gesturesEnabled,
      onCameraPositionChanged: (_, __, ___) {},
      onMapCreated: (controller) async {
        _mapController = controller;
        await _fitCamera();
      },
    );

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: Stack(
        children: [
          widget.isStatic ? IgnorePointer(child: map) : map,
          if (_isLoadingRoute)
            const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }
}
