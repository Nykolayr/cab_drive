// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationModelImpl _$$LocationModelImplFromJson(Map<String, dynamic> json) =>
    _$LocationModelImpl(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$$LocationModelImplToJson(_$LocationModelImpl instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
    };

_$DriverModelImpl _$$DriverModelImplFromJson(Map<String, dynamic> json) =>
    _$DriverModelImpl(
      uid: json['uid'] as String,
      display_name: json['display_name'] as String?,
      phone_number: json['phone_number'] as String?,
      mark: json['mark'] as String?,
      commission_percent: (json['commission_percent'] as num?)?.toDouble(),
      is_blocked: json['is_blocked'] as bool?,
      on_shift: json['on_shift'] as bool?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      distance_km: (json['distance_km'] as num).toDouble(),
    );

Map<String, dynamic> _$$DriverModelImplToJson(_$DriverModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'display_name': instance.display_name,
      'phone_number': instance.phone_number,
      'mark': instance.mark,
      'commission_percent': instance.commission_percent,
      'is_blocked': instance.is_blocked,
      'on_shift': instance.on_shift,
      'lat': instance.lat,
      'lng': instance.lng,
      'distance_km': instance.distance_km,
    };

_$ETAItemModelImpl _$$ETAItemModelImplFromJson(Map<String, dynamic> json) =>
    _$ETAItemModelImpl(
      eta_seconds: (json['eta_seconds'] as num).toInt(),
      eta_text: json['eta_text'] as String,
    );

Map<String, dynamic> _$$ETAItemModelImplToJson(_$ETAItemModelImpl instance) =>
    <String, dynamic>{
      'eta_seconds': instance.eta_seconds,
      'eta_text': instance.eta_text,
    };

_$ETAResponseModelImpl _$$ETAResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ETAResponseModelImpl(
      etas: (json['etas'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            e == null
                ? null
                : ETAItemModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$ETAResponseModelImplToJson(
        _$ETAResponseModelImpl instance) =>
    <String, dynamic>{
      'etas': instance.etas,
    };

_$PriceBreakdownModelImpl _$$PriceBreakdownModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PriceBreakdownModelImpl(
      price_base: (json['price_base'] as num).toDouble(),
      price_after_tariff: (json['price_after_tariff'] as num).toDouble(),
    );

Map<String, dynamic> _$$PriceBreakdownModelImplToJson(
        _$PriceBreakdownModelImpl instance) =>
    <String, dynamic>{
      'price_base': instance.price_base,
      'price_after_tariff': instance.price_after_tariff,
    };

_$PriceItemModelImpl _$$PriceItemModelImplFromJson(Map<String, dynamic> json) =>
    _$PriceItemModelImpl(
      price: (json['price'] as num).toDouble(),
      distance_km: (json['distance_km'] as num).toDouble(),
      duration_sec: (json['duration_sec'] as num).toInt(),
      tariff_multiplier: (json['tariff_multiplier'] as num).toDouble(),
      congestion_multiplier: (json['congestion_multiplier'] as num).toDouble(),
      available_drivers_in_radius:
          (json['available_drivers_in_radius'] as num).toInt(),
      breakdown: PriceBreakdownModel.fromJson(
          json['breakdown'] as Map<String, dynamic>),
      intermediate_point: json['intermediate_point'] == null
          ? null
          : LocationModel.fromJson(
              json['intermediate_point'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PriceItemModelImplToJson(
        _$PriceItemModelImpl instance) =>
    <String, dynamic>{
      'price': instance.price,
      'distance_km': instance.distance_km,
      'duration_sec': instance.duration_sec,
      'tariff_multiplier': instance.tariff_multiplier,
      'congestion_multiplier': instance.congestion_multiplier,
      'available_drivers_in_radius': instance.available_drivers_in_radius,
      'breakdown': instance.breakdown,
      'intermediate_point': instance.intermediate_point,
    };

_$PricesResponseModelImpl _$$PricesResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PricesResponseModelImpl(
      prices: (json['prices'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            e == null
                ? null
                : PriceItemModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$$PricesResponseModelImplToJson(
        _$PricesResponseModelImpl instance) =>
    <String, dynamic>{
      'prices': instance.prices,
    };

_$GetETARequestModelImpl _$$GetETARequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$GetETARequestModelImpl(
      user_location:
          LocationModel.fromJson(json['user_location'] as Map<String, dynamic>),
      radius_km: (json['radius_km'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$GetETARequestModelImplToJson(
        _$GetETARequestModelImpl instance) =>
    <String, dynamic>{
      'user_location': instance.user_location,
      'radius_km': instance.radius_km,
    };

_$GetPricesRequestModelImpl _$$GetPricesRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$GetPricesRequestModelImpl(
      user_location:
          LocationModel.fromJson(json['user_location'] as Map<String, dynamic>),
      dest_location:
          LocationModel.fromJson(json['dest_location'] as Map<String, dynamic>),
      intermediate_location: json['intermediate_location'] == null
          ? null
          : LocationModel.fromJson(
              json['intermediate_location'] as Map<String, dynamic>),
      movers: (json['movers'] as num).toInt(),
    );

Map<String, dynamic> _$$GetPricesRequestModelImplToJson(
        _$GetPricesRequestModelImpl instance) =>
    <String, dynamic>{
      'user_location': instance.user_location,
      'dest_location': instance.dest_location,
      'intermediate_location': instance.intermediate_location,
      'movers': instance.movers,
    };

const _$TariffEnumMap = {
  Tariff.largus: 'largus',
  Tariff.fiat: 'fiat',
  Tariff.largustermo: 'largustermo',
};
