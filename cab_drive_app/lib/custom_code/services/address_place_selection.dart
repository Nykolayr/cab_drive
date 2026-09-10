import 'package:flutter/foundation.dart';

import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/point_struct.dart';
import '/backend/schema/structs/sender_struct.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Результат тапа по подсказке адреса.
///
/// REGRESSION GUARD: тап по пункту списка ВСЕГДА либо `ok`+координаты+label,
/// либо явный fail. Запрещено оставлять «тихий» return без записи в поле.
class ResolvedPlaceSelection {
  const ResolvedPlaceSelection({
    required this.ok,
    required this.addressLabel,
    this.street,
    this.number,
    this.fullAddress,
    this.city,
    this.region,
    this.placeId,
    this.lat,
    this.lng,
  });

  final bool ok;
  final String addressLabel;
  final String? street;
  final String? number;
  final String? fullAddress;
  final String? city;
  final String? region;
  final String? placeId;
  final double? lat;
  final double? lng;

  PointStruct toPoint({SenderStruct? sender}) {
    return PointStruct(
      latlng: (lat != null && lng != null) ? LatLng(lat!, lng!) : null,
      placeID: placeId,
      address: addressLabel,
      fullAddress: fullAddress,
      city: city,
      region: region,
      sender: sender,
    );
  }
}

/// Единый резолв выбора адреса для A / B / karta.
///
/// Не дублировать логику в виджетах. Не возвращать «needHouse» — тап = выбор.
class AddressPlaceSelection {
  AddressPlaceSelection._();

  static Future<ResolvedPlaceSelection> resolve({
    required String fieldTag,
    String? placeId,
    String? mainText,
  }) async {
    final id = placeId?.trim() ?? '';
    final main = mainText?.trim() ?? '';
    debugPrint(
      '[Search.$fieldTag] tap placeId=${_short(id)} main="$main"',
    );

    if (id.isEmpty && main.isEmpty) {
      debugPrint('[Search.$fieldTag] FAIL empty placeId+main');
      return const ResolvedPlaceSelection(ok: false, addressLabel: '');
    }

    final response = await GeocodePlaceIDCall.call(
      placeId: id.isNotEmpty ? id : main,
    );
    var body = response.jsonBody ?? '';
    var status = response.statusCode;
    var lat = GeocodePlaceIDCall.lat(body);
    var lng = GeocodePlaceIDCall.lng(body);
    var street = GeocodePlaceIDCall.street(body);
    var number = GeocodePlaceIDCall.number(body);
    var address = GeocodePlaceIDCall.address(body);
    var city = GeocodePlaceIDCall.areal2(body) ?? GeocodePlaceIDCall.city(body);
    var region = GeocodePlaceIDCall.areal(body);

    debugPrint(
      '[Search.$fieldTag] http=$status street="$street" number="$number" '
      'lat=$lat lng=$lng addr="${_short(address ?? '')}"',
    );

    if ((lat == null || lng == null) &&
        main.isNotEmpty &&
        id.isNotEmpty &&
        id != main) {
      debugPrint('[Search.$fieldTag] no coords — retry mainText');
      final retry = await GeocodePlaceIDCall.call(placeId: main);
      body = retry.jsonBody ?? '';
      status = retry.statusCode;
      lat = GeocodePlaceIDCall.lat(body);
      lng = GeocodePlaceIDCall.lng(body);
      street = GeocodePlaceIDCall.street(body);
      number = GeocodePlaceIDCall.number(body);
      address = GeocodePlaceIDCall.address(body);
      city = GeocodePlaceIDCall.areal2(body) ?? GeocodePlaceIDCall.city(body);
      region = GeocodePlaceIDCall.areal(body);
      debugPrint(
        '[Search.$fieldTag] retry http=$status lat=$lat lng=$lng',
      );
    }

    if (lat == null || lng == null) {
      // Даже при fail отдаём текст подсказки — UI обязан записать его в поле.
      debugPrint(
        '[Search.$fieldTag] FAIL no coords — UI must still show main="$main"',
      );
      return ResolvedPlaceSelection(
        ok: false,
        addressLabel: main.isNotEmpty ? main : (address ?? ''),
      );
    }

    final hasNumber = number != null && number.isNotEmpty;
    final hasStreet = street != null && street.isNotEmpty;
    // Как в списке: сначала то, что видел пользователь (main).
    final label = main.isNotEmpty
        ? main
        : (hasNumber && hasStreet
            ? '$street, $number'
            : (hasStreet
                ? street!
                : (address?.isNotEmpty == true ? address! : '')));

    if (label.isEmpty) {
      debugPrint('[Search.$fieldTag] FAIL empty label');
      return const ResolvedPlaceSelection(ok: false, addressLabel: '');
    }

    debugPrint('[Search.$fieldTag] OK apply label="$label"');
    return ResolvedPlaceSelection(
      ok: true,
      addressLabel: label,
      street: street,
      number: number,
      fullAddress: address,
      city: city,
      region: region,
      placeId: id.isNotEmpty ? id : GeocodePlaceIDCall.placeId(body),
      lat: lat,
      lng: lng,
    );
  }

  static String _short(String v) {
    if (v.length <= 64) return v;
    return '${v.substring(0, 64)}…';
  }
}
