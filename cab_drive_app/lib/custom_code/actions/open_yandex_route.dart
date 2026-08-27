// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '/flutter_flow/lat_lng.dart';

/// Маршрут A→B: Навигатор → Карты → магазин → браузер.
Future<void> openYandexRoute(LatLng startLatLng, LatLng endLatLng) async {
  final startLat = startLatLng.latitude;
  final startLng = startLatLng.longitude;
  final endLat = endLatLng.latitude;
  final endLng = endLatLng.longitude;

  final naviUri = Uri.parse(
    'yandexnavi://build_route_on_map'
    '?lat_from=$startLat&lon_from=$startLng'
    '&lat_to=$endLat&lon_to=$endLng',
  );
  if (await _tryLaunch(naviUri)) return;

  final mapsAppUri = Uri.parse(
    'yandexmaps://maps.yandex.ru/?rtext=$startLat,$startLng~$endLat,$endLng&rtt=auto',
  );
  if (await _tryLaunch(mapsAppUri)) return;

  if (!kIsWeb && Platform.isAndroid) {
    final market = Uri.parse('market://details?id=ru.yandex.yandexnavi');
    if (await _tryLaunch(market)) return;
    final play = Uri.parse(
      'https://play.google.com/store/apps/details?id=ru.yandex.yandexnavi',
    );
    if (await _tryLaunch(play)) return;
  }

  if (!kIsWeb && Platform.isIOS) {
    final appStore = Uri.parse('https://apps.apple.com/app/id474500851');
    if (await _tryLaunch(appStore)) return;
  }

  final webUri = Uri.parse(
    'https://yandex.ru/maps/?rtext=$startLat,$startLng~$endLat,$endLng&rtt=auto',
  );
  final launched = await _tryLaunch(webUri);
  if (!launched) {
    throw Exception('Не удалось открыть Яндекс Навигатор');
  }
}

Future<bool> _tryLaunch(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
