import 'dart:convert';

import 'package:http/http.dart' as http;

import '/custom_code/yandex/yandex_config.dart';
import '/flutter_flow/flutter_flow_util.dart';

class YandexGeocodeResult {
  const YandexGeocodeResult({
    required this.lat,
    required this.lon,
    required this.text,
    this.secondaryText = '',
  });

  final double lat;
  final double lon;
  final String text;
  final String secondaryText;

  String get placeId => '$lon,$lat';
}

/// Геокодер Яндекса (поиск и обратное геокодирование).
class YandexGeocoderService {
  YandexGeocoderService._();

  static const _baseUrl = 'https://geocode-maps.yandex.ru/1.x/';

  static String get _apiKey {
    if (YandexConfig.geocoderKey.isNotEmpty) {
      return YandexConfig.geocoderKey;
    }
    return YandexConfig.mapkitKey;
  }

  static bool get hasApiKey => YandexConfig.hasGeocoderKey;

  static Future<List<YandexGeocodeResult>> searchByAddress({
    required String query,
    String lang = 'ru_RU',
    int results = 10,
  }) async {
    if (!hasApiKey) return [];
    final q = query.trim();
    if (q.isEmpty) return [];

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'apikey': _apiKey,
        'geocode': q,
        'format': 'json',
        'lang': lang,
        'results': '$results',
      });
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];
      return _parseMembers(jsonDecode(response.body) as Map<String, dynamic>);
    } catch (_) {
      return [];
    }
  }

  static Future<YandexGeocodeResult?> reverseGeocode({
    required double lat,
    required double lon,
    String lang = 'ru_RU',
  }) async {
    if (!hasApiKey) return null;
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'apikey': _apiKey,
        'geocode': '$lon,$lat',
        'format': 'json',
        'lang': lang,
        'results': '1',
      });
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final list = _parseMembers(jsonDecode(response.body) as Map<String, dynamic>);
      return list.isEmpty ? null : list.first;
    } catch (_) {
      return null;
    }
  }

  static List<YandexGeocodeResult> _parseMembers(Map<String, dynamic> data) {
    final members = data['response']?['GeoObjectCollection']?['featureMember']
        as List<dynamic>?;
    if (members == null || members.isEmpty) return [];

    final list = <YandexGeocodeResult>[];
    for (final member in members) {
      final geo = (member as Map<String, dynamic>)['GeoObject']
          as Map<String, dynamic>?;
      if (geo == null) continue;

      final posStr = geo['Point']?['pos']?.toString();
      if (posStr == null || posStr.isEmpty) continue;
      final parts = posStr.trim().split(RegExp(r'\s+'));
      if (parts.length < 2) continue;

      final lon = double.tryParse(parts[0]);
      final lat = double.tryParse(parts[1]);
      if (lat == null || lon == null) continue;

      final meta = geo['metaDataProperty']?['GeocoderMetaData']
          as Map<String, dynamic>?;
      final text = meta?['text']?.toString() ??
          meta?['Address']?['formatted']?.toString() ??
          '';
      final components =
          meta?['Address']?['Components'] as List<dynamic>? ?? const [];
      var locality = '';
      var area = '';
      for (final c in components) {
        final kind = (c as Map)['kind']?.toString();
        final name = c['name']?.toString() ?? '';
        if (kind == 'locality') locality = name;
        if (kind == 'province' || kind == 'area') area = name;
      }

      list.add(
        YandexGeocodeResult(
          lat: lat,
          lon: lon,
          text: text,
          secondaryText: locality.isNotEmpty ? locality : area,
        ),
      );
    }
    return list;
  }

  /// JSON в формате, совместимом с парсерами Google Geocode в FF.
  static Map<String, dynamic> googleStyleGeocodeBody(YandexGeocodeResult r) {
    return {
      'results': [
        {
          'formatted_address': r.text,
          'place_id': r.placeId,
          'geometry': {
            'location': {'lat': r.lat, 'lng': r.lon},
          },
          'address_components': [
            {
              'long_name': r.secondaryText,
              'types': ['locality'],
            },
            {
              'long_name': r.secondaryText,
              'types': ['administrative_area_level_1'],
            },
          ],
        },
      ],
    };
  }

  static Map<String, dynamic> googleStyleAutocompleteBody(
    List<YandexGeocodeResult> results,
  ) {
    return {
      'predictions': results
          .map(
            (r) => {
              'place_id': r.placeId,
              'structured_formatting': {
                'main_text': r.text.split(',').first.trim(),
                'secondary_text': r.secondaryText.isNotEmpty
                    ? r.secondaryText
                    : r.text,
              },
            },
          )
          .toList(growable: false),
    };
  }

  static Map<String, dynamic> googleStyleDistanceMatrixBody({
    required String distanceText,
    required String durationText,
  }) {
    return {
      'rows': [
        {
          'elements': [
            {
              'distance': {'text': distanceText},
              'duration': {'text': durationText},
            },
          ],
        },
      ],
    };
  }

  static LatLng? parseLatLngPair(String value) {
    final parts = value.split(',');
    if (parts.length < 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }
}
