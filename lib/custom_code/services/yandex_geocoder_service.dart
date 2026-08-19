import 'dart:math' as math;

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

  /// Google-совместимый order: lat,lng (не lon,lat Яндекса).
  String get placeId => '$lat,$lon';

  String get localityLine {
    final parts = <String>[];
    if (country.isNotEmpty) parts.add(country);
    final cityName = city.isNotEmpty ? city : province;
    if (cityName.isNotEmpty && cityName != country) {
      parts.add(cityName);
    }
    return parts.join(', ');
  }

  /// Город без страны: «Хамовники, Москва».
  String get cityLine {
    final parts = <String>[];
    if (district.isNotEmpty) parts.add(district);
    final cityName = city.isNotEmpty ? city : province;
    if (cityName.isNotEmpty && cityName != district) {
      parts.add(cityName);
    }
    return parts.join(', ');
  }

  String get streetLine {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (house.isNotEmpty) parts.add(house);
    if (parts.isNotEmpty) return parts.join(', ');
    final loc = localityLine;
    if (loc.isNotEmpty && text.startsWith(loc) && text.length > loc.length) {
      final rest =
          text.substring(loc.length).replaceFirst(RegExp(r'^,\s*'), '');
      if (rest.isNotEmpty) return rest;
    }
    return '';
  }

  /// Как в Яндекс Такси: крупно улица/дом.
  String get taxiTitle {
    if (streetLine.isNotEmpty) return streetLine;
    if (city.isNotEmpty) return city;
    if (province.isNotEmpty) return province;
    return text;
  }

  /// Как в Яндекс Такси: серым город (без страны).
  String get taxiSubtitle {
    if (streetLine.isNotEmpty) return cityLine;
    if (province.isNotEmpty && province != city) return province;
    return '';
  }

  String get secondaryText => city.isNotEmpty ? city : province;
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

  /// bbox России: Калининград … Чукотка (lon,lat~lon,lat).
  static const _russiaBbox = '19.6,41.2~180,81.9';
  static const _moscowLon = 37.6173;
  static const _moscowLat = 55.7558;
  static const _nearbyRadiusKm = 20.0;
  static const _maxSuggestions = 10;
  static const _earthRadiusKm = 6371.0;

  static Future<List<YandexGeocodeResult>> searchByAddress({
    required String query,
    String? location,
    String lang = 'ru_RU',
    int results = 20,
    String types = 'geocode',
  }) async {
    if (!hasApiKey) return [];
    final q = query.trim();
    if (q.isEmpty) return [];

    final forLocality = types.contains('locality');
    try {
      final bias = _parseBias(location);
      var list = await _geocode(
        geocode: q,
        lang: lang,
        results: results,
        lon: bias.lon,
        lat: bias.lat,
        kind: forLocality ? 'locality' : null,
        nearbyOnly: !forLocality,
      );
      if (list.isEmpty) {
        list = await _geocode(
          geocode: 'Россия, $q',
          lang: lang,
          results: results,
          lon: bias.lon,
          lat: bias.lat,
          kind: forLocality ? 'locality' : null,
          nearbyOnly: !forLocality,
        );
      }
      if (!forLocality && !_hasStreetLevel(list)) {
        final streets = await _geocode(
          geocode: q,
          lang: lang,
          results: results,
          lon: bias.lon,
          lat: bias.lat,
          kind: 'street',
          nearbyOnly: true,
        );
        list = _mergeUnique([...streets, ...list]);
      }
      list = _filterAndSort(list, forLocality: forLocality);
      if (!forLocality) {
        list = _withinRadius(list, bias.lat, bias.lon, _nearbyRadiusKm);
      }
      if (kDebugMode) {
        debugPrint(
          '[Geocoder] q="$q" types=$types n=${list.length}'
          ' radiusKm=${forLocality ? "-" : _nearbyRadiusKm}'
          ' first=${list.isEmpty ? "-" : "${list.first.taxiTitle} | ${list.first.taxiSubtitle}"}',
        );
      }
      return list.take(_maxSuggestions).toList(growable: false);
    } catch (e, st) {
      debugPrint('[Geocoder] search failed: $e\n$st');
      return [];
    }
  }

  static Future<List<YandexGeocodeResult>> _geocode({
    required String geocode,
    required String lang,
    required int results,
    required double lon,
    required double lat,
    String? kind,
    bool nearbyOnly = false,
  }) async {
    final params = <String, String>{
      'apikey': _apiKey,
      'geocode': geocode,
      'format': 'json',
      'lang': lang,
      'results': '$results',
      'll': '$lon,$lat',
      'rspn': '1',
    };
    if (nearbyOnly) {
      params['spn'] = _spanForRadiusKm(lat, _nearbyRadiusKm);
    } else {
      params['spn'] = '2.5,2.5';
      params['bbox'] = _russiaBbox;
    }
    if (kind != null && kind.isNotEmpty) {
      params['kind'] = kind;
    }
    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('[Geocoder] HTTP ${response.statusCode}');
      return [];
    }
    return _parseMembers(
      jsonDecode(response.body) as Map<String, dynamic>,
      russiaOnly: true,
    );
  }

  /// Google `lat,lng`, `LatLng(lat: …, lng: …)` или Яндекс не используем.
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

  /// spn Яндекса: ширина/высота окна в градусах ≈ радиус.
  static String _spanForRadiusKm(double lat, double radiusKm) {
    const kmPerDegLat = 111.32;
    final latSpan = (2 * radiusKm / kmPerDegLat).clamp(0.05, 2.0);
    final cosLat = math.cos(lat * math.pi / 180).abs().clamp(0.2, 1.0);
    final lonSpan = (2 * radiusKm / (kmPerDegLat * cosLat)).clamp(0.05, 4.0);
    return '${lonSpan.toStringAsFixed(4)},${latSpan.toStringAsFixed(4)}';
  }

  static List<YandexGeocodeResult> _withinRadius(
    List<YandexGeocodeResult> list,
    double lat,
    double lon,
    double radiusKm,
  ) {
    return list
        .where((r) => _distanceKm(lat, lon, r.lat, r.lon) <= radiusKm)
        .toList();
  }

  static double _distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * _earthRadiusKm * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * math.pi / 180;

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

  static bool _hasStreetLevel(List<YandexGeocodeResult> list) {
    return list.any((r) =>
        r.kind == 'house' ||
        r.kind == 'street' ||
        r.street.isNotEmpty ||
        r.house.isNotEmpty);
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

  static List<YandexGeocodeResult> _filterAndSort(
    List<YandexGeocodeResult> list, {
    required bool forLocality,
  }) {
    final filtered = list.where((r) {
      if (forLocality) {
        return r.kind == 'locality' ||
            r.kind == 'province' ||
            r.city.isNotEmpty;
      }
      return r.kind != 'country';
    }).toList();
    filtered.sort((a, b) => _kindRank(a.kind).compareTo(_kindRank(b.kind)));
    return filtered;
  }

  static int _kindRank(String kind) {
    switch (kind) {
      case 'house':
        return 0;
      case 'street':
        return 1;
      case 'district':
      case 'metro':
        return 2;
      case 'locality':
        return 3;
      case 'area':
      case 'province':
        return 4;
      default:
        return 5;
    }
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
