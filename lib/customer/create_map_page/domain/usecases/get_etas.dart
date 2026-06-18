// lib/features/orders/domain/usecases/get_etas.dart
import '../entities/entities.dart';
import '../repositories/orders_repository.dart';

class GetEtasUseCase {
  final OrdersRepository repository;

  GetEtasUseCase(this.repository);

  Future<Map<String, ETAItemEntity?>> call(LocationEntity userLocation, {double? radiusKm}) {
    return repository.getEtas(userLocation, radiusKm: radiusKm);
  }
}