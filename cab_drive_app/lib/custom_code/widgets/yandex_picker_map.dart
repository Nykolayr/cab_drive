// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';

import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Интерактивная Яндекс-карта с пином по центру (выбор адреса).
class YandexPickerMap extends StatefulWidget {
  const YandexPickerMap({
    super.key,
    required this.initialLocation,
    this.initialZoom = 15.0,
    this.onCameraIdle,
    this.onMapCreated,
    this.allowInteraction = true,
  });

  final LatLng initialLocation;
  final double initialZoom;
  final ValueChanged<LatLng>? onCameraIdle;
  final void Function(YandexMapController controller)? onMapCreated;
  final bool allowInteraction;

  @override
  State<YandexPickerMap> createState() => _YandexPickerMapState();
}

class _YandexPickerMapState extends State<YandexPickerMap> {
  Timer? _idleTimer;
  LatLng? _lastReported;

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _scheduleIdle(Point target) {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(milliseconds: 350), () {
      final latLng = LatLng(target.latitude, target.longitude);
      if (_lastReported != null &&
          _lastReported!.latitude == latLng.latitude &&
          _lastReported!.longitude == latLng.longitude) {
        return;
      }
      _lastReported = latLng;
      widget.onCameraIdle?.call(latLng);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allow = widget.allowInteraction;

    return YandexMap(
      zoomGesturesEnabled: allow,
      scrollGesturesEnabled: allow,
      rotateGesturesEnabled: allow,
      tiltGesturesEnabled: allow,
      onCameraPositionChanged: (position, _, finished) {
        if (!finished) {
          _scheduleIdle(position.target);
        }
      },
      onMapCreated: (controller) async {
        widget.onMapCreated?.call(controller);
        await controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: Point(
                latitude: widget.initialLocation.latitude,
                longitude: widget.initialLocation.longitude,
              ),
              zoom: widget.initialZoom,
            ),
          ),
        );
      },
    );
  }
}
