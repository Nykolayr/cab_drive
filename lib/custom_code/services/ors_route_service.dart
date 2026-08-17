import 'package:open_route_service/open_route_service.dart';

import '/custom_code/config/route_config.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Маршруты по дорогам через OpenRouteService (профиль driving-car).
class OrsRouteService {
  OrsRouteService._();

  static OpenRouteService? _client;

  static OpenRouteService get _ors {
    final key = RouteConfig.orsApiKey;
    if (key.isEmpty) {
      throw StateError('ORS_API_KEY is not set');
    }
    return _client ??= OpenRouteService(apiKey: key);
  }

  /// Точки полилинии A→B. При ошибке или пустом ключе — прямая линия.
  static Future<List<LatLng>> fetchDrivingRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    if (!RouteConfig.hasOrsApiKey) {
      return [from, to];
    }

    try {
      final coordinates = await _ors.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(
          latitude: from.latitude,
          longitude: from.longitude,
        ),
        endCoordinate: ORSCoordinate(
          latitude: to.latitude,
          longitude: to.longitude,
        ),
        profileOverride: ORSProfile.drivingCar,
      );

      if (coordinates.length <= 2) {
        return [from, to];
      }

      return coordinates
          .map((c) => LatLng(c.latitude, c.longitude))
          .toList(growable: false);
    } catch (_) {
      return [from, to];
    }
  }

  /// ETA и расстояние до точки (для трекинга водителя).
  static Future<({String timeLeft, String kmLeft})?> fetchDrivingMatrix({
    required LatLng from,
    required LatLng to,
  }) async {
    if (!RouteConfig.hasOrsApiKey) {
      return null;
    }

    try {
      final response = await _ors.matrixPost(
        locations: [
          ORSCoordinate(latitude: from.latitude, longitude: from.longitude),
          ORSCoordinate(latitude: to.latitude, longitude: to.longitude),
        ],
        profileOverride: ORSProfile.drivingCar,
        metrics: const ['duration', 'distance'],
      );

      if (response.durations.isEmpty ||
          response.distances.isEmpty ||
          response.durations.first.length < 2) {
        return null;
      }

      final durationSec = response.durations[0][1];
      final distanceM = response.distances[0][1];

      return (
        timeLeft: _formatDuration(durationSec),
        kmLeft: _formatDistance(distanceM),
      );
    } catch (_) {
      return null;
    }
  }

  static String _formatDuration(double seconds) {
    final totalMinutes = (seconds / 60).round();
    if (totalMinutes < 60) {
      return '$totalMinutes мин';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return '$hours ч';
    }
    return '$hours ч $minutes мин';
  }

  static String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} м';
    }
    final km = meters / 1000;
    return '${km.toStringAsFixed(km >= 10 ? 0 : 1)} км';
  }
}
