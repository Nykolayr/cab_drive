part of 'bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.pop(BuildContext context) = _Pop;

  const factory AuthEvent.sendCode() = _SendCode;
  const factory AuthEvent.resendCode() = _ResendCode;

  const factory AuthEvent.confirmCode({Function(AuthUser)? onSuccess}) = _ConfirmCode;
  const factory AuthEvent.sendFcmToken() = _SendFcmToken;

  const factory AuthEvent.sendResetCode(String number) = _SendResetCode;
}