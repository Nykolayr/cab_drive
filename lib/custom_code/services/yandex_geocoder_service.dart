import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '/custom_code/yandex/yandex_config.dart';
import '/flutter_flow/flutter_flow_util.dart';

class YandexGeocodeResult {
  const YandexGeocodeResult({
    required this.lat,
    required this.lon,
    required this.text,
    this.country = '',
    this.city = '',
    this.province = '',
    this.street = '',
    this.house = '',
    this.district = '',
    this.kind = '',
    this.uri = '',
    this.titleOverride = '',
    this.subtitleOverride = '',
  });

  final double lat;
  final double lon;
  final String text;
  final String country;
  final String city;
  final String province;
  final String street;
  final String house;
  final String district;
  final String kind;
  /// uri из Geosuggest — для геокодера при выборе пункта.
  final String uri;
  final String titleOverride;
  final String subtitleOverride;

  /// place_id: uri Suggest или lat,lng.
  String get placeId {
    if (uri.isNotEmpty) return uri;
    return '$lat,$lon';
  }

  String get streetLine {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (house.isNotEmpty) parts.add(house);
    return parts.join(', ');
  }

  String get cityOnly {
    if (city.isNotEmpty) return city;
    if (province.isNotEmpty) return province;
    return '';
  }

  /// Как в Яндекс Такси: крупно улица/дом.
  String get taxiTitle {
    if (titleOverride.isNotEmpty) return titleOverride;
    if (streetLine.isNotEmpty) return streetLine;
    return text;
  }

  /// Как в Яндекс Такси: серым город.
  String get taxiSubtitle {
    if (subtitleOverride.isNotEmpty) return subtitleOverride;
    return cityOnly;
  }

  String get secondaryText => cityOnly;
}

/// Поиск адресов: Geosuggest (префикс как в Такси) + геокодер для координат.
class YandexGeocoderService {
  YandexGeocoderService._();

  static const _geocodeUrl = 'https://geocode-maps.yandex.ru/1.x/';
  static const _suggestUrl = 'https://suggest-maps.yandex.ru/v1/suggest';

  static String get _geocodeApiKey {
    if (YandexConfig.geocoderKey.isNotEmpty) {
      return YandexConfig.geocoderKey;
    }
    return YandexConfig.mapkitKey;
  }

  static String get _suggestApiKey {
    if (YandexConfig.suggestKey.isNotEmpty) {
      return YandexConfig.suggestKey;
    }
    return _geocodeApiKey;
  }

  static bool get hasApiKey => YandexConfig.hasGeocoderKey;

  static const _russiaBbox = '19.6,41.2~180,81.9';
  static const _moscowLon = 37.6173;
  static const _moscowLat = 55.7558;
  static const _maxSuggestions = 10;
  /// Префикс как в Такси: с 4 символов уже ищем.
  static const minSuggestChars = 4;

  static bool isSuggestUri(String? value) {
    final v = value?.trim() ?? '';
    return v.startsWith('ymapsbm1://') || v.startsWith('yandexmaps://');
  }

  static Future<List<YandexGeocodeResult>> searchByAddress({
    required String query,
    String? location,
    String lang = 'ru_RU',
    int results = 10,
    String types = 'geocode',
  }) async {
    if (!hasApiKey) return [];
    final q = query.trim();
    if (q.isEmpty) return [];

    final forLocality = types.contains('locality');
    try {
      final bias = _parseBias(location);

      if (forLocality) {
        return await _searchLocalities(q, lang, results, bias);
      }

      if (q.length < minSuggestChars) {
        if (kDebugMode) {
          debugPrint('[Geocoder] skip suggest, len=${q.length} < $minSuggestChars');
        }
        return const [];
      }

      // Основной путь — Geosuggest (префикс), как в Яндекс Такси.
      var list = await _suggest(
        text: q,
        lang: lang.startsWith('ru') ? 'ru' : 'en',
        results: results,
        lon: bias.lon,
        lat: bias.lat,
      );
      if (list.isEmpty) {
        // Fallback: геокодер street/house, если Suggest недоступен по ключу.
        list = await _geocodeStreetFallback(q, lang, results, bias);
      }

      if (kDebugMode) {
        debugPrint(
          '[Geocoder] suggest q="$q" n=${list.length}'
          ' first=${list.isEmpty ? "-" : "${list.first.taxiTitle} | ${list.first.taxiSubtitle}"}',
        );
      }
      return list.take(_maxSuggestions).toList(growable: false);
    } catch (e, st) {
      debugPrint('[Geocoder] search failed: $e\n$st');
      return [];
    }
  }

  static Future<List<YandexGeocodeResult>> _searchLocalities(
    String q,
    String lang,
    int results,
    ({double lat, double lon}) bias,
  ) async {
    var list = await _geocode(
      geocode: q,
      lang: lang,
      results: results,
      lon: bias.lon,
      lat: bias.lat,
      kind: 'locality',
    );
    if (list.isEmpty) {
      list = await _geocode(
        geocode: 'Россия, $q',
        lang: lang,
        results: results,
        lon: bias.lon,
        lat: bias.lat,
        kind: 'locality',
      );
    }
    return list
        .where((r) =>
            r.kind == 'locality' ||
            r.kind == 'province' ||
            r.city.isNotEmpty)
        .take(_maxSuggestions)
        .toList(growable: false);
  }

