// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:url_launcher/url_launcher.dart';

/// Открывает маршрут A→B во внешних Яндекс.Картах (приложение или браузер).
Future<void> openYandexRoute(LatLng startLatLng, LatLng endLatLng) async {
  final startLat = startLatLng.latitude;
  final startLng = startLatLng.longitude;
  final endLat = endLatLng.latitude;
  final endLng = endLatLng.longitude;

  final appUri = Uri.parse(
    'yandexmaps://maps.yandex.ru/?rtext=$startLat,$startLng~$endLat,$endLng&rtt=auto',
  );
  final webUri = Uri.parse(
    'https://yandex.ru/maps/?rtext=$startLat,$startLng~$endLat,$endLng&rtt=auto',
  );

  if (await canLaunchUrl(appUri)) {
    await launchUrl(appUri, mode: LaunchMode.externalApplication);
    return;
  }

  if (await canLaunchUrl(webUri)) {
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
    return;
  }

  throw Exception('Не удалось открыть Яндекс.Карты');
}
