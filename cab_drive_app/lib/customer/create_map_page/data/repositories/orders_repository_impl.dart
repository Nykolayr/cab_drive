// lib/features/orders/data/repositories/orders_repository_impl.dart
import '../../domain/entities/entities.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';
import '../models/order_models.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, ETAItemEntity?>> getEtas(LocationEntity userLocation,
      {double? radiusKm}) async {
    final req = GetETARequestModel(
      user_location:
          LocationModel(lat: userLocation.lat, lng: userLocation.lng),
      radius_km: radiusKm,
    );

    final resp = await remoteDataSource.getPickupCalculate(req);

    final result = <String, ETAItemEntity?>{};
    resp.etas.forEach((key, value) {
      if (value == null) {
        result[key] = null;
      } else {
        result[key] = ETAItemEntity(
          etaSeconds: value.eta_seconds,
          etaText: value.eta_text,

        );
      }
    });

    return result;
  }

  @override
  Future<Map<String, PriceItemEntity?>> getPrices(
    LocationEntity userLocation,
    LocationEntity destLocation,
    int movers, {
    LocationEntity? intermediate,
    double? radiusKm,
    double? basePerKm,
    double? basePerMin,
    double? baseFee,
  }) async {
    final req = GetPricesRequestModel(
      user_location:
          LocationModel(lat: userLocation.lat, lng: userLocation.lng),
      dest_location:
          LocationModel(lat: destLocation.lat, lng: destLocation.lng),
      intermediate_location: intermediate != null
          ? LocationModel(lat: intermediate.lat, lng: intermediate.lng)
          : null, movers: movers,
    );

    final resp = await remoteDataSource.getRouteCalculate(req);

    final result = <String, PriceItemEntity?>{};
    resp.prices.forEach((key, value) {
      if (value == null) {
        result[key] = null;
      } else {
        result[key] = PriceItemEntity(
          price: value.price,
          distanceKm: value.distance_km,
          durationSec: value.duration_sec,
          tariffMultiplier: value.tariff_multiplier,
          congestionMultiplier: value.congestion_multiplier,
          availableDriversInRadius: value.available_drivers_in_radius,
          breakdown: PriceBreakdownEntity(
            priceBase: value.breakdown.price_base,
            priceAfterTariff: value.breakdown.price_after_tariff,
          ),
          intermediatePoint: value.intermediate_point != null
              ? LocationEntity(
                  lat: value.intermediate_point!.lat,
                  lng: value.intermediate_point!.lng)
              : null,
        );
      }
    });

    return result;
  }
}
