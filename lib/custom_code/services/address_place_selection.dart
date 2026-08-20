import 'package:flutter/foundation.dart';

import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/point_struct.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Единый резолв выбора адреса (Suggest uri → координаты + подпись).
/// Использовать во всех экранах с AutocompleteCall / GeocodePlaceIDCall.
class ResolvedPlaceSelection {
  const ResolvedPlaceSelection({
    required this.ok,
    required this.needsHouseNumber,
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
  /// Улица без дома — оставить фокус в поле и дописать номер.
  final bool needsHouseNumber;
  final String addressLabel;
  final String? street;
  final String? number;
  final String? fullAddress;
  final String? city;
  final String? region;
  final String? placeId;
  final double? lat;
  final double? lng;

  PointStruct toPoint() {
    return PointStruct(
      latlng: (lat != null && lng != null) ? LatLng(lat!, lng!) : null,
      placeID: placeId,
      address: addressLabel,
      fullAddress: fullAddress,
      city: city,
      region: region,
    );
  }

  static const fail = ResolvedPlaceSelection(
    ok: false,
    needsHouseNumber: false,
    addressLabel: '',
  );
}

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
      return ResolvedPlaceSelection.fail;
    }

    final response = await GeocodePlaceIDCall.call(
      placeId: id.isNotEmpty ? id : main,
    );
    final body = response.jsonBody ?? '';
    final status = response.statusCode;
    final lat = GeocodePlaceIDCall.lat(body);
    final lng = GeocodePlaceIDCall.lng(body);
    final street = GeocodePlaceIDCall.street(body);
    final number = GeocodePlaceIDCall.number(body);
    final address = GeocodePlaceIDCall.address(body);
    final city = GeocodePlaceIDCall.areal2(body) ?? GeocodePlaceIDCall.city(body);
    final region = GeocodePlaceIDCall.areal(body);

    debugPrint(
      '[Search.$fieldTag] http=$status street="$street" number="$number" '
      'lat=$lat lng=$lng addr="${_short(address ?? '')}"',
    );

    if (lat == null || lng == null) {
      debugPrint('[Search.$fieldTag] FAIL no coords — field text NOT updated');
      return ResolvedPlaceSelection.fail;
    }

    final hasNumber = number != null && number.isNotEmpty;
    final hasStreet = street != null && street.isNotEmpty;
    final label = hasNumber && hasStreet
        ? '$street, $number'
        : (hasStreet
            ? street!
            : (address?.isNotEmpty == true
                ? address!
                : (main.isNotEmpty ? main : '')));

    if (label.isEmpty) {
      debugPrint('[Search.$fieldTag] FAIL empty label');
      return ResolvedPlaceSelection.fail;
    }

    final needsHouse = !hasNumber;
    debugPrint(
      '[Search.$fieldTag] OK branch=${needsHouse ? "needHouse" : "complete"} '
      'label="$label"',
    );

    return ResolvedPlaceSelection(
      ok: true,
      needsHouseNumber: needsHouse,
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