  /// Geosuggest: types=street,house — только адреса.
  static Future<List<YandexGeocodeResult>> _suggest({
    required String text,
    required String lang,
    required int results,
    required double lon,
    required double lat,
  }) async {
    final uri = Uri.parse(_suggestUrl).replace(queryParameters: {
      'apikey': _suggestApiKey,
      'text': text,
      'lang': lang,
      'results': '${results.clamp(1, 10)}',
      'types': 'street,house',
      'print_address': '1',
      'attrs': 'uri',
      'countries': 'ru',
      'll': '$lon,$lat',
      'ull': '$lon,$lat',
      'highlight': '0',
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('[Geocoder] Suggest HTTP ${response.statusCode}');
      return [];
    }
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) return [];
    return _parseSuggest(data);
  }

  static List<YandexGeocodeResult> _parseSuggest(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return [];

    final out = <YandexGeocodeResult>[];
    for (final item in results) {
      if (item is! Map<String, dynamic>) continue;
      final tags = (item['tags'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          const [];
      final isStreet = tags.contains('street');
      final isHouse = tags.contains('house');
      if (!isStreet && !isHouse) continue;

      final title = (item['title'] as Map?)?['text']?.toString() ?? '';
      final subtitle = (item['subtitle'] as Map?)?['text']?.toString() ?? '';
      final uri = item['uri']?.toString() ?? '';
      final address = item['address'] as Map<String, dynamic>?;
      final formatted = address?['formatted_address']?.toString() ?? title;
      final components = address?['component'] as List<dynamic>? ?? const [];

      String city = '';
      String province = '';
      String street = '';
      String house = '';
      for (final c in components) {
        if (c is! Map) continue;
        final name = c['name']?.toString() ?? '';
        final kinds = (c['kind'] as List<dynamic>?)
                ?.map((e) => e.toString().toLowerCase())
                .toList() ??
            const [];
        if (kinds.contains('locality') && city.isEmpty) city = name;
        if (kinds.contains('province') && province.isEmpty) province = name;
        if (kinds.contains('street') && street.isEmpty) street = name;
        if (kinds.contains('house') && house.isEmpty) house = name;
      }

      out.add(
        YandexGeocodeResult(
          lat: 0,
          lon: 0,
          text: formatted,
          city: city,
          province: province,
          street: street,
          house: house,
          kind: isHouse ? 'house' : 'street',
          uri: uri,
          titleOverride: title.isNotEmpty
              ? title
              : (street.isNotEmpty
                  ? [street, if (house.isNotEmpty) house].join(', ')
                  : formatted),
          subtitleOverride: subtitle.isNotEmpty
              ? subtitle
              : (city.isNotEmpty ? city : province),
        ),
      );
    }
    return out;
  }

  static Future<List<YandexGeocodeResult>> _geocodeStreetFallback(
    String q,
    String lang,
    int results,
    ({double lat, double lon}) bias,
  ) async {
    final houses = await _geocode(
      geocode: q,
      lang: lang,
      results: results,
      lon: bias.lon,
      lat: bias.lat,
      kind: 'house',
    );
    final streets = await _geocode(
      geocode: q,
      lang: lang,
      results: results,
      lon: bias.lon,
      lat: bias.lat,
      kind: 'street',
    );
    final merged = _mergeUnique([...houses, ...streets]);
    return merged.where((r) {
      return r.kind == 'house' ||
          r.kind == 'street' ||
          r.street.isNotEmpty ||
          r.house.isNotEmpty;
    }).toList();
  }

  static Future<List<YandexGeocodeResult>> _geocode({
    required String geocode,
    required String lang,
    required int results,
    required double lon,
    required double lat,
    String? kind,
    String? uri,
  }) async {
    final params = <String, String>{
      'apikey': _geocodeApiKey,
      'format': 'json',
      'lang': lang,
      'results': '$results',
    };
    if (uri != null && uri.isNotEmpty) {
      params['uri'] = uri;
    } else {
      params['geocode'] = geocode;
      params['ll'] = '$lon,$lat';
      params['spn'] = '2.5,2.5';
      params['bbox'] = _russiaBbox;
      params['rspn'] = '0';
      if (kind != null && kind.isNotEmpty) {
        params['kind'] = kind;
      }
    }
    final requestUri = Uri.parse(_geocodeUrl).replace(queryParameters: params);
    final response = await http.get(requestUri);
    if (response.statusCode != 200) {
      debugPrint('[Geocoder] geocode HTTP ${response.statusCode}');
      return [];
    }
    return _parseMembers(
      jsonDecode(response.body) as Map<String, dynamic>,
      russiaOnly: true,
    );
  }

  /// Разрешить Suggest uri (или lat,lng) в точку с координатами.
  static Future<YandexGeocodeResult?> resolvePlaceId(String placeId) async {
    final id = placeId.trim();
    if (id.isEmpty) return null;
    if (isSuggestUri(id)) {
      final list = await _geocode(
        geocode: '',
        lang: 'ru_RU',
        results: 1,
        lon: _moscowLon,
        lat: _moscowLat,
        uri: id,
      );
      return list.isEmpty ? null : list.first;
    }
    final coords = parseLatLngPair(id);
    if (coords != null) {
      return reverseGeocode(lat: coords.latitude, lon: coords.longitude);
    }
    // Текст адреса — прямой геокод.
    final list = await _geocode(
      geocode: id,
      lang: 'ru_RU',
      results: 1,
      lon: _moscowLon,
      lat: _moscowLat,
    );
    return list.isEmpty ? null : list.first;
  }

  static ({double lat, double lon}) _parseBias(String? raw) {
    const fallback = (lat: _moscowLat, lon: _moscowLon);
    if (raw == null || raw.trim().isEmpty) return fallback;

    final named = RegExp(
      r'lat:\s*(-?\d+(?:\.\d+)?)[\s\S]*?lng:\s*(-?\d+(?:\.\d+)?)',
    ).firstMatch(raw);
    if (named != null) {
      final lat = double.tryParse(named.group(1)!);
      final lon = double.tryParse(named.group(2)!);
      if (lat != null && lon != null && _isUsableBias(lat, lon)) {
        return (lat: lat, lon: lon);
      }
    }

    final pair = parseLatLngPair(raw);
    if (pair != null && _isUsableBias(pair.latitude, pair.longitude)) {
      return (lat: pair.latitude, lon: pair.longitude);
    }
    return fallback;
  }

  static bool _isUsableBias(double lat, double lon) {
    if (lat.abs() < 0.01 && lon.abs() < 0.01) return false;
    return lat >= 41 && lat <= 82 && lon >= 19 && lon <= 180;
  }

  static Future<YandexGeocodeResult?> reverseGeocode({
    required double lat,
    required double lon,
    String lang = 'ru_RU',
  }) async {
    if (!hasApiKey) return null;
    try {
      final uri = Uri.parse(_geocodeUrl).replace(queryParameters: {
        'apikey': _geocodeApiKey,
        'geocode': '$lon,$lat',
        'format': 'json',
        'lang': lang,
        'results': '1',
      });
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final list =
          _parseMembers(jsonDecode(response.body) as Map<String, dynamic>);
      return list.isEmpty ? null : list.first;
    } catch (e) {
      debugPrint('[Geocoder] reverse failed: $e');
      return null;
    }
  }

  static List<YandexGeocodeResult> _parseMembers(
    Map<String, dynamic> data, {
    bool russiaOnly = false,
  }) {
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
      if (russiaOnly) {
        final countryCode =
            meta?['Address']?['country_code']?.toString().toUpperCase();
        if (countryCode != null &&
            countryCode.isNotEmpty &&
            countryCode != 'RU') {
          continue;
        }
      }

      final components =
          meta?['Address']?['Components'] as List<dynamic>? ?? const [];
      final kind = meta?['kind']?.toString() ?? '';

      list.add(
        YandexGeocodeResult(
          lat: lat,
          lon: lon,
          text: text,
          country: _component(components, 'country'),
          city: _component(components, 'locality'),
          province: _component(components, 'province'),
          street: _component(components, 'street'),
          house: _component(components, 'house'),
          district: _component(components, 'district'),
          kind: kind,
        ),
      );
    }
    return list;
  }

  static String _component(List<dynamic> components, String kind) {
    for (final c in components) {
      if ((c as Map)['kind']?.toString() == kind) {
        return c['name']?.toString() ?? '';
      }
    }
    return '';
  }

  static List<YandexGeocodeResult> _mergeUnique(
    List<YandexGeocodeResult> items,
  ) {
    final seen = <String>{};
    final out = <YandexGeocodeResult>[];
    for (final r in items) {
      final key = '${r.placeId}|${r.text}';
      if (seen.add(key)) out.add(r);
    }
    return out;
  }

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
              'long_name': r.city.isNotEmpty ? r.city : r.province,
              'types': ['locality'],
            },
            {
              'long_name': r.city.isNotEmpty ? r.city : r.province,
              'types': ['administrative_area_level_2'],
            },
            {
              'long_name': r.province.isNotEmpty ? r.province : r.city,
              'types': ['administrative_area_level_1'],
            },
            {
              'long_name': r.street,
              'types': ['route'],
            },
            {
              'long_name': r.house,
              'types': ['street_number'],
            },
          ],
        },
      ],
    };
  }

  static Map<String, dynamic> googleStyleAutocompleteBody(
    List<YandexGeocodeResult> results, {
    String types = 'geocode',
  }) {
    final forLocality = types.contains('locality');
    return {
      'predictions': results
          .map(
            (r) => {
              'place_id': r.placeId,
              'structured_formatting': {
                'main_text': forLocality
                    ? (r.city.isNotEmpty ? r.city : r.taxiTitle)
                    : r.taxiTitle,
                'secondary_text': forLocality
                    ? (r.country.isNotEmpty ? r.country : 'Россия')
                    : r.taxiSubtitle,
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
