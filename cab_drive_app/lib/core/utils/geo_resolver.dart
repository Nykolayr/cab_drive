import 'package:geolocator/geolocator.dart';

import '/backend/api/client_error_reporter.dart';
import '/flutter_flow/lat_lng.dart' as ff;

/// Причина, по которой точную позицию получить не удалось.
enum GeoFailReason {
  none,
  serviceDisabled, // выключен системный тумблер геолокации
  permissionDenied, // runtime-права не дали
  permissionDeniedForever, // запрещено навсегда — только системные настройки
  positionFailed, // права есть, но фикс не получен (таймаут/ошибка)
}

class GeoResult {
  const GeoResult({
    required this.latLng,
    required this.reason,
    this.fromCache = false,
  });

  /// Реальная позиция либо фолбэк — может быть null если фолбэка нет.
  final ff.LatLng? latLng;
  final GeoFailReason reason;

  /// true — позиция из getLastKnownPosition (может быть устаревшей).
  final bool fromCache;

  bool get isRealLocation =>
      latLng != null && reason == GeoFailReason.none ||
      (fromCache && latLng != null);
}

/// Резолвит позицию пользователя с диагностикой и фолбэками:
/// разрешение → fused fix (medium accuracy, есть таймаут) → last known → дефолт.
/// Каждый шаг пишет крошку на сервер (crumb:geo).
Future<GeoResult> resolveUserLocation({ff.LatLng? defaultLocation}) async {
  final reporter = ClientErrorReporter.instance;
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    reporter?.crumb('geo', 'service_enabled=$serviceEnabled');

    var permission = await Geolocator.checkPermission();
    reporter?.crumb('geo', 'permission_before=$permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      reporter?.crumb('geo', 'permission_after_request=$permission');
    }

    if (permission == LocationPermission.deniedForever) {
      return _fallback(defaultLocation, GeoFailReason.permissionDeniedForever);
    }
    if (permission == LocationPermission.denied) {
      return _fallback(defaultLocation, GeoFailReason.permissionDenied);
    }
    if (!serviceEnabled) {
      // Права есть, но GPS-тумблер выключен — Android FusedLocation иногда
      // всё равно отдаст сетевую позицию, поэтому фикс пробуем до фолбэка.
      final cached = await _lastKnown();
      if (cached != null) {
        reporter?.crumb('geo', 'service_off_but_cached');
        return GeoResult(
          latLng: cached,
          reason: GeoFailReason.serviceDisabled,
          fromCache: true,
        );
      }
      return _fallback(defaultLocation, GeoFailReason.serviceDisabled);
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (pos.latitude != 0 || pos.longitude != 0) {
        reporter?.crumb('geo', 'fix_ok');
        return GeoResult(
          latLng: ff.LatLng(pos.latitude, pos.longitude),
          reason: GeoFailReason.none,
        );
      }
    } catch (e) {
      reporter?.crumb('geo', 'fix_error=${_brief(e)}');
    }

    final cached = await _lastKnown();
    if (cached != null) {
      reporter?.crumb('geo', 'last_known_ok');
      return GeoResult(
        latLng: cached,
        reason: GeoFailReason.none,
        fromCache: true,
      );
    }
    return _fallback(defaultLocation, GeoFailReason.positionFailed);
  } catch (e) {
    reporter?.crumb('geo', 'resolve_crash=${_brief(e)}');
    return _fallback(defaultLocation, GeoFailReason.positionFailed);
  }
}

Future<ff.LatLng?> _lastKnown() async {
  try {
    final last = await Geolocator.getLastKnownPosition();
    if (last != null && (last.latitude != 0 || last.longitude != 0)) {
      return ff.LatLng(last.latitude, last.longitude);
    }
  } catch (_) {}
  return null;
}

GeoResult _fallback(ff.LatLng? defaultLocation, GeoFailReason reason) {
  ClientErrorReporter.instance
      ?.crumb('geo', 'fallback=${reason.name}');
  return GeoResult(latLng: defaultLocation, reason: reason);
}

String _brief(Object e) =>
    e.toString().replaceAll('\n', ' ').take(300);

extension on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
