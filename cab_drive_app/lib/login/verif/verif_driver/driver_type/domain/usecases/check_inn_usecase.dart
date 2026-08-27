import '../entities/check_inn_entity.dart';
import '../repositories/check_inn_repository.dart';

class CheckInnUseCase {
  final CheckInnRepository repository;

  CheckInnUseCase(this.repository);

  Future<CheckInnEntity> call(String inn) {
    return repository.checkInn(inn);
  }
}