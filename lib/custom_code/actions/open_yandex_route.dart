// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:url_launcher/url_launcher.dart';
import '/flutter_flow/lat_lng.dart';

Future<void> openYandexRoute(LatLng startLatLng, LatLng endLatLng) async {
  final startLat = startLatLng.latitude;
  final startLng = startLatLng.longitude;
  final endLat = endLatLng.latitude;
  final endLng = endLatLng.longitude;

  // Формируем URL для маршрута в Яндекс.Картах
  final yandexUrl =
      'yandexmaps://maps.yandex.ru/?rtext=$startLat,$startLng~$endLat,$endLng&rtt=auto';

  // Проверяем возможность открытия URL и запускаем
  if (await canLaunchUrl(Uri.parse(yandexUrl))) {
    await launchUrl(Uri.parse(yandexUrl));
  } else {
    throw Exception('Не удалось открыть Яндекс.Карты для маршрута');
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
