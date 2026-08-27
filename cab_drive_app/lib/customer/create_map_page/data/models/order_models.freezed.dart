// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) {
  return _LocationModel.fromJson(json);
}

/// @nodoc
mixin _$LocationModel {
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;

  /// Serializes this LocationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationModelCopyWith<LocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationModelCopyWith<$Res> {
  factory $LocationModelCopyWith(
          LocationModel value, $Res Function(LocationModel) then) =
      _$LocationModelCopyWithImpl<$Res, LocationModel>;
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class _$LocationModelCopyWithImpl<$Res, $Val extends LocationModel>
    implements $LocationModelCopyWith<$Res> {
  _$LocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
  }) {
    return _then(_value.copyWith(
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationModelImplCopyWith<$Res>
    implements $LocationModelCopyWith<$Res> {
  factory _$$LocationModelImplCopyWith(
          _$LocationModelImpl value, $Res Function(_$LocationModelImpl) then) =
      __$$LocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class __$$LocationModelImplCopyWithImpl<$Res>
    extends _$LocationModelCopyWithImpl<$Res, _$LocationModelImpl>
    implements _$$LocationModelImplCopyWith<$Res> {
  __$$LocationModelImplCopyWithImpl(
      _$LocationModelImpl _value, $Res Function(_$LocationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
  }) {
    return _then(_$LocationModelImpl(
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationModelImpl implements _LocationModel {
  const _$LocationModelImpl({required this.lat, required this.lng});

  factory _$LocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationModelImplFromJson(json);

  @override
  final double lat;
  @override
  final double lng;

  @override
  String toString() {
    return 'LocationModel(lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationModelImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng);

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      __$$LocationModelImplCopyWithImpl<_$LocationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationModelImplToJson(
      this,
    );
  }
}

abstract class _LocationModel implements LocationModel {
  const factory _LocationModel(
      {required final double lat,
      required final double lng}) = _$LocationModelImpl;

  factory _LocationModel.fromJson(Map<String, dynamic> json) =
      _$LocationModelImpl.fromJson;

  @override
  double get lat;
  @override
  double get lng;

  /// Create a copy of LocationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DriverModel _$DriverModelFromJson(Map<String, dynamic> json) {
  return _DriverModel.fromJson(json);
}

/// @nodoc
mixin _$DriverModel {
  String get uid => throw _privateConstructorUsedError;
  String? get display_name => throw _privateConstructorUsedError;
  String? get phone_number => throw _privateConstructorUsedError;
  String? get mark => throw _privateConstructorUsedError;
  double? get commission_percent => throw _privateConstructorUsedError;
  bool? get is_blocked => throw _privateConstructorUsedError;
  bool? get on_shift => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  double get distance_km => throw _privateConstructorUsedError;

  /// Serializes this DriverModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverModelCopyWith<DriverModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverModelCopyWith<$Res> {
  factory $DriverModelCopyWith(
          DriverModel value, $Res Function(DriverModel) then) =
      _$DriverModelCopyWithImpl<$Res, DriverModel>;
  @useResult
  $Res call(
      {String uid,
      String? display_name,
      String? phone_number,
      String? mark,
      double? commission_percent,
      bool? is_blocked,
      bool? on_shift,
      double lat,
      double lng,
      double distance_km});
}

/// @nodoc
class _$DriverModelCopyWithImpl<$Res, $Val extends DriverModel>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? display_name = freezed,
    Object? phone_number = freezed,
    Object? mark = freezed,
    Object? commission_percent = freezed,
    Object? is_blocked = freezed,
    Object? on_shift = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? distance_km = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      display_name: freezed == display_name
          ? _value.display_name
          : display_name // ignore: cast_nullable_to_non_nullable
              as String?,
      phone_number: freezed == phone_number
          ? _value.phone_number
          : phone_number // ignore: cast_nullable_to_non_nullable
              as String?,
      mark: freezed == mark
          ? _value.mark
          : mark // ignore: cast_nullable_to_non_nullable
              as String?,
      commission_percent: freezed == commission_percent
          ? _value.commission_percent
          : commission_percent // ignore: cast_nullable_to_non_nullable
              as double?,
      is_blocked: freezed == is_blocked
          ? _value.is_blocked
          : is_blocked // ignore: cast_nullable_to_non_nullable
              as bool?,
      on_shift: freezed == on_shift
          ? _value.on_shift
          : on_shift // ignore: cast_nullable_to_non_nullable
              as bool?,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      distance_km: null == distance_km
          ? _value.distance_km
          : distance_km // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverModelImplCopyWith<$Res>
    implements $DriverModelCopyWith<$Res> {
  factory _$$DriverModelImplCopyWith(
          _$DriverModelImpl value, $Res Function(_$DriverModelImpl) then) =
      __$$DriverModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String? display_name,
      String? phone_number,
      String? mark,
      double? commission_percent,
      bool? is_blocked,
      bool? on_shift,
      double lat,
      double lng,
      double distance_km});
}

/// @nodoc
class __$$DriverModelImplCopyWithImpl<$Res>
    extends _$DriverModelCopyWithImpl<$Res, _$DriverModelImpl>
    implements _$$DriverModelImplCopyWith<$Res> {
  __$$DriverModelImplCopyWithImpl(
      _$DriverModelImpl _value, $Res Function(_$DriverModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? display_name = freezed,
    Object? phone_number = freezed,
    Object? mark = freezed,
    Object? commission_percent = freezed,
    Object? is_blocked = freezed,
    Object? on_shift = freezed,
    Object? lat = null,
    Object? lng = null,
    Object? distance_km = null,
  }) {
    return _then(_$DriverModelImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      display_name: freezed == display_name
          ? _value.display_name
          : display_name // ignore: cast_nullable_to_non_nullable
              as String?,
      phone_number: freezed == phone_number
          ? _value.phone_number
          : phone_number // ignore: cast_nullable_to_non_nullable
              as String?,
      mark: freezed == mark
          ? _value.mark
          : mark // ignore: cast_nullable_to_non_nullable
              as String?,
      commission_percent: freezed == commission_percent
          ? _value.commission_percent
          : commission_percent // ignore: cast_nullable_to_non_nullable
              as double?,
      is_blocked: freezed == is_blocked
          ? _value.is_blocked
          : is_blocked // ignore: cast_nullable_to_non_nullable
              as bool?,
      on_shift: freezed == on_shift
          ? _value.on_shift
          : on_shift // ignore: cast_nullable_to_non_nullable
              as bool?,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      distance_km: null == distance_km
          ? _value.distance_km
          : distance_km // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DriverModelImpl implements _DriverModel {
  const _$DriverModelImpl(
      {required this.uid,
      this.display_name,
      this.phone_number,
      this.mark,
      this.commission_percent,
      this.is_blocked,
      this.on_shift,
      required this.lat,
      required this.lng,
      required this.distance_km});

  factory _$DriverModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DriverModelImplFromJson(json);

  @override
  final String uid;
  @override
  final String? display_name;
  @override
  final String? phone_number;
  @override
  final String? mark;
  @override
  final double? commission_percent;
  @override
  final bool? is_blocked;
  @override
  final bool? on_shift;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final double distance_km;

  @override
  String toString() {
    return 'DriverModel(uid: $uid, display_name: $display_name, phone_number: $phone_number, mark: $mark, commission_percent: $commission_percent, is_blocked: $is_blocked, on_shift: $on_shift, lat: $lat, lng: $lng, distance_km: $distance_km)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.display_name, display_name) ||
                other.display_name == display_name) &&
            (identical(other.phone_number, phone_number) ||
                other.phone_number == phone_number) &&
            (identical(other.mark, mark) || other.mark == mark) &&
            (identical(other.commission_percent, commission_percent) ||
                other.commission_percent == commission_percent) &&
            (identical(other.is_blocked, is_blocked) ||
                other.is_blocked == is_blocked) &&
            (identical(other.on_shift, on_shift) ||
                other.on_shift == on_shift) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.distance_km, distance_km) ||
                other.distance_km == distance_km));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, display_name, phone_number,
      mark, commission_percent, is_blocked, on_shift, lat, lng, distance_km);

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverModelImplCopyWith<_$DriverModelImpl> get copyWith =>
      __$$DriverModelImplCopyWithImpl<_$DriverModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DriverModelImplToJson(
      this,
    );
  }
}

abstract class _DriverModel implements DriverModel {
  const factory _DriverModel(
      {required final String uid,
      final String? display_name,
      final String? phone_number,
      final String? mark,
      final double? commission_percent,
      final bool? is_blocked,
      final bool? on_shift,
      required final double lat,
      required final double lng,
      required final double distance_km}) = _$DriverModelImpl;

  factory _DriverModel.fromJson(Map<String, dynamic> json) =
      _$DriverModelImpl.fromJson;

  @override
  String get uid;
  @override
  String? get display_name;
  @override
  String? get phone_number;
  @override
  String? get mark;
  @override
  double? get commission_percent;
  @override
  bool? get is_blocked;
  @override
  bool? get on_shift;
  @override
  double get lat;
  @override
  double get lng;
  @override
  double get distance_km;

  /// Create a copy of DriverModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverModelImplCopyWith<_$DriverModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ETAItemModel _$ETAItemModelFromJson(Map<String, dynamic> json) {
  return _ETAItemModel.fromJson(json);
}

/// @nodoc
mixin _$ETAItemModel {
  int get eta_seconds => throw _privateConstructorUsedError;
  String get eta_text => throw _privateConstructorUsedError;

  /// Serializes this ETAItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ETAItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ETAItemModelCopyWith<ETAItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ETAItemModelCopyWith<$Res> {
  factory $ETAItemModelCopyWith(
          ETAItemModel value, $Res Function(ETAItemModel) then) =
      _$ETAItemModelCopyWithImpl<$Res, ETAItemModel>;
  @useResult
  $Res call({int eta_seconds, String eta_text});
}

/// @nodoc
class _$ETAItemModelCopyWithImpl<$Res, $Val extends ETAItemModel>
    implements $ETAItemModelCopyWith<$Res> {
  _$ETAItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ETAItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eta_seconds = null,
    Object? eta_text = null,
  }) {
    return _then(_value.copyWith(
      eta_seconds: null == eta_seconds
          ? _value.eta_seconds
          : eta_seconds // ignore: cast_nullable_to_non_nullable
              as int,
      eta_text: null == eta_text
          ? _value.eta_text
          : eta_text // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ETAItemModelImplCopyWith<$Res>
    implements $ETAItemModelCopyWith<$Res> {
  factory _$$ETAItemModelImplCopyWith(
          _$ETAItemModelImpl value, $Res Function(_$ETAItemModelImpl) then) =
      __$$ETAItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int eta_seconds, String eta_text});
}

/// @nodoc
class __$$ETAItemModelImplCopyWithImpl<$Res>
    extends _$ETAItemModelCopyWithImpl<$Res, _$ETAItemModelImpl>
    implements _$$ETAItemModelImplCopyWith<$Res> {
  __$$ETAItemModelImplCopyWithImpl(
      _$ETAItemModelImpl _value, $Res Function(_$ETAItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ETAItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eta_seconds = null,
    Object? eta_text = null,
  }) {
    return _then(_$ETAItemModelImpl(
      eta_seconds: null == eta_seconds
          ? _value.eta_seconds
          : eta_seconds // ignore: cast_nullable_to_non_nullable
              as int,
      eta_text: null == eta_text
          ? _value.eta_text
          : eta_text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ETAItemModelImpl implements _ETAItemModel {
  const _$ETAItemModelImpl({required this.eta_seconds, required this.eta_text});

  factory _$ETAItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ETAItemModelImplFromJson(json);

  @override
  final int eta_seconds;
  @override
  final String eta_text;

  @override
  String toString() {
    return 'ETAItemModel(eta_seconds: $eta_seconds, eta_text: $eta_text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ETAItemModelImpl &&
            (identical(other.eta_seconds, eta_seconds) ||
                other.eta_seconds == eta_seconds) &&
            (identical(other.eta_text, eta_text) ||
                other.eta_text == eta_text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, eta_seconds, eta_text);

  /// Create a copy of ETAItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ETAItemModelImplCopyWith<_$ETAItemModelImpl> get copyWith =>
      __$$ETAItemModelImplCopyWithImpl<_$ETAItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ETAItemModelImplToJson(
      this,
    );
  }
}

abstract class _ETAItemModel implements ETAItemModel {
  const factory _ETAItemModel(
      {required final int eta_seconds,
      required final String eta_text}) = _$ETAItemModelImpl;

  factory _ETAItemModel.fromJson(Map<String, dynamic> json) =
      _$ETAItemModelImpl.fromJson;

  @override
  int get eta_seconds;
  @override
  String get eta_text;

  /// Create a copy of ETAItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ETAItemModelImplCopyWith<_$ETAItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ETAResponseModel _$ETAResponseModelFromJson(Map<String, dynamic> json) {
  return _ETAResponseModel.fromJson(json);
}

/// @nodoc
mixin _$ETAResponseModel {
  Map<String, ETAItemModel?> get etas => throw _privateConstructorUsedError;

  /// Serializes this ETAResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ETAResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ETAResponseModelCopyWith<ETAResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ETAResponseModelCopyWith<$Res> {
  factory $ETAResponseModelCopyWith(
          ETAResponseModel value, $Res Function(ETAResponseModel) then) =
      _$ETAResponseModelCopyWithImpl<$Res, ETAResponseModel>;
  @useResult
  $Res call({Map<String, ETAItemModel?> etas});
}

/// @nodoc
class _$ETAResponseModelCopyWithImpl<$Res, $Val extends ETAResponseModel>
    implements $ETAResponseModelCopyWith<$Res> {
  _$ETAResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ETAResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? etas = null,
  }) {
    return _then(_value.copyWith(
      etas: null == etas
          ? _value.etas
          : etas // ignore: cast_nullable_to_non_nullable
              as Map<String, ETAItemModel?>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ETAResponseModelImplCopyWith<$Res>
    implements $ETAResponseModelCopyWith<$Res> {
  factory _$$ETAResponseModelImplCopyWith(_$ETAResponseModelImpl value,
          $Res Function(_$ETAResponseModelImpl) then) =
      __$$ETAResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, ETAItemModel?> etas});
}

/// @nodoc
class __$$ETAResponseModelImplCopyWithImpl<$Res>
    extends _$ETAResponseModelCopyWithImpl<$Res, _$ETAResponseModelImpl>
    implements _$$ETAResponseModelImplCopyWith<$Res> {
  __$$ETAResponseModelImplCopyWithImpl(_$ETAResponseModelImpl _value,
      $Res Function(_$ETAResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ETAResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? etas = null,
  }) {
    return _then(_$ETAResponseModelImpl(
      etas: null == etas
          ? _value._etas
          : etas // ignore: cast_nullable_to_non_nullable
              as Map<String, ETAItemModel?>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ETAResponseModelImpl implements _ETAResponseModel {
  const _$ETAResponseModelImpl({required final Map<String, ETAItemModel?> etas})
      : _etas = etas;

  factory _$ETAResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ETAResponseModelImplFromJson(json);

  final Map<String, ETAItemModel?> _etas;
  @override
  Map<String, ETAItemModel?> get etas {
    if (_etas is EqualUnmodifiableMapView) return _etas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_etas);
  }

  @override
  String toString() {
    return 'ETAResponseModel(etas: $etas)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ETAResponseModelImpl &&
            const DeepCollectionEquality().equals(other._etas, _etas));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_etas));

  /// Create a copy of ETAResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ETAResponseModelImplCopyWith<_$ETAResponseModelImpl> get copyWith =>
      __$$ETAResponseModelImplCopyWithImpl<_$ETAResponseModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ETAResponseModelImplToJson(
      this,
    );
  }
}

abstract class _ETAResponseModel implements ETAResponseModel {
  const factory _ETAResponseModel(
          {required final Map<String, ETAItemModel?> etas}) =
      _$ETAResponseModelImpl;

  factory _ETAResponseModel.fromJson(Map<String, dynamic> json) =
      _$ETAResponseModelImpl.fromJson;

  @override
  Map<String, ETAItemModel?> get etas;

  /// Create a copy of ETAResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ETAResponseModelImplCopyWith<_$ETAResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceBreakdownModel _$PriceBreakdownModelFromJson(Map<String, dynamic> json) {
  return _PriceBreakdownModel.fromJson(json);
}

/// @nodoc
mixin _$PriceBreakdownModel {
  double get price_base => throw _privateConstructorUsedError;
  double get price_after_tariff => throw _privateConstructorUsedError;

  /// Serializes this PriceBreakdownModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceBreakdownModelCopyWith<PriceBreakdownModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceBreakdownModelCopyWith<$Res> {
  factory $PriceBreakdownModelCopyWith(
          PriceBreakdownModel value, $Res Function(PriceBreakdownModel) then) =
      _$PriceBreakdownModelCopyWithImpl<$Res, PriceBreakdownModel>;
  @useResult
  $Res call({double price_base, double price_after_tariff});
}

/// @nodoc
class _$PriceBreakdownModelCopyWithImpl<$Res, $Val extends PriceBreakdownModel>
    implements $PriceBreakdownModelCopyWith<$Res> {
  _$PriceBreakdownModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price_base = null,
    Object? price_after_tariff = null,
  }) {
    return _then(_value.copyWith(
      price_base: null == price_base
          ? _value.price_base
          : price_base // ignore: cast_nullable_to_non_nullable
              as double,
      price_after_tariff: null == price_after_tariff
          ? _value.price_after_tariff
          : price_after_tariff // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriceBreakdownModelImplCopyWith<$Res>
    implements $PriceBreakdownModelCopyWith<$Res> {
  factory _$$PriceBreakdownModelImplCopyWith(_$PriceBreakdownModelImpl value,
          $Res Function(_$PriceBreakdownModelImpl) then) =
      __$$PriceBreakdownModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double price_base, double price_after_tariff});
}

/// @nodoc
class __$$PriceBreakdownModelImplCopyWithImpl<$Res>
    extends _$PriceBreakdownModelCopyWithImpl<$Res, _$PriceBreakdownModelImpl>
    implements _$$PriceBreakdownModelImplCopyWith<$Res> {
  __$$PriceBreakdownModelImplCopyWithImpl(_$PriceBreakdownModelImpl _value,
      $Res Function(_$PriceBreakdownModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price_base = null,
    Object? price_after_tariff = null,
  }) {
    return _then(_$PriceBreakdownModelImpl(
      price_base: null == price_base
          ? _value.price_base
          : price_base // ignore: cast_nullable_to_non_nullable
              as double,
      price_after_tariff: null == price_after_tariff
          ? _value.price_after_tariff
          : price_after_tariff // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceBreakdownModelImpl implements _PriceBreakdownModel {
  const _$PriceBreakdownModelImpl(
      {required this.price_base, required this.price_after_tariff});

  factory _$PriceBreakdownModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceBreakdownModelImplFromJson(json);

  @override
  final double price_base;
  @override
  final double price_after_tariff;

  @override
  String toString() {
    return 'PriceBreakdownModel(price_base: $price_base, price_after_tariff: $price_after_tariff)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceBreakdownModelImpl &&
            (identical(other.price_base, price_base) ||
                other.price_base == price_base) &&
            (identical(other.price_after_tariff, price_after_tariff) ||
                other.price_after_tariff == price_after_tariff));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, price_base, price_after_tariff);

  /// Create a copy of PriceBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceBreakdownModelImplCopyWith<_$PriceBreakdownModelImpl> get copyWith =>
      __$$PriceBreakdownModelImplCopyWithImpl<_$PriceBreakdownModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceBreakdownModelImplToJson(
      this,
    );
  }
}

abstract class _PriceBreakdownModel implements PriceBreakdownModel {
  const factory _PriceBreakdownModel(
      {required final double price_base,
      required final double price_after_tariff}) = _$PriceBreakdownModelImpl;

  factory _PriceBreakdownModel.fromJson(Map<String, dynamic> json) =
      _$PriceBreakdownModelImpl.fromJson;

  @override
  double get price_base;
  @override
  double get price_after_tariff;

  /// Create a copy of PriceBreakdownModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceBreakdownModelImplCopyWith<_$PriceBreakdownModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PriceItemModel _$PriceItemModelFromJson(Map<String, dynamic> json) {
  return _PriceItemModel.fromJson(json);
}

/// @nodoc
mixin _$PriceItemModel {
  double get price => throw _privateConstructorUsedError;
  double get distance_km => throw _privateConstructorUsedError;
  int get duration_sec => throw _privateConstructorUsedError;
  double get tariff_multiplier => throw _privateConstructorUsedError;
  double get congestion_multiplier => throw _privateConstructorUsedError;
  int get available_drivers_in_radius => throw _privateConstructorUsedError;
  PriceBreakdownModel get breakdown => throw _privateConstructorUsedError;
  LocationModel? get intermediate_point => throw _privateConstructorUsedError;

  /// Serializes this PriceItemModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PriceItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceItemModelCopyWith<PriceItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceItemModelCopyWith<$Res> {
  factory $PriceItemModelCopyWith(
          PriceItemModel value, $Res Function(PriceItemModel) then) =
      _$PriceItemModelCopyWithImpl<$Res, PriceItemModel>;
  @useResult
  $Res call(
      {double price,
      double distance_km,
      int duration_sec,
      double tariff_multiplier,
      double congestion_multiplier,
      int available_drivers_in_radius,
      PriceBreakdownModel breakdown,
      LocationModel? intermediate_point});

  $PriceBreakdownModelCopyWith<$Res> get breakdown;
  $LocationModelCopyWith<$Res>? get intermediate_point;
}

/// @nodoc
class _$PriceItemModelCopyWithImpl<$Res, $Val extends PriceItemModel>
    implements $PriceItemModelCopyWith<$Res> {
  _$PriceItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? distance_km = null,
    Object? duration_sec = null,
    Object? tariff_multiplier = null,
    Object? congestion_multiplier = null,
    Object? available_drivers_in_radius = null,
    Object? breakdown = null,
    Object? intermediate_point = freezed,
  }) {
    return _then(_value.copyWith(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      distance_km: null == distance_km
          ? _value.distance_km
          : distance_km // ignore: cast_nullable_to_non_nullable
              as double,
      duration_sec: null == duration_sec
          ? _value.duration_sec
          : duration_sec // ignore: cast_nullable_to_non_nullable
              as int,
      tariff_multiplier: null == tariff_multiplier
          ? _value.tariff_multiplier
          : tariff_multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      congestion_multiplier: null == congestion_multiplier
          ? _value.congestion_multiplier
          : congestion_multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      available_drivers_in_radius: null == available_drivers_in_radius
          ? _value.available_drivers_in_radius
          : available_drivers_in_radius // ignore: cast_nullable_to_non_nullable
              as int,
      breakdown: null == breakdown
          ? _value.breakdown
          : breakdown // ignore: cast_nullable_to_non_nullable
              as PriceBreakdownModel,
      intermediate_point: freezed == intermediate_point
          ? _value.intermediate_point
          : intermediate_point // ignore: cast_nullable_to_non_nullable
              as LocationModel?,
    ) as $Val);
  }

  /// Create a copy of PriceItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceBreakdownModelCopyWith<$Res> get breakdown {
    return $PriceBreakdownModelCopyWith<$Res>(_value.breakdown, (value) {
      return _then(_value.copyWith(breakdown: value) as $Val);
    });
  }

  /// Create a copy of PriceItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res>? get intermediate_point {
    if (_value.intermediate_point == null) {
      return null;
    }

    return $LocationModelCopyWith<$Res>(_value.intermediate_point!, (value) {
      return _then(_value.copyWith(intermediate_point: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PriceItemModelImplCopyWith<$Res>
    implements $PriceItemModelCopyWith<$Res> {
  factory _$$PriceItemModelImplCopyWith(_$PriceItemModelImpl value,
          $Res Function(_$PriceItemModelImpl) then) =
      __$$PriceItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double price,
      double distance_km,
      int duration_sec,
      double tariff_multiplier,
      double congestion_multiplier,
      int available_drivers_in_radius,
      PriceBreakdownModel breakdown,
      LocationModel? intermediate_point});

  @override
  $PriceBreakdownModelCopyWith<$Res> get breakdown;
  @override
  $LocationModelCopyWith<$Res>? get intermediate_point;
}

/// @nodoc
class __$$PriceItemModelImplCopyWithImpl<$Res>
    extends _$PriceItemModelCopyWithImpl<$Res, _$PriceItemModelImpl>
    implements _$$PriceItemModelImplCopyWith<$Res> {
  __$$PriceItemModelImplCopyWithImpl(
      _$PriceItemModelImpl _value, $Res Function(_$PriceItemModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceItemModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? distance_km = null,
    Object? duration_sec = null,
    Object? tariff_multiplier = null,
    Object? congestion_multiplier = null,
    Object? available_drivers_in_radius = null,
    Object? breakdown = null,
    Object? intermediate_point = freezed,
  }) {
    return _then(_$PriceItemModelImpl(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      distance_km: null == distance_km
          ? _value.distance_km
          : distance_km // ignore: cast_nullable_to_non_nullable
              as double,
      duration_sec: null == duration_sec
          ? _value.duration_sec
          : duration_sec // ignore: cast_nullable_to_non_nullable
              as int,
      tariff_multiplier: null == tariff_multiplier
          ? _value.tariff_multiplier
          : tariff_multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      congestion_multiplier: null == congestion_multiplier
          ? _value.congestion_multiplier
          : congestion_multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      available_drivers_in_radius: null == available_drivers_in_radius
          ? _value.available_drivers_in_radius
          : available_drivers_in_radius // ignore: cast_nullable_to_non_nullable
              as int,
      breakdown: null == breakdown
          ? _value.breakdown
          : breakdown // ignore: cast_nullable_to_non_nullable
              as PriceBreakdownModel,
      intermediate_point: freezed == intermediate_point
          ? _value.intermediate_point
          : intermediate_point // ignore: cast_nullable_to_non_nullable
              as LocationModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PriceItemModelImpl implements _PriceItemModel {
  const _$PriceItemModelImpl(
      {required this.price,
      required this.distance_km,
      required this.duration_sec,
      required this.tariff_multiplier,
      required this.congestion_multiplier,
      required this.available_drivers_in_radius,
      required this.breakdown,
      this.intermediate_point});

  factory _$PriceItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PriceItemModelImplFromJson(json);

  @override
  final double price;
  @override
  final double distance_km;
  @override
  final int duration_sec;
  @override
  final double tariff_multiplier;
  @override
  final double congestion_multiplier;
  @override
  final int available_drivers_in_radius;
  @override
  final PriceBreakdownModel breakdown;
  @override
  final LocationModel? intermediate_point;

  @override
  String toString() {
    return 'PriceItemModel(price: $price, distance_km: $distance_km, duration_sec: $duration_sec, tariff_multiplier: $tariff_multiplier, congestion_multiplier: $congestion_multiplier, available_drivers_in_radius: $available_drivers_in_radius, breakdown: $breakdown, intermediate_point: $intermediate_point)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceItemModelImpl &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.distance_km, distance_km) ||
                other.distance_km == distance_km) &&
            (identical(other.duration_sec, duration_sec) ||
                other.duration_sec == duration_sec) &&
            (identical(other.tariff_multiplier, tariff_multiplier) ||
                other.tariff_multiplier == tariff_multiplier) &&
            (identical(other.congestion_multiplier, congestion_multiplier) ||
                other.congestion_multiplier == congestion_multiplier) &&
            (identical(other.available_drivers_in_radius,
                    available_drivers_in_radius) ||
                other.available_drivers_in_radius ==
                    available_drivers_in_radius) &&
            (identical(other.breakdown, breakdown) ||
                other.breakdown == breakdown) &&
            (identical(other.intermediate_point, intermediate_point) ||
                other.intermediate_point == intermediate_point));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      price,
      distance_km,
      duration_sec,
      tariff_multiplier,
      congestion_multiplier,
      available_drivers_in_radius,
      breakdown,
      intermediate_point);

  /// Create a copy of PriceItemModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceItemModelImplCopyWith<_$PriceItemModelImpl> get copyWith =>
      __$$PriceItemModelImplCopyWithImpl<_$PriceItemModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PriceItemModelImplToJson(
      this,
    );
  }
}

abstract class _PriceItemModel implements PriceItemModel {
  const factory _PriceItemModel(
      {required final double price,
      required final double distance_km,
      required final int duration_sec,
      required final double tariff_multiplier,
      required final double congestion_multiplier,
      required final int available_drivers_in_radius,
      required final PriceBreakdownModel breakdown,
      final LocationModel? intermediate_point}) = _$PriceItemModelImpl;

  factory _PriceItemModel.fromJson(Map<String, dynamic> json) =
      _$PriceItemModelImpl.fromJson;

  @override
  double get price;
  @override
  double get distance_km;
  @override
  int get duration_sec;
  @override
  double get tariff_multiplier;
  @override
  double get congestion_multiplier;
  @override
  int get available_drivers_in_radius;
  @override
  PriceBreakdownModel get breakdown;
  @override
  LocationModel? get intermediate_point;

  /// Create a copy of PriceItemModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceItemModelImplCopyWith<_$PriceItemModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PricesResponseModel _$PricesResponseModelFromJson(Map<String, dynamic> json) {
  return _PricesResponseModel.fromJson(json);
}

/// @nodoc
mixin _$PricesResponseModel {
  Map<String, PriceItemModel?> get prices => throw _privateConstructorUsedError;

  /// Serializes this PricesResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PricesResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PricesResponseModelCopyWith<PricesResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PricesResponseModelCopyWith<$Res> {
  factory $PricesResponseModelCopyWith(
          PricesResponseModel value, $Res Function(PricesResponseModel) then) =
      _$PricesResponseModelCopyWithImpl<$Res, PricesResponseModel>;
  @useResult
  $Res call({Map<String, PriceItemModel?> prices});
}

/// @nodoc
class _$PricesResponseModelCopyWithImpl<$Res, $Val extends PricesResponseModel>
    implements $PricesResponseModelCopyWith<$Res> {
  _$PricesResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PricesResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prices = null,
  }) {
    return _then(_value.copyWith(
      prices: null == prices
          ? _value.prices
          : prices // ignore: cast_nullable_to_non_nullable
              as Map<String, PriceItemModel?>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PricesResponseModelImplCopyWith<$Res>
    implements $PricesResponseModelCopyWith<$Res> {
  factory _$$PricesResponseModelImplCopyWith(_$PricesResponseModelImpl value,
          $Res Function(_$PricesResponseModelImpl) then) =
      __$$PricesResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, PriceItemModel?> prices});
}

/// @nodoc
class __$$PricesResponseModelImplCopyWithImpl<$Res>
    extends _$PricesResponseModelCopyWithImpl<$Res, _$PricesResponseModelImpl>
    implements _$$PricesResponseModelImplCopyWith<$Res> {
  __$$PricesResponseModelImplCopyWithImpl(_$PricesResponseModelImpl _value,
      $Res Function(_$PricesResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PricesResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prices = null,
  }) {
    return _then(_$PricesResponseModelImpl(
      prices: null == prices
          ? _value._prices
          : prices // ignore: cast_nullable_to_non_nullable
              as Map<String, PriceItemModel?>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PricesResponseModelImpl implements _PricesResponseModel {
  const _$PricesResponseModelImpl(
      {required final Map<String, PriceItemModel?> prices})
      : _prices = prices;

  factory _$PricesResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PricesResponseModelImplFromJson(json);

  final Map<String, PriceItemModel?> _prices;
  @override
  Map<String, PriceItemModel?> get prices {
    if (_prices is EqualUnmodifiableMapView) return _prices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_prices);
  }

  @override
  String toString() {
    return 'PricesResponseModel(prices: $prices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PricesResponseModelImpl &&
            const DeepCollectionEquality().equals(other._prices, _prices));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_prices));

  /// Create a copy of PricesResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PricesResponseModelImplCopyWith<_$PricesResponseModelImpl> get copyWith =>
      __$$PricesResponseModelImplCopyWithImpl<_$PricesResponseModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PricesResponseModelImplToJson(
      this,
    );
  }
}

abstract class _PricesResponseModel implements PricesResponseModel {
  const factory _PricesResponseModel(
          {required final Map<String, PriceItemModel?> prices}) =
      _$PricesResponseModelImpl;

  factory _PricesResponseModel.fromJson(Map<String, dynamic> json) =
      _$PricesResponseModelImpl.fromJson;

  @override
  Map<String, PriceItemModel?> get prices;

  /// Create a copy of PricesResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PricesResponseModelImplCopyWith<_$PricesResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GetETARequestModel _$GetETARequestModelFromJson(Map<String, dynamic> json) {
  return _GetETARequestModel.fromJson(json);
}

/// @nodoc
mixin _$GetETARequestModel {
  LocationModel get user_location => throw _privateConstructorUsedError;
  double? get radius_km => throw _privateConstructorUsedError;

  /// Serializes this GetETARequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GetETARequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GetETARequestModelCopyWith<GetETARequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetETARequestModelCopyWith<$Res> {
  factory $GetETARequestModelCopyWith(
          GetETARequestModel value, $Res Function(GetETARequestModel) then) =
      _$GetETARequestModelCopyWithImpl<$Res, GetETARequestModel>;
  @useResult
  $Res call({LocationModel user_location, double? radius_km});

  $LocationModelCopyWith<$Res> get user_location;
}

/// @nodoc
class _$GetETARequestModelCopyWithImpl<$Res, $Val extends GetETARequestModel>
    implements $GetETARequestModelCopyWith<$Res> {
  _$GetETARequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GetETARequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_location = null,
    Object? radius_km = freezed,
  }) {
    return _then(_value.copyWith(
      user_location: null == user_location
          ? _value.user_location
          : user_location // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      radius_km: freezed == radius_km
          ? _value.radius_km
          : radius_km // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }

  /// Create a copy of GetETARequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get user_location {
    return $LocationModelCopyWith<$Res>(_value.user_location, (value) {
      return _then(_value.copyWith(user_location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetETARequestModelImplCopyWith<$Res>
    implements $GetETARequestModelCopyWith<$Res> {
  factory _$$GetETARequestModelImplCopyWith(_$GetETARequestModelImpl value,
          $Res Function(_$GetETARequestModelImpl) then) =
      __$$GetETARequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({LocationModel user_location, double? radius_km});

  @override
  $LocationModelCopyWith<$Res> get user_location;
}

/// @nodoc
class __$$GetETARequestModelImplCopyWithImpl<$Res>
    extends _$GetETARequestModelCopyWithImpl<$Res, _$GetETARequestModelImpl>
    implements _$$GetETARequestModelImplCopyWith<$Res> {
  __$$GetETARequestModelImplCopyWithImpl(_$GetETARequestModelImpl _value,
      $Res Function(_$GetETARequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of GetETARequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_location = null,
    Object? radius_km = freezed,
  }) {
    return _then(_$GetETARequestModelImpl(
      user_location: null == user_location
          ? _value.user_location
          : user_location // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      radius_km: freezed == radius_km
          ? _value.radius_km
          : radius_km // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetETARequestModelImpl implements _GetETARequestModel {
  const _$GetETARequestModelImpl({required this.user_location, this.radius_km});

  factory _$GetETARequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetETARequestModelImplFromJson(json);

  @override
  final LocationModel user_location;
  @override
  final double? radius_km;

  @override
  String toString() {
    return 'GetETARequestModel(user_location: $user_location, radius_km: $radius_km)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetETARequestModelImpl &&
            (identical(other.user_location, user_location) ||
                other.user_location == user_location) &&
            (identical(other.radius_km, radius_km) ||
                other.radius_km == radius_km));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user_location, radius_km);

  /// Create a copy of GetETARequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetETARequestModelImplCopyWith<_$GetETARequestModelImpl> get copyWith =>
      __$$GetETARequestModelImplCopyWithImpl<_$GetETARequestModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetETARequestModelImplToJson(
      this,
    );
  }
}

abstract class _GetETARequestModel implements GetETARequestModel {
  const factory _GetETARequestModel(
      {required final LocationModel user_location,
      final double? radius_km}) = _$GetETARequestModelImpl;

  factory _GetETARequestModel.fromJson(Map<String, dynamic> json) =
      _$GetETARequestModelImpl.fromJson;

  @override
  LocationModel get user_location;
  @override
  double? get radius_km;

  /// Create a copy of GetETARequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetETARequestModelImplCopyWith<_$GetETARequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GetPricesRequestModel _$GetPricesRequestModelFromJson(
    Map<String, dynamic> json) {
  return _GetPricesRequestModel.fromJson(json);
}

/// @nodoc
mixin _$GetPricesRequestModel {
  LocationModel get user_location => throw _privateConstructorUsedError;
  LocationModel get dest_location => throw _privateConstructorUsedError;
  LocationModel? get intermediate_location =>
      throw _privateConstructorUsedError;
  int get movers => throw _privateConstructorUsedError;

  /// Serializes this GetPricesRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GetPricesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GetPricesRequestModelCopyWith<GetPricesRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetPricesRequestModelCopyWith<$Res> {
  factory $GetPricesRequestModelCopyWith(GetPricesRequestModel value,
          $Res Function(GetPricesRequestModel) then) =
      _$GetPricesRequestModelCopyWithImpl<$Res, GetPricesRequestModel>;
  @useResult
  $Res call(
      {LocationModel user_location,
      LocationModel dest_location,
      LocationModel? intermediate_location,
      int movers});

  $LocationModelCopyWith<$Res> get user_location;
  $LocationModelCopyWith<$Res> get dest_location;
  $LocationModelCopyWith<$Res>? get intermediate_location;
}

/// @nodoc
class _$GetPricesRequestModelCopyWithImpl<$Res,
        $Val extends GetPricesRequestModel>
    implements $GetPricesRequestModelCopyWith<$Res> {
  _$GetPricesRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GetPricesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_location = null,
    Object? dest_location = null,
    Object? intermediate_location = freezed,
    Object? movers = null,
  }) {
    return _then(_value.copyWith(
      user_location: null == user_location
          ? _value.user_location
          : user_location // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      dest_location: null == dest_location
          ? _value.dest_location
          : dest_location // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      intermediate_location: freezed == intermediate_location
          ? _value.intermediate_location
          : intermediate_location // ignore: cast_nullable_to_non_nullable
              as LocationModel?,
      movers: null == movers
          ? _value.movers
          : movers // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of GetPricesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get user_location {
    return $LocationModelCopyWith<$Res>(_value.user_location, (value) {
      return _then(_value.copyWith(user_location: value) as $Val);
    });
  }

  /// Create a copy of GetPricesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res> get dest_location {
    return $LocationModelCopyWith<$Res>(_value.dest_location, (value) {
      return _then(_value.copyWith(dest_location: value) as $Val);
    });
  }

  /// Create a copy of GetPricesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationModelCopyWith<$Res>? get intermediate_location {
    if (_value.intermediate_location == null) {
      return null;
    }

    return $LocationModelCopyWith<$Res>(_value.intermediate_location!, (value) {
      return _then(_value.copyWith(intermediate_location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetPricesRequestModelImplCopyWith<$Res>
    implements $GetPricesRequestModelCopyWith<$Res> {
  factory _$$GetPricesRequestModelImplCopyWith(
          _$GetPricesRequestModelImpl value,
          $Res Function(_$GetPricesRequestModelImpl) then) =
      __$$GetPricesRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LocationModel user_location,
      LocationModel dest_location,
      LocationModel? intermediate_location,
      int movers});

  @override
  $LocationModelCopyWith<$Res> get user_location;
  @override
  $LocationModelCopyWith<$Res> get dest_location;
  @override
  $LocationModelCopyWith<$Res>? get intermediate_location;
}

/// @nodoc
class __$$GetPricesRequestModelImplCopyWithImpl<$Res>
    extends _$GetPricesRequestModelCopyWithImpl<$Res,
        _$GetPricesRequestModelImpl>
    implements _$$GetPricesRequestModelImplCopyWith<$Res> {
  __$$GetPricesRequestModelImplCopyWithImpl(_$GetPricesRequestModelImpl _value,
      $Res Function(_$GetPricesRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of GetPricesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_location = null,
    Object? dest_location = null,
    Object? intermediate_location = freezed,
    Object? movers = null,
  }) {
    return _then(_$GetPricesRequestModelImpl(
      user_location: null == user_location
          ? _value.user_location
          : user_location // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      dest_location: null == dest_location
          ? _value.dest_location
          : dest_location // ignore: cast_nullable_to_non_nullable
              as LocationModel,
      intermediate_location: freezed == intermediate_location
          ? _value.intermediate_location
          : intermediate_location // ignore: cast_nullable_to_non_nullable
              as LocationModel?,
      movers: null == movers
          ? _value.movers
          : movers // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetPricesRequestModelImpl implements _GetPricesRequestModel {
  const _$GetPricesRequestModelImpl(
      {required this.user_location,
      required this.dest_location,
      this.intermediate_location,
      required this.movers});

  factory _$GetPricesRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetPricesRequestModelImplFromJson(json);

  @override
  final LocationModel user_location;
  @override
  final LocationModel dest_location;
  @override
  final LocationModel? intermediate_location;
  @override
  final int movers;

  @override
  String toString() {
    return 'GetPricesRequestModel(user_location: $user_location, dest_location: $dest_location, intermediate_location: $intermediate_location, movers: $movers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetPricesRequestModelImpl &&
            (identical(other.user_location, user_location) ||
                other.user_location == user_location) &&
            (identical(other.dest_location, dest_location) ||
                other.dest_location == dest_location) &&
            (identical(other.intermediate_location, intermediate_location) ||
                other.intermediate_location == intermediate_location) &&
            (identical(other.movers, movers) || other.movers == movers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, user_location, dest_location, intermediate_location, movers);

  /// Create a copy of GetPricesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetPricesRequestModelImplCopyWith<_$GetPricesRequestModelImpl>
      get copyWith => __$$GetPricesRequestModelImplCopyWithImpl<
          _$GetPricesRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetPricesRequestModelImplToJson(
      this,
    );
  }
}

abstract class _GetPricesRequestModel implements GetPricesRequestModel {
  const factory _GetPricesRequestModel(
      {required final LocationModel user_location,
      required final LocationModel dest_location,
      final LocationModel? intermediate_location,
      required final int movers}) = _$GetPricesRequestModelImpl;

  factory _GetPricesRequestModel.fromJson(Map<String, dynamic> json) =
      _$GetPricesRequestModelImpl.fromJson;

  @override
  LocationModel get user_location;
  @override
  LocationModel get dest_location;
  @override
  LocationModel? get intermediate_location;
  @override
  int get movers;

  /// Create a copy of GetPricesRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetPricesRequestModelImplCopyWith<_$GetPricesRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
