import '../entities/auth_response/auth_response.dart';

abstract class AuthRepository {

  Future<String> sendCode(String number);

  Future<AuthResponse> confirmCode(String code, String session);

  Future<String> sendResetCode(String number);

  Future<String> confirmResetCode(String code, String session);

  Future<void> setFcmToken(String uid, String fcmToken);

}