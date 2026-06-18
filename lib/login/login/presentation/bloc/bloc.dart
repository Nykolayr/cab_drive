import 'package:bloc/bloc.dart';
import 'package:cab_drive/login/login/domain/entities/user/auth_user.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/utils/shared_prefs.dart';
import '../../../../core/utils/status.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

part 'bloc.freezed.dart';
part 'event.dart';
part 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc()
      : super(_Auth(
            phone: TextEditingController(),
            status: SuccessStatus())) {
    emit(_Auth(phone: _number, status: SuccessStatus()));
    on<AuthEvent>((events, emit) async {
      events.map(
        sendCode: _sendCode,
        resendCode: _resendCode,
        confirmCode: _confirmCode,
        pop: _pop,
        sendResetCode: _sendResetCode, sendFcmToken: _sendToken,

      );
    });
  }

  bool _isAuth = true;

  final AuthRepository _repository = AuthRepositoryImpl();

  final TextEditingController _number = TextEditingController();

  final TextEditingController _code = TextEditingController();
  late String _session;

  _sendToken (_SendFcmToken value) async {
    await _sendFcmToken(_user!.firebaseId);
  }

  _sendCode(_SendCode value) async {
    try {

        emit((state).copyWith(status: LoadingStatus()));
        print(_number.text);
        final response = await _repository.sendCode(
          _number.text,
        );

        _session = response;


      emit(_Code(controller: _code, status: SuccessStatus()));
    } on DioException catch (_) {
      print(_);
      try {
        emit(state.copyWith(
            status: FailedStatus(
                exception: _.response?.data['message'] ??
                    'Ошибка авторизации, проверьте соединение с интернетом или попробуйте позднее')));
      } catch (_) {
        emit(state.copyWith(
            status: FailedStatus(
                exception:
                    'Ошибка авторизации, проверьте соединение с интернетом или попробуйте позднее')));
      }
    } catch (_) {
      emit(state.copyWith(
          status: FailedStatus(
              exception:
                  'Ошибка авторизации, проверьте соединение с интернетом или попробуйте позднее')));
    }
  }

  _resendCode(_ResendCode v) async {
    try {
      emit((state as _Code).copyWith(status: LoadingStatus()));

      _session = await _repository.sendCode(_number.text);
      emit((state as _Code).copyWith(status: SuccessStatus()));
    } on DioException catch (_) {
      emit((state as _Code)
          .copyWith(status: FailedStatus(exception: _.toString())));
    }
  }

  _confirmCode(_ConfirmCode v) async {
    try {
      emit((state).copyWith(status: LoadingStatus()));
      final response = await _repository.confirmCode(
          _code.text, _session);

      SharedPrefs.setToken = response.token;

      // Отправка FCM token после успешной авторизации
      _user ??= response.user;
      emit((state).copyWith(status: SuccessStatus()));
      v.onSuccess?.call(response.user);
    } on DioException catch (_) {
      print(_.response?.data);
      emit((state).copyWith(
          status: FailedStatus(
              exception: _.response?.data['message'] ?? _.toString())));
    } catch (_) {
      emit((state).copyWith(status: FailedStatus(exception: _.toString())));
      rethrow;
    }
  }

  AuthUser? _user;

  Future<void> _sendFcmToken(String firebaseId) async {
    try {
      await Future.delayed(const Duration(seconds: 10));
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await _repository.setFcmToken(firebaseId, fcmToken);
        }
      }
    } catch (e) {
      // Игнорируем ошибки FCM, чтобы не блокировать авторизацию
      print('FCM token error: $e');
    }
  }

_pop(_Pop v) async {
  emit(_Auth(phone: _number, status: SuccessStatus()));

}


  _sendResetCode(_SendResetCode v) async {
    try {
      emit(state.copyWith(status: LoadingStatus()));
      _session = await _repository.sendResetCode(_number.text);
      _code.text = '';
      emit(_Code(controller: _code, status: SuccessStatus()));
    } on DioException catch (_) {

      emit(state.copyWith(status: FailedStatus(exception: _.response?.data['message'])));
    }
  }

}
