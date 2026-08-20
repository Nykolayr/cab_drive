import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:yandex_mapkit/yandex_mapkit.dart';

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

  /// place_id: uri Suggest + метаданные для резолва, либо lat,lng / текст.
  /// Разделитель — ASCII Unit Separator (не ломается в JSON/логах как таб).
  static const placeIdSep = '\u001f';

  String get placeId {
    // Координаты из MapKit Suggest важнее uri: uri требует HTTP Geocoder (у нас 403).
    if (lat.abs() > 0.01 || lon.abs() > 0.01) {
      return '$lat,$lon$placeIdSep$text$placeIdSep$house$placeIdSep$street'
          '$placeIdSep$cityOnly';
    }
    if (uri.isNotEmpty) {
      return '$uri$placeIdSep$text$placeIdSep$house$placeIdSep$street'
          '$placeIdSep$cityOnly';
    }
    return text;
  }

  YandexGeocodeResult copyWith({
    double? lat,
    double? lon,
    String? text,
    String? country,
    String? city,
    String? province,
    String? street,
    String? house,
    String? district,
    String? kind,
    String? uri,
    String? titleOverride,
    String? subtitleOverride,
  }) {
    return YandexGeocodeResult(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      text: text ?? this.text,
      country: country ?? this.country,
      city: city ?? this.city,
      province: province ?? this.province,
      street: street ?? this.street,
      house: house ?? this.house,
      district: district ?? this.district,
      kind: kind ?? this.kind,
      uri: uri ?? this.uri,
      titleOverride: titleOverride ?? this.titleOverride,
      subtitleOverride: subtitleOverride ?? this.subtitleOverride,
    );
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

  /// Последний HTTP-код geocode-maps (для логов UI: 403 ≠ «адрес не найден»).
  static int? lastResolveHttpStatus;

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
    final v = _placeIdHead(value);
    return v.startsWith('ymapsbm1://') || v.startsWith('yandexmaps://');
  }

  static String _placeIdHead(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return '';
    // Новый sep + старый tab (на случай кэша/старых ответов).
    return raw.split(RegExp('[\u001f\t]')).first.trim();
  }

  static List<String> _placeIdParts(String id) {
    return id.split(RegExp('[\u001f\t]'));
  }

  /// Нормализация для сравнения префикса с названием улицы.
  static String _normalizeStreetQuery(String raw) {
    var s = raw.toLowerCase().trim();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    s = s.replaceFirst(
      RegExp(
        r'^(улица|ул\.?|проспект|пр-т|пр\.?|переулок|пер\.?|проезд|площадь|пл\.?|бульвар|б-р|набережная|наб\.?)\s+',
      ),
      '',
    );
    return s.trim();
  }

  /// Префикс должен цепляться за улицу/дом в title, а не только за село в subtitle.
  static bool _titleMatchesQuery(YandexGeocodeResult r, String query) {
    final q = _normalizeStreetQuery(query);
    if (q.length < 2) return true;
    final title = _normalizeStreetQuery(
      r.titleOverride.isNotEmpty ? r.titleOverride : r.streetLine,
    );
    final street = _normalizeStreetQuery(r.street);
    final house = r.house.toLowerCase().trim();
    if (title.contains(q) || street.contains(q)) return true;
    // «елизаровых 56» — дом в title уже в title; отдельно дом как запрос.
    if (house.isNotEmpty && q.contains(house) && street.isNotEmpty) {
      final withoutHouse = q.replaceAll(house, '').trim();
      if (withoutHouse.isEmpty ||
          street.contains(withoutHouse) ||
          title.contains(withoutHouse)) {
        return true;
      }
    }
    return false;
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

      // Список адресов — как раньше: HTTP Geosuggest types=street,house
      // (MapKit Suggest сыпет сёла/реки — не для UI списка).
      var list = await _suggest(
        text: q,
        lang: lang.startsWith('ru') ? 'ru' : 'en',
        results: results,
        lon: bias.lon,
        lat: bias.lat,
      );
      list = list.where((r) => _titleMatchesQuery(r, q)).toList(growable: false);

      // Подтянуть center с MapKit по совпадению title (без смены состава списка).
      if (list.isNotEmpty) {
        list = await _attachMapKitCenters(
          list,
          query: q,
          lon: bias.lon,
          lat: bias.lat,
        );
      }

      if (list.isEmpty) {
        // Fallback: только house/street из MapKit, дома первыми.
        list = await _suggestMapKit(
          text: q,
          lon: bias.lon,
          lat: bias.lat,
          results: results,
        );
        list = list.where((r) => _titleMatchesQuery(r, q)).toList(growable: false);
      }
      if (list.isEmpty) {
        list = await _geocodeStreetFallback(q, lang, results, bias);
        list = list.where((r) => _titleMatchesQuery(r, q)).toList(growable: false);
      }

      if (kDebugMode) {
        final first = list.isEmpty
            ? '-'
            : '${list.first.taxiTitle} | ${list.first.taxiSubtitle}'
                ' lat=${list.first.lat} lng=${list.first.lon}';
        debugPrint('[Geocoder] suggest q="$q" n=${list.length} first=$first');
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

  /// Нативный MapKit Suggest — только street/house + center.
  static Future<List<YandexGeocodeResult>> _suggestMapKit({
    required String text,
    required double lon,
    required double lat,
    required int results,
  }) async {
    try {
      final sessionPair = await YandexSuggest.getSuggestions(
        text: text,
        boundingBox: BoundingBox(
          southWest: Point(latitude: lat - 0.35, longitude: lon - 0.45),
          northEast: Point(latitude: lat + 0.35, longitude: lon + 0.45),
        ),
        suggestOptions: SuggestOptions(
          suggestType: SuggestType.geo,
          suggestWords: true,
          userPosition: Point(latitude: lat, longitude: lon),
        ),
      );
      final session = sessionPair.$1;
      final result = await sessionPair.$2;
      await session.close();

      if (result.error != null) {
        debugPrint('[Geocoder] MapKitSuggest error: ${result.error}');
        return const [];
      }
      final items = result.items;
      if (items == null || items.isEmpty) {
        if (kDebugMode) {
          debugPrint('[Geocoder] MapKitSuggest empty');
        }
        return const [];
      }

      final out = <YandexGeocodeResult>[];
      for (final item in items) {
        if (item.type == SuggestItemType.business ||
            item.type == SuggestItemType.transit) {
          continue;
        }
        final tags =
            item.tags.map((e) => e.toString().toLowerCase()).toList(growable: false);
        final isHouse = tags.contains('house');
        final isStreet = tags.contains('street');
        // Как HTTP Geosuggest: только улица и дом — без сёл/рек/районов.
        if (!isHouse && !isStreet) continue;

        final title = item.title.trim();
        final subtitle = (item.subtitle ?? '').trim();
        var house = '';
        var street = '';
        if (isHouse || RegExp(r',\s*\d').hasMatch(title)) {
          final houseMatch =
              RegExp(r'(\d+[а-яА-Яa-zA-Z]?)\s*$').firstMatch(title);
          house = houseMatch?.group(1) ?? '';
          street = title
              .replaceAll(RegExp(r',\s*\d+[а-яА-Яa-zA-Z]?\s*$'), '')
              .trim();
        } else {
          street = title;
        }

        String city = '';
        if (subtitle.isNotEmpty) {
          final parts = subtitle.split(',').map((e) => e.trim()).toList();
          city = parts.isNotEmpty ? parts.last : subtitle;
        }

        final center = item.center;
        final display = item.displayText.trim().isNotEmpty
            ? item.displayText.trim()
            : title;
        out.add(
          YandexGeocodeResult(
            lat: center?.latitude ?? 0,
            lon: center?.longitude ?? 0,
            text: display,
            city: city,
            street: street,
            house: house,
            kind: isHouse ? 'house' : 'street',
            titleOverride: title.isNotEmpty ? title : display,
            subtitleOverride: subtitle,
          ),
        );
      }

      // Дома выше улиц; с координатами выше без.
      out.sort((a, b) {
        final aHouse = a.kind == 'house' || a.house.isNotEmpty;
        final bHouse = b.kind == 'house' || b.house.isNotEmpty;
        if (aHouse != bHouse) return aHouse ? -1 : 1;
        final aOk = a.lat.abs() > 0.01 || a.lon.abs() > 0.01;
        final bOk = b.lat.abs() > 0.01 || b.lon.abs() > 0.01;
        if (aOk == bOk) return 0;
        return aOk ? -1 : 1;
      });

      if (kDebugMode) {
        final withCenter =
            out.where((r) => r.lat.abs() > 0.01 || r.lon.abs() > 0.01).length;
        debugPrint(
          '[Geocoder] MapKitSuggest n=${out.length} withCenter=$withCenter'
          ' (street/house only)',
        );
      }
      return out.take(results.clamp(1, _maxSuggestions)).toList(growable: false);
    } catch (e, st) {
      debugPrint('[Geocoder] MapKitSuggest failed: $e\n$st');
      return const [];
    }
  }

  /// К HTTP-подсказкам (uri) приклеить lat/lng из MapKit при совпадении названия.
  static Future<List<YandexGeocodeResult>> _attachMapKitCenters(
    List<YandexGeocodeResult> httpList, {
    required String query,
    required double lon,
    required double lat,
  }) async {
    final mk = await _suggestMapKit(
      text: query,
      lon: lon,
      lat: lat,
      results: _maxSuggestions,
    );
    if (mk.isEmpty) return httpList;

    return httpList.map((h) {
      if (h.lat.abs() > 0.01 || h.lon.abs() > 0.01) return h;
      final hKey = _normalizeStreetQuery(h.taxiTitle);
      final hStreet = _normalizeStreetQuery(h.street);
      for (final m in mk) {
        if (m.lat.abs() < 0.01 && m.lon.abs() < 0.01) continue;
        final mKey = _normalizeStreetQuery(m.taxiTitle);
        final mStreet = _normalizeStreetQuery(m.street);
        final titleHit = hKey.isNotEmpty && (hKey == mKey || mKey.contains(hKey) || hKey.contains(mKey));
        final streetHit = hStreet.isNotEmpty &&
            mStreet.isNotEmpty &&
            (hStreet == mStreet) &&
            (h.house.isEmpty ||
                m.house.isEmpty ||
                h.house.toLowerCase() == m.house.toLowerCase());
        if (titleHit || streetHit) {
          return h.copyWith(lat: m.lat, lon: m.lon);
        }
      }
      return h;
    }).toList(growable: false);
  }

  /// Geosuggest HTTP: types=street,house — только адреса (без координат).
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
      // Окно вокруг пользователя (~город), чтобы сёла с похожим именем не доминировали.
      'spn': '0.45,0.45',
      'bbox': '${lon - 0.45},${lat - 0.35}~${lon + 0.45},${lat + 0.35}',
      'strict_bounds': '0',
      'highlight': '0',
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('[Geocoder] Suggest HTTP ${response.statusCode}');
      return [];
    }
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) return [];
    return _parseSuggest(data, query: text);
  }

  static List<YandexGeocodeResult> _parseSuggest(
    Map<String, dynamic> data, {
    String query = '',
  }) {
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
      final components = address?['component'] as List<dynamic> ?? const [];

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

      // Дом из title, если в components нет (часто у Suggest).
      if (house.isEmpty) {
        final houseMatch = RegExp(r'(\d+[а-яА-Яa-zA-Z]?)\s*$').firstMatch(title);
        if (houseMatch != null && isHouse) {
          house = houseMatch.group(1) ?? '';
        }
      }

      final parsed = YandexGeocodeResult(
        lat: 0,
        lon: 0,
        text: formatted.isNotEmpty ? formatted : title,
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
      );
      if (!_titleMatchesQuery(parsed, query)) continue;
      out.add(parsed);
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
    lastResolveHttpStatus = response.statusCode;
    if (response.statusCode != 200) {
      debugPrint('[Geocoder] geocode HTTP ${response.statusCode}');
      return [];
    }
    return _parseMembers(
      jsonDecode(response.body) as Map<String, dynamic>,
      russiaOnly: true,
    );
  }

  /// Когда HTTP Geocoder 403 (ключ без Geocoder API), координаты берём через MapKit.
  static Future<YandexGeocodeResult?> _resolveViaMapKit(String query) async {
    final q = query.trim();
    if (q.isEmpty) return null;
    try {
      if (kDebugMode) {
        debugPrint('[Geocoder] MapKit searchByText q="${q.length > 64 ? '${q.substring(0, 64)}…' : q}"');
      }
      final sessionPair = await YandexSearch.searchByText(
        searchText: q,
        geometry: Geometry.fromPoint(
          const Point(latitude: _moscowLat, longitude: _moscowLon),
        ),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
          resultPageSize: 5,
        ),
      );
      final session = sessionPair.$1;
      final result = await sessionPair.$2;
      await session.close();
      if (result.error != null) {
        debugPrint('[Geocoder] MapKit error: ${result.error}');
        return null;
      }
      final items = result.items;
      if (items == null || items.isEmpty) {
        debugPrint('[Geocoder] MapKit empty');
        return null;
      }
      final item = items.first;
      Point? point = item.toponymMetadata?.balloonPoint;
      if (point == null) {
        for (final g in item.geometry) {
          final p = g.point;
          if (p != null) {
            point = p;
            break;
          }
        }
      }
      if (point == null) {
        debugPrint('[Geocoder] MapKit no point');
        return null;
      }
      final comps = item.toponymMetadata?.address.addressComponents ?? const {};
      final street = comps[SearchComponentKind.street] ?? '';
      final house = comps[SearchComponentKind.house] ?? '';
      final city = comps[SearchComponentKind.locality] ?? '';
      final province = comps[SearchComponentKind.province] ?? '';
      final text = item.toponymMetadata?.address.formattedAddress ?? item.name;
      if (kDebugMode) {
        debugPrint(
          '[Geocoder] MapKit OK lat=${point.latitude} lng=${point.longitude} '
          'street=$street house=$house',
        );
      }
      return YandexGeocodeResult(
        lat: point.latitude,
        lon: point.longitude,
        text: text,
        city: city,
        province: province,
        street: street,
        house: house,
        kind: house.isNotEmpty ? 'house' : 'street',
      );
    } catch (e, st) {
      debugPrint('[Geocoder] MapKit failed: $e\n$st');
      return null;
    }
  }

  static String _composeAddressQuery({
    required String textHint,
    required String houseHint,
    required String streetHint,
    required String cityHint,
    required String headFallback,
  }) {
    if (streetHint.isNotEmpty) {
      final streetPart = houseHint.isNotEmpty
          ? '$streetHint, $houseHint'
          : streetHint;
      if (cityHint.isNotEmpty) return '$cityHint, $streetPart';
      return streetPart;
    }
    if (textHint.isNotEmpty) {
      if (cityHint.isNotEmpty &&
          !textHint.toLowerCase().contains(cityHint.toLowerCase())) {
        return '$cityHint, $textHint';
      }
      return textHint;
    }
    return headFallback;
  }

  /// Разрешить Suggest uri (или lat,lng / текст) в точку с координатами.
  static Future<YandexGeocodeResult?> resolvePlaceId(String placeId) async {
    final id = placeId.trim();
    if (id.isEmpty) return null;
    lastResolveHttpStatus = null;

    final parts = _placeIdParts(id);
    final head = parts.first.trim();
    final textHint = parts.length > 1 ? parts[1].trim() : '';
    final houseHint = parts.length > 2 ? parts[2].trim() : '';
    final streetHint = parts.length > 3 ? parts[3].trim() : '';
    final cityHint = parts.length > 4 ? parts[4].trim() : '';

    YandexGeocodeResult? enrich(YandexGeocodeResult? r) {
      if (r == null) return null;
      var out = r;
      if (out.house.isEmpty && houseHint.isNotEmpty) {
        out = out.copyWith(house: houseHint);
      }
      if (out.street.isEmpty && streetHint.isNotEmpty) {
        out = out.copyWith(street: streetHint);
      }
      if (out.city.isEmpty && cityHint.isNotEmpty) {
        out = out.copyWith(city: cityHint);
      }
      if (out.text.isEmpty && textHint.isNotEmpty) {
        out = out.copyWith(text: textHint);
      }
      return out;
    }

    if (isSuggestUri(head)) {
      if (kDebugMode) {
        debugPrint('[Geocoder] resolve uri=${head.length > 48 ? '${head.substring(0, 48)}…' : head}');
      }
      var list = await _geocode(
        geocode: '',
        lang: 'ru_RU',
        results: 1,
        lon: _moscowLon,
        lat: _moscowLat,
        uri: head,
      );
      if (list.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[Geocoder] resolve uri ok street=${list.first.street} house=${list.first.house}',
          );
        }
        return enrich(list.first);
      }
      final query = _composeAddressQuery(
        textHint: textHint,
        houseHint: houseHint,
        streetHint: streetHint,
        cityHint: cityHint,
        headFallback: '',
      );
      if (query.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[Geocoder] resolve uri empty → geocode text');
        }
        list = await _geocode(
          geocode: query,
          lang: 'ru_RU',
          results: 1,
          lon: _moscowLon,
          lat: _moscowLat,
        );
        if (list.isNotEmpty) return enrich(list.first);
        final viaMapKit = await _resolveViaMapKit(query);
        if (viaMapKit != null) return enrich(viaMapKit);
      }
      debugPrint(
        '[Geocoder] resolve uri failed http=$lastResolveHttpStatus',
      );
      return null;
    }

    final coords = parseLatLngPair(head);
    if (coords != null) {
      final reversed = await reverseGeocode(
        lat: coords.latitude,
        lon: coords.longitude,
      );
      if (reversed != null) return enrich(reversed);
      // Координаты уже из MapKit Suggest — reverse может дать 403, не теряем точку.
      final label = textHint.isNotEmpty
          ? textHint
          : _composeAddressQuery(
              textHint: '',
              houseHint: houseHint,
              streetHint: streetHint,
              cityHint: cityHint,
              headFallback: head,
            );
      if (kDebugMode) {
        debugPrint(
          '[Geocoder] resolve latlng from suggest '
          'lat=${coords.latitude} lng=${coords.longitude} (no reverse)',
        );
      }
      return enrich(
        YandexGeocodeResult(
          lat: coords.latitude,
          lon: coords.longitude,
          text: label,
          city: cityHint,
          street: streetHint,
          house: houseHint,
          kind: houseHint.isNotEmpty ? 'house' : 'street',
        ),
      );
    }
    // Текст адреса — прямой геокод, затем MapKit.
    final query = _composeAddressQuery(
      textHint: textHint.isNotEmpty ? textHint : head,
      houseHint: houseHint,
      streetHint: streetHint,
      cityHint: cityHint,
      headFallback: head,
    );
    final list = await _geocode(
      geocode: query,
      lang: 'ru_RU',
      results: 1,
      lon: _moscowLon,
      lat: _moscowLat,
    );
    if (list.isNotEmpty) return enrich(list.first);
    return enrich(await _resolveViaMapKit(query));
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
