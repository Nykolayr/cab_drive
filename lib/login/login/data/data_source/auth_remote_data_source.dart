import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/app_dio.dart';
import '../../domain/entities/auth_response/auth_response.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> signIn(String number, String password);

  Future<String> sendCode(String number);

  Future<AuthResponse> confirmCode(
      String code, String session);

  Future<String> sendResetCode(String number);
  Future<String> confirmResetCode(String code, String session);
  Future<AuthResponse> confirmResetPassword(String password, String session);
  Future<void> setFcmToken(String uid, String fcmToken);
}

class AuthRemoteDataSourceImpl extends AuthRemoteDataSource {
  final _dio = AppDio()();

  @override
  Future<String> sendCode(String number) async {
    final response = await _dio.post('users/auth',
        data: FormData.fromMap({
          'phone': number,
        }));

    print(' reg ${response.data}');
    return response.data['call_token'];
  }

  @override
  Future<AuthResponse> confirmCode(String code, String session) async {
    final response = await _dio.post('users/auth_by_code',
        data: FormData.fromMap({
          'code': int.parse(code),
          'call_token': session,
        }));
    print(response.data);
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> signIn(String number, String password) async {
    final response = await _dio.post('users/auth',
        data: FormData.fromMap({
          'phone': '+7 ' +number,
          'password': password,
        }));
    print(response.data);
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<String> sendResetCode(String number) async {
    final response = await _dio.post('users/send_reset_sms_code',
        data: FormData.fromMap({
          'phone': '+7 ' + number,
        }));

    return response.data['call_token'];
  }

  @override
  Future<String> confirmResetCode(String code, String session) async {
    final response = await _dio.post('users/verify_reset_password',
        data: FormData.fromMap({
          'code': int.parse(code),
          'call_token': session,
        }));
    print(response.data);
    return response.data['reset_token'];
  }



  @override
  Future<AuthResponse> confirmResetPassword(String password, String session) async {
    final response = await _dio.post('users/reset_password',
        data: FormData.fromMap({
          'password': password,
          'reset_token': session,
        }));
    print(response.data);
    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<void> setFcmToken(String uid, String fcmToken) async {
    await AppDio()().post('users/fcm',
        data: FormData.fromMap({
          'uid': uid,
          'fcm_token': fcmToken,
          'user_id': FirebaseAuth.instance.currentUser!.uid
        }));
  }
}
