// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LocationEntity {
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;

  /// Create a copy of LocationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationEntityCopyWith<LocationEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationEntityCopyWith<$Res> {
  factory $LocationEntityCopyWith(
          LocationEntity value, $Res Function(LocationEntity) then) =
      _$LocationEntityCopyWithImpl<$Res, LocationEntity>;
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class _$LocationEntityCopyWithImpl<$Res, $Val extends LocationEntity>
    implements $LocationEntityCopyWith<$Res> {
  _$LocationEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationEntity
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
abstract class _$$LocationEntityImplCopyWith<$Res>
    implements $LocationEntityCopyWith<$Res> {
  factory _$$LocationEntityImplCopyWith(_$LocationEntityImpl value,
          $Res Function(_$LocationEntityImpl) then) =
      __$$LocationEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class __$$LocationEntityImplCopyWithImpl<$Res>
    extends _$LocationEntityCopyWithImpl<$Res, _$LocationEntityImpl>
    implements _$$LocationEntityImplCopyWith<$Res> {
  __$$LocationEntityImplCopyWithImpl(
      _$LocationEntityImpl _value, $Res Function(_$LocationEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
  }) {
    return _then(_$LocationEntityImpl(
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

class _$LocationEntityImpl implements _LocationEntity {
  const _$LocationEntityImpl({required this.lat, required this.lng});

  @override
  final double lat;
  @override
  final double lng;

  @override
  String toString() {
    return 'LocationEntity(lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationEntityImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @override
  int get hashCode => Object.hash(runtimeType, lat, lng);

  /// Create a copy of LocationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationEntityImplCopyWith<_$LocationEntityImpl> get copyWith =>
      __$$LocationEntityImplCopyWithImpl<_$LocationEntityImpl>(
          this, _$identity);
}

abstract class _LocationEntity implements LocationEntity {
  const factory _LocationEntity(
      {required final double lat,
      required final double lng}) = _$LocationEntityImpl;

  @override
  double get lat;
  @override
  double get lng;

  /// Create a copy of LocationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationEntityImplCopyWith<_$LocationEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DriverEntity {
  String get uid => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get mark => throw _privateConstructorUsedError;
  double? get commissionPercent => throw _privateConstructorUsedError;
  bool get isBlocked => throw _privateConstructorUsedError;
  bool get onShift => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  double get distanceKm => throw _privateConstructorUsedError;

  /// Create a copy of DriverEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriverEntityCopyWith<DriverEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverEntityCopyWith<$Res> {
  factory $DriverEntityCopyWith(
          DriverEntity value, $Res Function(DriverEntity) then) =
      _$DriverEntityCopyWithImpl<$Res, DriverEntity>;
  @useResult
  $Res call(
      {String uid,
      String? displayName,
      String? phoneNumber,
      String? mark,
      double? commissionPercent,
      bool isBlocked,
      bool onShift,
      double lat,
      double lng,
      double distanceKm});
}

/// @nodoc
class _$DriverEntityCopyWithImpl<$Res, $Val extends DriverEntity>
    implements $DriverEntityCopyWith<$Res> {
  _$DriverEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = freezed,
    Object? phoneNumber = freezed,
    Object? mark = freezed,
    Object? commissionPercent = freezed,
    Object? isBlocked = null,
    Object? onShift = null,
    Object? lat = null,
    Object? lng = null,
    Object? distanceKm = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      mark: freezed == mark
          ? _value.mark
          : mark // ignore: cast_nullable_to_non_nullable
              as String?,
      commissionPercent: freezed == commissionPercent
          ? _value.commissionPercent
          : commissionPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      onShift: null == onShift
          ? _value.onShift
          : onShift // ignore: cast_nullable_to_non_nullable
              as bool,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DriverEntityImplCopyWith<$Res>
    implements $DriverEntityCopyWith<$Res> {
  factory _$$DriverEntityImplCopyWith(
          _$DriverEntityImpl value, $Res Function(_$DriverEntityImpl) then) =
      __$$DriverEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String? displayName,
      String? phoneNumber,
      String? mark,
      double? commissionPercent,
      bool isBlocked,
      bool onShift,
      double lat,
      double lng,
      double distanceKm});
}

/// @nodoc
class __$$DriverEntityImplCopyWithImpl<$Res>
    extends _$DriverEntityCopyWithImpl<$Res, _$DriverEntityImpl>
    implements _$$DriverEntityImplCopyWith<$Res> {
  __$$DriverEntityImplCopyWithImpl(
      _$DriverEntityImpl _value, $Res Function(_$DriverEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = freezed,
    Object? phoneNumber = freezed,
    Object? mark = freezed,
    Object? commissionPercent = freezed,
    Object? isBlocked = null,
    Object? onShift = null,
    Object? lat = null,
    Object? lng = null,
    Object? distanceKm = null,
  }) {
    return _then(_$DriverEntityImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      mark: freezed == mark
          ? _value.mark
          : mark // ignore: cast_nullable_to_non_nullable
              as String?,
      commissionPercent: freezed == commissionPercent
          ? _value.commissionPercent
          : commissionPercent // ignore: cast_nullable_to_non_nullable
              as double?,
      isBlocked: null == isBlocked
          ? _value.isBlocked
          : isBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      onShift: null == onShift
          ? _value.onShift
          : onShift // ignore: cast_nullable_to_non_nullable
              as bool,
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$DriverEntityImpl implements _DriverEntity {
  const _$DriverEntityImpl(
      {required this.uid,
      this.displayName,
      this.phoneNumber,
      this.mark,
      this.commissionPercent,
      required this.isBlocked,
      required this.onShift,
      required this.lat,
      required this.lng,
      required this.distanceKm});

  @override
  final String uid;
  @override
  final String? displayName;
  @override
  final String? phoneNumber;
  @override
  final String? mark;
  @override
  final double? commissionPercent;
  @override
  final bool isBlocked;
  @override
  final bool onShift;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final double distanceKm;

  @override
  String toString() {
    return 'DriverEntity(uid: $uid, displayName: $displayName, phoneNumber: $phoneNumber, mark: $mark, commissionPercent: $commissionPercent, isBlocked: $isBlocked, onShift: $onShift, lat: $lat, lng: $lng, distanceKm: $distanceKm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriverEntityImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.mark, mark) || other.mark == mark) &&
            (identical(other.commissionPercent, commissionPercent) ||
                other.commissionPercent == commissionPercent) &&
            (identical(other.isBlocked, isBlocked) ||
                other.isBlocked == isBlocked) &&
            (identical(other.onShift, onShift) || other.onShift == onShift) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm));
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid, displayName, phoneNumber,
      mark, commissionPercent, isBlocked, onShift, lat, lng, distanceKm);

  /// Create a copy of DriverEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriverEntityImplCopyWith<_$DriverEntityImpl> get copyWith =>
      __$$DriverEntityImplCopyWithImpl<_$DriverEntityImpl>(this, _$identity);
}

abstract class _DriverEntity implements DriverEntity {
  const factory _DriverEntity(
      {required final String uid,
      final String? displayName,
      final String? phoneNumber,
      final String? mark,
      final double? commissionPercent,
      required final bool isBlocked,
      required final bool onShift,
      required final double lat,
      required final double lng,
      required final double distanceKm}) = _$DriverEntityImpl;

  @override
  String get uid;
  @override
  String? get displayName;
  @override
  String? get phoneNumber;
  @override
  String? get mark;
  @override
  double? get commissionPercent;
  @override
  bool get isBlocked;
  @override
  bool get onShift;
  @override
  double get lat;
  @override
  double get lng;
  @override
  double get distanceKm;

  /// Create a copy of DriverEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriverEntityImplCopyWith<_$DriverEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ETAItemEntity {
  int get etaSeconds => throw _privateConstructorUsedError;
  String get etaText => throw _privateConstructorUsedError;

  /// Create a copy of ETAItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ETAItemEntityCopyWith<ETAItemEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ETAItemEntityCopyWith<$Res> {
  factory $ETAItemEntityCopyWith(
          ETAItemEntity value, $Res Function(ETAItemEntity) then) =
      _$ETAItemEntityCopyWithImpl<$Res, ETAItemEntity>;
  @useResult
  $Res call({int etaSeconds, String etaText});
}

/// @nodoc
class _$ETAItemEntityCopyWithImpl<$Res, $Val extends ETAItemEntity>
    implements $ETAItemEntityCopyWith<$Res> {
  _$ETAItemEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ETAItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? etaSeconds = null,
    Object? etaText = null,
  }) {
    return _then(_value.copyWith(
      etaSeconds: null == etaSeconds
          ? _value.etaSeconds
          : etaSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      etaText: null == etaText
          ? _value.etaText
          : etaText // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ETAItemEntityImplCopyWith<$Res>
    implements $ETAItemEntityCopyWith<$Res> {
  factory _$$ETAItemEntityImplCopyWith(
          _$ETAItemEntityImpl value, $Res Function(_$ETAItemEntityImpl) then) =
      __$$ETAItemEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int etaSeconds, String etaText});
}

/// @nodoc
class __$$ETAItemEntityImplCopyWithImpl<$Res>
    extends _$ETAItemEntityCopyWithImpl<$Res, _$ETAItemEntityImpl>
    implements _$$ETAItemEntityImplCopyWith<$Res> {
  __$$ETAItemEntityImplCopyWithImpl(
      _$ETAItemEntityImpl _value, $Res Function(_$ETAItemEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of ETAItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? etaSeconds = null,
    Object? etaText = null,
  }) {
    return _then(_$ETAItemEntityImpl(
      etaSeconds: null == etaSeconds
          ? _value.etaSeconds
          : etaSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      etaText: null == etaText
          ? _value.etaText
          : etaText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ETAItemEntityImpl implements _ETAItemEntity {
  const _$ETAItemEntityImpl({required this.etaSeconds, required this.etaText});

  @override
  final int etaSeconds;
  @override
  final String etaText;

  @override
  String toString() {
    return 'ETAItemEntity(etaSeconds: $etaSeconds, etaText: $etaText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ETAItemEntityImpl &&
            (identical(other.etaSeconds, etaSeconds) ||
                other.etaSeconds == etaSeconds) &&
            (identical(other.etaText, etaText) || other.etaText == etaText));
  }

  @override
  int get hashCode => Object.hash(runtimeType, etaSeconds, etaText);

  /// Create a copy of ETAItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ETAItemEntityImplCopyWith<_$ETAItemEntityImpl> get copyWith =>
      __$$ETAItemEntityImplCopyWithImpl<_$ETAItemEntityImpl>(this, _$identity);
}

abstract class _ETAItemEntity implements ETAItemEntity {
  const factory _ETAItemEntity(
      {required final int etaSeconds,
      required final String etaText}) = _$ETAItemEntityImpl;

  @override
  int get etaSeconds;
  @override
  String get etaText;

  /// Create a copy of ETAItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ETAItemEntityImplCopyWith<_$ETAItemEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PriceBreakdownEntity {
  double get priceBase => throw _privateConstructorUsedError;
  double get priceAfterTariff => throw _privateConstructorUsedError;

  /// Create a copy of PriceBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceBreakdownEntityCopyWith<PriceBreakdownEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceBreakdownEntityCopyWith<$Res> {
  factory $PriceBreakdownEntityCopyWith(PriceBreakdownEntity value,
          $Res Function(PriceBreakdownEntity) then) =
      _$PriceBreakdownEntityCopyWithImpl<$Res, PriceBreakdownEntity>;
  @useResult
  $Res call({double priceBase, double priceAfterTariff});
}

/// @nodoc
class _$PriceBreakdownEntityCopyWithImpl<$Res,
        $Val extends PriceBreakdownEntity>
    implements $PriceBreakdownEntityCopyWith<$Res> {
  _$PriceBreakdownEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? priceBase = null,
    Object? priceAfterTariff = null,
  }) {
    return _then(_value.copyWith(
      priceBase: null == priceBase
          ? _value.priceBase
          : priceBase // ignore: cast_nullable_to_non_nullable
              as double,
      priceAfterTariff: null == priceAfterTariff
          ? _value.priceAfterTariff
          : priceAfterTariff // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PriceBreakdownEntityImplCopyWith<$Res>
    implements $PriceBreakdownEntityCopyWith<$Res> {
  factory _$$PriceBreakdownEntityImplCopyWith(_$PriceBreakdownEntityImpl value,
          $Res Function(_$PriceBreakdownEntityImpl) then) =
      __$$PriceBreakdownEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double priceBase, double priceAfterTariff});
}

/// @nodoc
class __$$PriceBreakdownEntityImplCopyWithImpl<$Res>
    extends _$PriceBreakdownEntityCopyWithImpl<$Res, _$PriceBreakdownEntityImpl>
    implements _$$PriceBreakdownEntityImplCopyWith<$Res> {
  __$$PriceBreakdownEntityImplCopyWithImpl(_$PriceBreakdownEntityImpl _value,
      $Res Function(_$PriceBreakdownEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? priceBase = null,
    Object? priceAfterTariff = null,
  }) {
    return _then(_$PriceBreakdownEntityImpl(
      priceBase: null == priceBase
          ? _value.priceBase
          : priceBase // ignore: cast_nullable_to_non_nullable
              as double,
      priceAfterTariff: null == priceAfterTariff
          ? _value.priceAfterTariff
          : priceAfterTariff // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$PriceBreakdownEntityImpl implements _PriceBreakdownEntity {
  const _$PriceBreakdownEntityImpl(
      {required this.priceBase, required this.priceAfterTariff});

  @override
  final double priceBase;
  @override
  final double priceAfterTariff;

  @override
  String toString() {
    return 'PriceBreakdownEntity(priceBase: $priceBase, priceAfterTariff: $priceAfterTariff)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceBreakdownEntityImpl &&
            (identical(other.priceBase, priceBase) ||
                other.priceBase == priceBase) &&
            (identical(other.priceAfterTariff, priceAfterTariff) ||
                other.priceAfterTariff == priceAfterTariff));
  }

  @override
  int get hashCode => Object.hash(runtimeType, priceBase, priceAfterTariff);

  /// Create a copy of PriceBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceBreakdownEntityImplCopyWith<_$PriceBreakdownEntityImpl>
      get copyWith =>
          __$$PriceBreakdownEntityImplCopyWithImpl<_$PriceBreakdownEntityImpl>(
              this, _$identity);
}

abstract class _PriceBreakdownEntity implements PriceBreakdownEntity {
  const factory _PriceBreakdownEntity(
      {required final double priceBase,
      required final double priceAfterTariff}) = _$PriceBreakdownEntityImpl;

  @override
  double get priceBase;
  @override
  double get priceAfterTariff;

  /// Create a copy of PriceBreakdownEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceBreakdownEntityImplCopyWith<_$PriceBreakdownEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PriceItemEntity {
  double get price => throw _privateConstructorUsedError;
  double get distanceKm => throw _privateConstructorUsedError;
  int get durationSec => throw _privateConstructorUsedError;
  double get tariffMultiplier => throw _privateConstructorUsedError;
  double get congestionMultiplier => throw _privateConstructorUsedError;
  int get availableDriversInRadius => throw _privateConstructorUsedError;
  PriceBreakdownEntity get breakdown => throw _privateConstructorUsedError;
  LocationEntity? get intermediatePoint => throw _privateConstructorUsedError;

  /// Create a copy of PriceItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PriceItemEntityCopyWith<PriceItemEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PriceItemEntityCopyWith<$Res> {
  factory $PriceItemEntityCopyWith(
          PriceItemEntity value, $Res Function(PriceItemEntity) then) =
      _$PriceItemEntityCopyWithImpl<$Res, PriceItemEntity>;
  @useResult
  $Res call(
      {double price,
      double distanceKm,
      int durationSec,
      double tariffMultiplier,
      double congestionMultiplier,
      int availableDriversInRadius,
      PriceBreakdownEntity breakdown,
      LocationEntity? intermediatePoint});

  $PriceBreakdownEntityCopyWith<$Res> get breakdown;
  $LocationEntityCopyWith<$Res>? get intermediatePoint;
}

/// @nodoc
class _$PriceItemEntityCopyWithImpl<$Res, $Val extends PriceItemEntity>
    implements $PriceItemEntityCopyWith<$Res> {
  _$PriceItemEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PriceItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? distanceKm = null,
    Object? durationSec = null,
    Object? tariffMultiplier = null,
    Object? congestionMultiplier = null,
    Object? availableDriversInRadius = null,
    Object? breakdown = null,
    Object? intermediatePoint = freezed,
  }) {
    return _then(_value.copyWith(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      durationSec: null == durationSec
          ? _value.durationSec
          : durationSec // ignore: cast_nullable_to_non_nullable
              as int,
      tariffMultiplier: null == tariffMultiplier
          ? _value.tariffMultiplier
          : tariffMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      congestionMultiplier: null == congestionMultiplier
          ? _value.congestionMultiplier
          : congestionMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      availableDriversInRadius: null == availableDriversInRadius
          ? _value.availableDriversInRadius
          : availableDriversInRadius // ignore: cast_nullable_to_non_nullable
              as int,
      breakdown: null == breakdown
          ? _value.breakdown
          : breakdown // ignore: cast_nullable_to_non_nullable
              as PriceBreakdownEntity,
      intermediatePoint: freezed == intermediatePoint
          ? _value.intermediatePoint
          : intermediatePoint // ignore: cast_nullable_to_non_nullable
              as LocationEntity?,
    ) as $Val);
  }

  /// Create a copy of PriceItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceBreakdownEntityCopyWith<$Res> get breakdown {
    return $PriceBreakdownEntityCopyWith<$Res>(_value.breakdown, (value) {
      return _then(_value.copyWith(breakdown: value) as $Val);
    });
  }

  /// Create a copy of PriceItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationEntityCopyWith<$Res>? get intermediatePoint {
    if (_value.intermediatePoint == null) {
      return null;
    }

    return $LocationEntityCopyWith<$Res>(_value.intermediatePoint!, (value) {
      return _then(_value.copyWith(intermediatePoint: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PriceItemEntityImplCopyWith<$Res>
    implements $PriceItemEntityCopyWith<$Res> {
  factory _$$PriceItemEntityImplCopyWith(_$PriceItemEntityImpl value,
          $Res Function(_$PriceItemEntityImpl) then) =
      __$$PriceItemEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double price,
      double distanceKm,
      int durationSec,
      double tariffMultiplier,
      double congestionMultiplier,
      int availableDriversInRadius,
      PriceBreakdownEntity breakdown,
      LocationEntity? intermediatePoint});

  @override
  $PriceBreakdownEntityCopyWith<$Res> get breakdown;
  @override
  $LocationEntityCopyWith<$Res>? get intermediatePoint;
}

/// @nodoc
class __$$PriceItemEntityImplCopyWithImpl<$Res>
    extends _$PriceItemEntityCopyWithImpl<$Res, _$PriceItemEntityImpl>
    implements _$$PriceItemEntityImplCopyWith<$Res> {
  __$$PriceItemEntityImplCopyWithImpl(
      _$PriceItemEntityImpl _value, $Res Function(_$PriceItemEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of PriceItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? price = null,
    Object? distanceKm = null,
    Object? durationSec = null,
    Object? tariffMultiplier = null,
    Object? congestionMultiplier = null,
    Object? availableDriversInRadius = null,
    Object? breakdown = null,
    Object? intermediatePoint = freezed,
  }) {
    return _then(_$PriceItemEntityImpl(
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      durationSec: null == durationSec
          ? _value.durationSec
          : durationSec // ignore: cast_nullable_to_non_nullable
              as int,
      tariffMultiplier: null == tariffMultiplier
          ? _value.tariffMultiplier
          : tariffMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      congestionMultiplier: null == congestionMultiplier
          ? _value.congestionMultiplier
          : congestionMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      availableDriversInRadius: null == availableDriversInRadius
          ? _value.availableDriversInRadius
          : availableDriversInRadius // ignore: cast_nullable_to_non_nullable
              as int,
      breakdown: null == breakdown
          ? _value.breakdown
          : breakdown // ignore: cast_nullable_to_non_nullable
              as PriceBreakdownEntity,
      intermediatePoint: freezed == intermediatePoint
          ? _value.intermediatePoint
          : intermediatePoint // ignore: cast_nullable_to_non_nullable
              as LocationEntity?,
    ));
  }
}

/// @nodoc

class _$PriceItemEntityImpl implements _PriceItemEntity {
  const _$PriceItemEntityImpl(
      {required this.price,
      required this.distanceKm,
      required this.durationSec,
      required this.tariffMultiplier,
      required this.congestionMultiplier,
      required this.availableDriversInRadius,
      required this.breakdown,
      this.intermediatePoint});

  @override
  final double price;
  @override
  final double distanceKm;
  @override
  final int durationSec;
  @override
  final double tariffMultiplier;
  @override
  final double congestionMultiplier;
  @override
  final int availableDriversInRadius;
  @override
  final PriceBreakdownEntity breakdown;
  @override
  final LocationEntity? intermediatePoint;

  @override
  String toString() {
    return 'PriceItemEntity(price: $price, distanceKm: $distanceKm, durationSec: $durationSec, tariffMultiplier: $tariffMultiplier, congestionMultiplier: $congestionMultiplier, availableDriversInRadius: $availableDriversInRadius, breakdown: $breakdown, intermediatePoint: $intermediatePoint)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PriceItemEntityImpl &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.durationSec, durationSec) ||
                other.durationSec == durationSec) &&
            (identical(other.tariffMultiplier, tariffMultiplier) ||
                other.tariffMultiplier == tariffMultiplier) &&
            (identical(other.congestionMultiplier, congestionMultiplier) ||
                other.congestionMultiplier == congestionMultiplier) &&
            (identical(
                    other.availableDriversInRadius, availableDriversInRadius) ||
                other.availableDriversInRadius == availableDriversInRadius) &&
            (identical(other.breakdown, breakdown) ||
                other.breakdown == breakdown) &&
            (identical(other.intermediatePoint, intermediatePoint) ||
                other.intermediatePoint == intermediatePoint));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      price,
      distanceKm,
      durationSec,
      tariffMultiplier,
      congestionMultiplier,
      availableDriversInRadius,
      breakdown,
      intermediatePoint);

  /// Create a copy of PriceItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PriceItemEntityImplCopyWith<_$PriceItemEntityImpl> get copyWith =>
      __$$PriceItemEntityImplCopyWithImpl<_$PriceItemEntityImpl>(
          this, _$identity);
}

abstract class _PriceItemEntity implements PriceItemEntity {
  const factory _PriceItemEntity(
      {required final double price,
      required final double distanceKm,
      required final int durationSec,
      required final double tariffMultiplier,
      required final double congestionMultiplier,
      required final int availableDriversInRadius,
      required final PriceBreakdownEntity breakdown,
      final LocationEntity? intermediatePoint}) = _$PriceItemEntityImpl;

  @override
  double get price;
  @override
  double get distanceKm;
  @override
  int get durationSec;
  @override
  double get tariffMultiplier;
  @override
  double get congestionMultiplier;
  @override
  int get availableDriversInRadius;
  @override
  PriceBreakdownEntity get breakdown;
  @override
  LocationEntity? get intermediatePoint;

  /// Create a copy of PriceItemEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PriceItemEntityImplCopyWith<_$PriceItemEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
