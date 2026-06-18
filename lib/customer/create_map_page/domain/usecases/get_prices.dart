// lib/features/orders/domain/usecases/get_prices.dart
import '../entities/entities.dart';
import '../repositories/orders_repository.dart';

class GetPricesUseCase {
  final OrdersRepository repository;

  GetPricesUseCase(this.repository);

  Future<Map<String, PriceItemEntity?>> call(
    LocationEntity userLocation,
    LocationEntity destLocation,
      int movers,
      {
    LocationEntity? intermediate,
    double? radiusKm,
    double? basePerKm,
    double? basePerMin,
    double? baseFee,
  }) {
    return repository.getPrices(
      userLocation,
      destLocation,
      movers,
      intermediate: intermediate,
      radiusKm: radiusKm,
      basePerKm: basePerKm,
      basePerMin: basePerMin,
      baseFee: baseFee,
    );
  }
}