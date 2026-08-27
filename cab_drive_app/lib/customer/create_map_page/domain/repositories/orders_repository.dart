// lib/features/orders/domain/repositories/orders_repository.dart
import '../entities/entities.dart';

abstract class OrdersRepository {
  Future<Map<String, ETAItemEntity?>> getEtas(LocationEntity userLocation,
      {double? radiusKm});

  Future<Map<String, PriceItemEntity?>> getPrices(
    LocationEntity userLocation,
    LocationEntity destLocation,
    int movers, {
    LocationEntity? intermediate,
    double? radiusKm,
    double? basePerKm,
    double? basePerMin,
    double? baseFee,
  });
}
