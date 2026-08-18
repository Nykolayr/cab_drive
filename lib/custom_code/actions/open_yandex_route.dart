// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:url_launcher/url_launcher.dart';
import '/flutter_flow/lat_lng.dart';

/// Маршрут A→B в браузере (Яндекс.Карты / Навигатор).
Future<void> openYandexRoute(LatLng startLatLng, LatLng endLatLng) async {
  final startLat = startLatLng.latitude;
  final startLng = startLatLng.longitude;
  final endLat = endLatLng.latitude;
  final endLng = endLatLng.longitude;

  final webUri = Uri.parse(
    'https://yandex.ru/maps/?rtext=$startLat,$startLng~$endLat,$endLng&rtt=auto',
  );

  final launched = await launchUrl(
    webUri,
    mode: LaunchMode.externalApplication,
  );
  if (!launched) {
    throw Exception('Не удалось открыть Яндекс Навигатор');
  }
}
