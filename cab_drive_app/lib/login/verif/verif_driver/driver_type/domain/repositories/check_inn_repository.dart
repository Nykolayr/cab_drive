import '../entities/check_inn_entity.dart';

abstract class CheckInnRepository {
  Future<CheckInnEntity> checkInn(String inn);
}