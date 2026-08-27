// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_inn_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInnDataModelImpl _$$CheckInnDataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CheckInnDataModelImpl(
      status: json['status'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$CheckInnDataModelImplToJson(
        _$CheckInnDataModelImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
    };

_$CheckInnResponseModelImpl _$$CheckInnResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CheckInnResponseModelImpl(
      status: json['status'] as String?,
      message: json['message'] as String?,
      statusCode: (json['status_code'] as num?)?.toInt(),
      success: json['success'] as bool,
      data: CheckInnDataModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CheckInnResponseModelImplToJson(
        _$CheckInnResponseModelImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'status_code': instance.statusCode,
      'success': instance.success,
      'data': instance.data,
    };
