import 'package:bloc/bloc.dart';
import 'package:cab_drive/login/login/domain/entities/user/auth_user.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/shared_prefs.dart';
import '../../../../core/utils/status.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

part 'bloc.freezed.dart';
part 'event.dart';
part 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc._(this._number, this._code)
      : super(_Auth(
          phone: _number,
          status: SuccessStatus(),
        )) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        sendCode: (e) => _sendCode(e, emit),
        resendCode: (e) => _resendCode(e, emit),
        confirmCode: (e) => _confirmCode(e, emit),
        pop: (e) => _pop(e, emit),
        sendResetCode: (e) => _sendResetCode(e, emit),
        sendFcmToken: (e) => _sendToken(e, emit),
      );
    });
  }

  factory AuthBloc() => AuthBloc._(
        TextEditingController(),
        TextEditingController(),
      );

  final AuthRepository _repository = AuthRepositoryImpl();
  final TextEditingController _number;
  final TextEditingController _code;
  late String _session;
  AuthUser? _user;

  Future<void> _sendToken(_SendFcmToken value, Emitter<AuthState> emit) async {
    final user = _user;
    if (user == null) return;
    await _sendFcmToken(user.firebaseId);
  }

  Future<void> _sendCode(_SendCode value, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: LoadingStatus()));
      final response = await _repository.sendCode(_number.text);
      _session = response;
      emit(_Code(controller: _code, status: SuccessStatus()));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      final text = (message != null && message.isNotEmpty)
          ? message
          : 'Ошибка авторизации (${e.response?.statusCode ?? 'сеть'}). Проверьте номер или попробуйте позже';
      emit(state.copyWith(status: FailedStatus(exception: text)));
    } catch (_) {
      emit(state.copyWith(
        status: FailedStatus(
          exception:
              'Ошибка авторизации, проверьте соединение с интернетом или попробуйте позднее',
        ),
      ));
    }
  }

  Future<void> _resendCode(_ResendCode v, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: LoadingStatus()));
      _session = await _repository.sendCode(_number.text);
      emit(state.copyWith(status: SuccessStatus()));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      emit(state.copyWith(
        status: FailedStatus(
          exception: message ?? e.toString(),
        ),
      ));
    }
  }

  Future<void> _confirmCode(_ConfirmCode v, Emitter<AuthState> emit) async {
    try {
      emit(state.copyWith(status: LoadingStatus()));
      final response = await _repository.confirmCode(_code.text, _session);
      SharedPrefs.setToken = response.token;
      _user ??= response.user;
      emit(state.copyWith(status: SuccessStatus()));
      v.onSuccess?.call(response.user);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      emit(state.copyWith(
        status: FailedStatus(exception: message ?? e.toString()),
      ));
    } catch (e) {
      emit(state.copyWith(status: FailedStatus(exception: e.toString())));
    }
  }

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
    } catch (_) {
      // FCM не блокирует авторизацию
    }
  }

  Future<void> _pop(_Pop v, Emitter<AuthState> emit) async {
    emit(_Auth(phone: _number, status: SuccessStatus()));
  }

  Future<void> _sendResetCode(
    _SendResetCode v,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: LoadingStatus()));
      _session = await _repository.sendResetCode(_number.text);
      _code.text = '';
      emit(_Code(controller: _code, status: SuccessStatus()));
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      emit(state.copyWith(
        status: FailedStatus(exception: message ?? e.toString()),
      ));
    }
  }
}
