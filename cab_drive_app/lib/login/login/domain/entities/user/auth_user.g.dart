// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthUserImpl _$$AuthUserImplFromJson(Map<String, dynamic> json) =>
    _$AuthUserImpl(
      phone: json['phone'] as String,
      password: json['password'] as String,
      email: json['email'] as String,
      id: (json['id'] as num).toInt(),
      firebaseId: json['firebase_id'] as String,
    );

Map<String, dynamic> _$$AuthUserImplToJson(_$AuthUserImpl instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'password': instance.password,
      'email': instance.email,
      'id': instance.id,
      'firebase_id': instance.firebaseId,
    };
