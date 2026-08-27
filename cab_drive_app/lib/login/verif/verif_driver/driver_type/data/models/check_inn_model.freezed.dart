// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_inn_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CheckInnDataModel _$CheckInnDataModelFromJson(Map<String, dynamic> json) {
  return _CheckInnDataModel.fromJson(json);
}

/// @nodoc
mixin _$CheckInnDataModel {
  bool get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this CheckInnDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInnDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInnDataModelCopyWith<CheckInnDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInnDataModelCopyWith<$Res> {
  factory $CheckInnDataModelCopyWith(
          CheckInnDataModel value, $Res Function(CheckInnDataModel) then) =
      _$CheckInnDataModelCopyWithImpl<$Res, CheckInnDataModel>;
  @useResult
  $Res call({bool status, String? message});
}

/// @nodoc
class _$CheckInnDataModelCopyWithImpl<$Res, $Val extends CheckInnDataModel>
    implements $CheckInnDataModelCopyWith<$Res> {
  _$CheckInnDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInnDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CheckInnDataModelImplCopyWith<$Res>
    implements $CheckInnDataModelCopyWith<$Res> {
  factory _$$CheckInnDataModelImplCopyWith(_$CheckInnDataModelImpl value,
          $Res Function(_$CheckInnDataModelImpl) then) =
      __$$CheckInnDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool status, String? message});
}

/// @nodoc
class __$$CheckInnDataModelImplCopyWithImpl<$Res>
    extends _$CheckInnDataModelCopyWithImpl<$Res, _$CheckInnDataModelImpl>
    implements _$$CheckInnDataModelImplCopyWith<$Res> {
  __$$CheckInnDataModelImplCopyWithImpl(_$CheckInnDataModelImpl _value,
      $Res Function(_$CheckInnDataModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInnDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = freezed,
  }) {
    return _then(_$CheckInnDataModelImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckInnDataModelImpl implements _CheckInnDataModel {
  const _$CheckInnDataModelImpl({required this.status, this.message});

  factory _$CheckInnDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInnDataModelImplFromJson(json);

  @override
  final bool status;
  @override
  final String? message;

  @override
  String toString() {
    return 'CheckInnDataModel(status: $status, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInnDataModelImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, message);

  /// Create a copy of CheckInnDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInnDataModelImplCopyWith<_$CheckInnDataModelImpl> get copyWith =>
      __$$CheckInnDataModelImplCopyWithImpl<_$CheckInnDataModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInnDataModelImplToJson(
      this,
    );
  }
}

abstract class _CheckInnDataModel implements CheckInnDataModel {
  const factory _CheckInnDataModel(
      {required final bool status,
      final String? message}) = _$CheckInnDataModelImpl;

  factory _CheckInnDataModel.fromJson(Map<String, dynamic> json) =
      _$CheckInnDataModelImpl.fromJson;

  @override
  bool get status;
  @override
  String? get message;

  /// Create a copy of CheckInnDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInnDataModelImplCopyWith<_$CheckInnDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CheckInnResponseModel _$CheckInnResponseModelFromJson(
    Map<String, dynamic> json) {
  return _CheckInnResponseModel.fromJson(json);
}

/// @nodoc
mixin _$CheckInnResponseModel {
  String? get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'status_code')
  int? get statusCode => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  CheckInnDataModel get data => throw _privateConstructorUsedError;

  /// Serializes this CheckInnResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CheckInnResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckInnResponseModelCopyWith<CheckInnResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckInnResponseModelCopyWith<$Res> {
  factory $CheckInnResponseModelCopyWith(CheckInnResponseModel value,
          $Res Function(CheckInnResponseModel) then) =
      _$CheckInnResponseModelCopyWithImpl<$Res, CheckInnResponseModel>;
  @useResult
  $Res call(
      {String? status,
      String? message,
      @JsonKey(name: 'status_code') int? statusCode,
      bool success,
      CheckInnDataModel data});

  $CheckInnDataModelCopyWith<$Res> get data;
}

/// @nodoc
class _$CheckInnResponseModelCopyWithImpl<$Res,
        $Val extends CheckInnResponseModel>
    implements $CheckInnResponseModelCopyWith<$Res> {
  _$CheckInnResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckInnResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? message = freezed,
    Object? statusCode = freezed,
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as CheckInnDataModel,
    ) as $Val);
  }

  /// Create a copy of CheckInnResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CheckInnDataModelCopyWith<$Res> get data {
    return $CheckInnDataModelCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CheckInnResponseModelImplCopyWith<$Res>
    implements $CheckInnResponseModelCopyWith<$Res> {
  factory _$$CheckInnResponseModelImplCopyWith(
          _$CheckInnResponseModelImpl value,
          $Res Function(_$CheckInnResponseModelImpl) then) =
      __$$CheckInnResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? status,
      String? message,
      @JsonKey(name: 'status_code') int? statusCode,
      bool success,
      CheckInnDataModel data});

  @override
  $CheckInnDataModelCopyWith<$Res> get data;
}

/// @nodoc
class __$$CheckInnResponseModelImplCopyWithImpl<$Res>
    extends _$CheckInnResponseModelCopyWithImpl<$Res,
        _$CheckInnResponseModelImpl>
    implements _$$CheckInnResponseModelImplCopyWith<$Res> {
  __$$CheckInnResponseModelImplCopyWithImpl(_$CheckInnResponseModelImpl _value,
      $Res Function(_$CheckInnResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CheckInnResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? message = freezed,
    Object? statusCode = freezed,
    Object? success = null,
    Object? data = null,
  }) {
    return _then(_$CheckInnResponseModelImpl(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as CheckInnDataModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckInnResponseModelImpl implements _CheckInnResponseModel {
  const _$CheckInnResponseModelImpl(
      {this.status,
      this.message,
      @JsonKey(name: 'status_code') this.statusCode,
      required this.success,
      required this.data});

  factory _$CheckInnResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckInnResponseModelImplFromJson(json);

  @override
  final String? status;
  @override
  final String? message;
  @override
  @JsonKey(name: 'status_code')
  final int? statusCode;
  @override
  final bool success;
  @override
  final CheckInnDataModel data;

  @override
  String toString() {
    return 'CheckInnResponseModel(status: $status, message: $message, statusCode: $statusCode, success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckInnResponseModelImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, status, message, statusCode, success, data);

  /// Create a copy of CheckInnResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckInnResponseModelImplCopyWith<_$CheckInnResponseModelImpl>
      get copyWith => __$$CheckInnResponseModelImplCopyWithImpl<
          _$CheckInnResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckInnResponseModelImplToJson(
      this,
    );
  }
}

abstract class _CheckInnResponseModel implements CheckInnResponseModel {
  const factory _CheckInnResponseModel(
      {final String? status,
      final String? message,
      @JsonKey(name: 'status_code') final int? statusCode,
      required final bool success,
      required final CheckInnDataModel data}) = _$CheckInnResponseModelImpl;

  factory _CheckInnResponseModel.fromJson(Map<String, dynamic> json) =
      _$CheckInnResponseModelImpl.fromJson;

  @override
  String? get status;
  @override
  String? get message;
  @override
  @JsonKey(name: 'status_code')
  int? get statusCode;
  @override
  bool get success;
  @override
  CheckInnDataModel get data;

  /// Create a copy of CheckInnResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckInnResponseModelImplCopyWith<_$CheckInnResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
