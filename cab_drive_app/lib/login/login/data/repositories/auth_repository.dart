
import '../../domain/entities/auth_response/auth_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_source/auth_remote_data_source.dart';

class AuthRepositoryImpl extends AuthRepository {

  final AuthRemoteDataSource _remoteDataSource = AuthRemoteDataSourceImpl();

  Future<AuthResponse> signIn (String number, String password) {
    return _remoteDataSource.signIn(number, password);
  }

  Future<String> sendCode (String number) {
    return _remoteDataSource.sendCode(number);
  }

  Future<AuthResponse> confirmCode (String code,  String session) {
    return _remoteDataSource.confirmCode(code, session);
  }

  @override
  Future<String> confirmResetCode(String code, String session) {
    return _remoteDataSource.confirmResetCode(code, session);
  }


  @override
  Future<String> sendResetCode(String number) {
    return _remoteDataSource.sendResetCode(number);
  }

  @override
  Future<void> setFcmToken(String uid, String fcmToken) {
    return _remoteDataSource.setFcmToken(uid, fcmToken);
  }
}
