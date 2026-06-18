import 'package:freezed_annotation/freezed_annotation.dart';

import '../user/auth_user.dart';


part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse(
      {
        required AuthUser user,
        @JsonKey(name: 'access_token') required String token,
      }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
