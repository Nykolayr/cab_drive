// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:url_launcher/url_launcher.dart';
import '/flutter_flow/lat_lng.dart';

Future<void> open2GISRoute(LatLng startLatLng, LatLng endLatLng) async {
  try {
    // Извлекаем широту и долготу начальной и конечной точки
    final startLat = startLatLng.latitude;
    final startLng = startLatLng.longitude;
    final endLat = endLatLng.latitude;
    final endLng = endLatLng.longitude;

    // Проверяем, что координаты находятся в допустимом диапазоне
    if (startLat < -90 || startLat > 90 || endLat < -90 || endLat > 90) {
      throw Exception('Широта должна быть в диапазоне от -90 до 90');
    }
    if (startLng < -180 || startLng > 180 || endLng < -180 || endLng > 180) {
      throw Exception('Долгота должна быть в диапазоне от -180 до 180');
    }

    // Формируем URL для маршрута в 2ГИС
    final dgisUrl = Uri.encodeFull(
        'https://2gis.ru/routeSearch/rsType/car/from/$startLat,$startLng/to/$endLat,$endLng');

    // Логируем URL для отладки
    print('Сформированный URL: $dgisUrl');

    // Проверяем возможность открытия URL и открываем его
    final uri = Uri.parse(dgisUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Не удалось открыть 2ГИС для маршрута');
    }
  } catch (e) {
    // Обрабатываем ошибки
    print('Ошибка при открытии маршрута в 2ГИС: $e');
  }
}
