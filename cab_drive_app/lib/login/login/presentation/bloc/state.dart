part of 'bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.auth({
    required TextEditingController phone,
    required StatusEnum status,
  }) = _Auth;

  const factory AuthState.code({
    required TextEditingController controller,
    required StatusEnum status,
  }) = _Code;

}