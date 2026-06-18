import '../../domain/entities/check_inn_entity.dart';
import '../../domain/repositories/check_inn_repository.dart';
import '../datasources/check_inn_remote_data_source.dart';
import '../models/check_inn_model.dart';

class CheckInnRepositoryImpl implements CheckInnRepository {
  final CheckInnRemoteDataSource remoteDataSource;

  CheckInnRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CheckInnEntity> checkInn(String inn) async {
    final CheckInnResponseModel resp = await remoteDataSource.checkInn(inn);

    return CheckInnEntity(
      success: resp.success,
      status: resp.data.status,
      message: resp.data.message ?? resp.message ?? '',
      statusCode: resp.statusCode ?? 0,
    );
  }
}