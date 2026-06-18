// lib/features/orders/data/models/order_models.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_models.freezed.dart';
part 'order_models.g.dart';

@JsonEnum(alwaysCreate: true)
enum Tariff {
  @JsonValue('largus')
  largus,
  @JsonValue('fiat')
  fiat,
  @JsonValue('largustermo')
  largustermo,
}

@freezed
class LocationModel with _$LocationModel {
  const factory LocationModel({
    required double lat,
    required double lng,
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
}

@freezed
class DriverModel with _$DriverModel {
  const factory DriverModel({
    required String uid,
    String? display_name,
    String? phone_number,
    String? mark,
    double? commission_percent,
    bool? is_blocked,
    bool? on_shift,
    required double lat,
    required double lng,
    required double distance_km,
  }) = _DriverModel;

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);
}

@freezed
class ETAItemModel with _$ETAItemModel {
  const factory ETAItemModel({
    required int eta_seconds,
    required String eta_text,
  }) = _ETAItemModel;

  factory ETAItemModel.fromJson(Map<String, dynamic> json) =>
      _$ETAItemModelFromJson(json);
}

@freezed
class ETAResponseModel with _$ETAResponseModel {
  const factory ETAResponseModel({
    required Map<String, ETAItemModel?> etas,
  }) = _ETAResponseModel;

  factory ETAResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ETAResponseModelFromJson(json);
}

@freezed
class PriceBreakdownModel with _$PriceBreakdownModel {
  const factory PriceBreakdownModel({
    required double price_base,
    required double price_after_tariff,
  }) = _PriceBreakdownModel;

  factory PriceBreakdownModel.fromJson(Map<String, dynamic> json) =>
      _$PriceBreakdownModelFromJson(json);
}

@freezed
class PriceItemModel with _$PriceItemModel {
  const factory PriceItemModel({
    required double price,
    required double distance_km,
    required int duration_sec,
    required double tariff_multiplier,
    required double congestion_multiplier,
    required int available_drivers_in_radius,
    required PriceBreakdownModel breakdown,
    LocationModel? intermediate_point,
  }) = _PriceItemModel;

  factory PriceItemModel.fromJson(Map<String, dynamic> json) =>
      _$PriceItemModelFromJson(json);
}

@freezed
class PricesResponseModel with _$PricesResponseModel {
  const factory PricesResponseModel({
    required Map<String, PriceItemModel?> prices,
  }) = _PricesResponseModel;

  factory PricesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PricesResponseModelFromJson(json);
}

@freezed
class GetETARequestModel with _$GetETARequestModel {
  const factory GetETARequestModel({
    required LocationModel user_location,
    double? radius_km,
  }) = _GetETARequestModel;

  factory GetETARequestModel.fromJson(Map<String, dynamic> json) =>
      _$GetETARequestModelFromJson(json);
}

@freezed
class GetPricesRequestModel with _$GetPricesRequestModel {
  const factory GetPricesRequestModel({
    required LocationModel user_location,
    required LocationModel dest_location,
    LocationModel? intermediate_location,
    required int movers,

  }) = _GetPricesRequestModel;

  factory GetPricesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GetPricesRequestModelFromJson(json);
}