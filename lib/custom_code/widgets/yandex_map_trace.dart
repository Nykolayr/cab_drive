import 'package:flutter/foundation.dart';

/// Временные трассы карты (debug). Тег: YandexOrderMap.
void yandexMapTrace(String message, {String tag = 'YandexOrderMap'}) {
  if (kDebugMode) {
    debugPrint('[$tag] $message');
  }
}
