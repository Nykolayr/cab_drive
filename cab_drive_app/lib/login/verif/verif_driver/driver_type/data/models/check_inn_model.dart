import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_inn_model.freezed.dart';
part 'check_inn_model.g.dart';

@freezed
class CheckInnDataModel with _$CheckInnDataModel {
  const factory CheckInnDataModel({
    required bool status,
    String? message,
  }) = _CheckInnDataModel;

  factory CheckInnDataModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInnDataModelFromJson(json);
}

@freezed
class CheckInnResponseModel with _$CheckInnResponseModel {
  const factory CheckInnResponseModel({
    String? status,
    String? message,
    @JsonKey(name: 'status_code') int? statusCode,
    required bool success,
    required CheckInnDataModel data,
  }) = _CheckInnResponseModel;

  factory CheckInnResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInnResponseModelFromJson(json);
}