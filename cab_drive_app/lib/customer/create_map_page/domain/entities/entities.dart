// lib/features/orders/domain/entities/entities.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'entities.freezed.dart';

@freezed
class LocationEntity with _$LocationEntity {
  const factory LocationEntity({
    required double lat,
    required double lng,
  }) = _LocationEntity;
}

@freezed
class DriverEntity with _$DriverEntity {
  const factory DriverEntity({
    required String uid,
    String? displayName,
    String? phoneNumber,
    String? mark,
    double? commissionPercent,
    required bool isBlocked,
    required bool onShift,
    required double lat,
    required double lng,
    required double distanceKm,
  }) = _DriverEntity;
}

@freezed
class ETAItemEntity with _$ETAItemEntity {
  const factory ETAItemEntity({
    required int etaSeconds,
    required String etaText,
  }) = _ETAItemEntity;
}

@freezed
class PriceBreakdownEntity with _$PriceBreakdownEntity {
  const factory PriceBreakdownEntity({
    required double priceBase,
    required double priceAfterTariff,
  }) = _PriceBreakdownEntity;
}

@freezed
class PriceItemEntity with _$PriceItemEntity {
  const factory PriceItemEntity({
    required double price,
    required double distanceKm,
    required int durationSec,
    required double tariffMultiplier,
    required double congestionMultiplier,
    required int availableDriversInRadius,
    required PriceBreakdownEntity breakdown,
    LocationEntity? intermediatePoint,
  }) = _PriceItemEntity;
}