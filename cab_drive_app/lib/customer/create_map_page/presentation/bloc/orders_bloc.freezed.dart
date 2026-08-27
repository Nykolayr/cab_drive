// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'orders_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrdersEvent {
  LocationEntity get userLocation => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(LocationEntity userLocation, double? radiusKm)
        getEtas,
    required TResult Function(
            LocationEntity userLocation,
            LocationEntity destLocation,
            LocationEntity? intermediate,
            int movers,
            dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess)
        getPrices,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(LocationEntity userLocation, double? radiusKm)? getEtas,
    TResult? Function(
            LocationEntity userLocation,
            LocationEntity destLocation,
            LocationEntity? intermediate,
            int movers,
            dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess)?
        getPrices,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(LocationEntity userLocation, double? radiusKm)? getEtas,
    TResult Function(
            LocationEntity userLocation,
            LocationEntity destLocation,
            LocationEntity? intermediate,
            int movers,
            dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess)?
        getPrices,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetEtas value) getEtas,
    required TResult Function(_GetPrices value) getPrices,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetEtas value)? getEtas,
    TResult? Function(_GetPrices value)? getPrices,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetEtas value)? getEtas,
    TResult Function(_GetPrices value)? getPrices,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrdersEventCopyWith<OrdersEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrdersEventCopyWith<$Res> {
  factory $OrdersEventCopyWith(
          OrdersEvent value, $Res Function(OrdersEvent) then) =
      _$OrdersEventCopyWithImpl<$Res, OrdersEvent>;
  @useResult
  $Res call({LocationEntity userLocation});

  $LocationEntityCopyWith<$Res> get userLocation;
}

/// @nodoc
class _$OrdersEventCopyWithImpl<$Res, $Val extends OrdersEvent>
    implements $OrdersEventCopyWith<$Res> {
  _$OrdersEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userLocation = null,
  }) {
    return _then(_value.copyWith(
      userLocation: null == userLocation
          ? _value.userLocation
          : userLocation // ignore: cast_nullable_to_non_nullable
              as LocationEntity,
    ) as $Val);
  }

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationEntityCopyWith<$Res> get userLocation {
    return $LocationEntityCopyWith<$Res>(_value.userLocation, (value) {
      return _then(_value.copyWith(userLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetEtasImplCopyWith<$Res>
    implements $OrdersEventCopyWith<$Res> {
  factory _$$GetEtasImplCopyWith(
          _$GetEtasImpl value, $Res Function(_$GetEtasImpl) then) =
      __$$GetEtasImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({LocationEntity userLocation, double? radiusKm});

  @override
  $LocationEntityCopyWith<$Res> get userLocation;
}

/// @nodoc
class __$$GetEtasImplCopyWithImpl<$Res>
    extends _$OrdersEventCopyWithImpl<$Res, _$GetEtasImpl>
    implements _$$GetEtasImplCopyWith<$Res> {
  __$$GetEtasImplCopyWithImpl(
      _$GetEtasImpl _value, $Res Function(_$GetEtasImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userLocation = null,
    Object? radiusKm = freezed,
  }) {
    return _then(_$GetEtasImpl(
      userLocation: null == userLocation
          ? _value.userLocation
          : userLocation // ignore: cast_nullable_to_non_nullable
              as LocationEntity,
      radiusKm: freezed == radiusKm
          ? _value.radiusKm
          : radiusKm // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$GetEtasImpl implements _GetEtas {
  const _$GetEtasImpl({required this.userLocation, this.radiusKm});

  @override
  final LocationEntity userLocation;
  @override
  final double? radiusKm;

  @override
  String toString() {
    return 'OrdersEvent.getEtas(userLocation: $userLocation, radiusKm: $radiusKm)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetEtasImpl &&
            (identical(other.userLocation, userLocation) ||
                other.userLocation == userLocation) &&
            (identical(other.radiusKm, radiusKm) ||
                other.radiusKm == radiusKm));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userLocation, radiusKm);

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetEtasImplCopyWith<_$GetEtasImpl> get copyWith =>
      __$$GetEtasImplCopyWithImpl<_$GetEtasImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(LocationEntity userLocation, double? radiusKm)
        getEtas,
    required TResult Function(
            LocationEntity userLocation,
            LocationEntity destLocation,
            LocationEntity? intermediate,
            int movers,
            dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess)
        getPrices,
  }) {
    return getEtas(userLocation, radiusKm);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(LocationEntity userLocation, double? radiusKm)? getEtas,
    TResult? Function(
            LocationEntity userLocation,
            LocationEntity destLocation,
            LocationEntity? intermediate,
            int movers,
            dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess)?
        getPrices,
  }) {
    return getEtas?.call(userLocation, radiusKm);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(LocationEntity userLocation, double? radiusKm)? getEtas,
    TResult Function(
            LocationEntity userLocation,
            LocationEntity destLocation,
            LocationEntity? intermediate,
            int movers,
            dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess)?
        getPrices,
    required TResult orElse(),
  }) {
    if (getEtas != null) {
      return getEtas(userLocation, radiusKm);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetEtas value) getEtas,
    required TResult Function(_GetPrices value) getPrices,
  }) {
    return getEtas(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetEtas value)? getEtas,
    TResult? Function(_GetPrices value)? getPrices,
  }) {
    return getEtas?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetEtas value)? getEtas,
    TResult Function(_GetPrices value)? getPrices,
    required TResult orElse(),
  }) {
    if (getEtas != null) {
      return getEtas(this);
    }
    return orElse();
  }
}

abstract class _GetEtas implements OrdersEvent {
  const factory _GetEtas(
      {required final LocationEntity userLocation,
      final double? radiusKm}) = _$GetEtasImpl;

  @override
  LocationEntity get userLocation;
  double? get radiusKm;

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetEtasImplCopyWith<_$GetEtasImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetPricesImplCopyWith<$Res>
    implements $OrdersEventCopyWith<$Res> {
  factory _$$GetPricesImplCopyWith(
          _$GetPricesImpl value, $Res Function(_$GetPricesImpl) then) =
      __$$GetPricesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LocationEntity userLocation,
      LocationEntity destLocation,
      LocationEntity? intermediate,
      int movers,
      dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess});

  @override
  $LocationEntityCopyWith<$Res> get userLocation;
  $LocationEntityCopyWith<$Res> get destLocation;
  $LocationEntityCopyWith<$Res>? get intermediate;
}

/// @nodoc
class __$$GetPricesImplCopyWithImpl<$Res>
    extends _$OrdersEventCopyWithImpl<$Res, _$GetPricesImpl>
    implements _$$GetPricesImplCopyWith<$Res> {
  __$$GetPricesImplCopyWithImpl(
      _$GetPricesImpl _value, $Res Function(_$GetPricesImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userLocation = null,
    Object? destLocation = null,
    Object? intermediate = freezed,
    Object? movers = null,
    Object? onSuccess = freezed,
  }) {
    return _then(_$GetPricesImpl(
      userLocation: null == userLocation
          ? _value.userLocation
          : userLocation // ignore: cast_nullable_to_non_nullable
              as LocationEntity,
      destLocation: null == destLocation
          ? _value.destLocation
          : destLocation // ignore: cast_nullable_to_non_nullable
              as LocationEntity,
      intermediate: freezed == intermediate
          ? _value.intermediate
          : intermediate // ignore: cast_nullable_to_non_nullable
              as LocationEntity?,
      movers: null == movers
          ? _value.movers
          : movers // ignore: cast_nullable_to_non_nullable
              as int,
      onSuccess: freezed == onSuccess
          ? _value.onSuccess
          : onSuccess // ignore: cast_nullable_to_non_nullable
              as dynamic Function(Map<String, PriceItemEntity?>?)?,
    ));
  }

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationEntityCopyWith<$Res> get destLocation {
    return $LocationEntityCopyWith<$Res>(_value.destLocation, (value) {
      return _then(_value.copyWith(destLocation: value));
    });
  }

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationEntityCopyWith<$Res>? get intermediate {
    if (_value.intermediate == null) {
      return null;
    }

    return $LocationEntityCopyWith<$Res>(_value.intermediate!, (value) {
      return _then(_value.copyWith(intermediate: value));
    });
  }
}

/// @nodoc

class _$GetPricesImpl implements _GetPrices {
  const _$GetPricesImpl(
      {required this.userLocation,
      required this.destLocation,
      this.intermediate,
      required this.movers,
      this.onSuccess});

  @override
  final LocationEntity userLocation;
  @override
  final LocationEntity destLocation;
  @override
  final LocationEntity? intermediate;
  @override
  final int movers;
  @override
  final dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess;

  @override
  String toString() {
    return 'OrdersEvent.getPrices(userLocation: $userLocation, destLocation: $destLocation, intermediate: $intermediate, movers: $movers, onSuccess: $onSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetPricesImpl &&
            (identical(other.userLocation, userLocation) ||
                other.userLocation == userLocation) &&
            (identical(other.destLocation, destLocation) ||
                other.destLocation == destLocation) &&
            (identical(other.intermediate, intermediate) ||
                other.intermediate == intermediate) &&
            (identical(other.movers, movers) || other.movers == movers) &&
            (identical(other.onSuccess, onSuccess) ||
                other.onSuccess == onSuccess));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, userLocation, destLocation, intermediate, movers, onSuccess);

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetPricesImplCopyWith<_$GetPricesImpl> get copyWith =>
      __$$GetPricesImplCopyWithImpl<_$GetPricesImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(LocationEntity userLocation, double? radiusKm)
        getEtas,
    required TResult Function(
            LocationEntity userLocation,
            LocationEntity destLocation,
            LocationEntity? intermediate,
            int movers,
            dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess)
        getPrices,
  }) {
    return getPrices(
        userLocation, destLocation, intermediate, movers, onSuccess);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(LocationEntity userLocation, double? radiusKm)? getEtas,
    TResult? Function(
            LocationEntity userLocation,
            LocationEntity destLocation,
            LocationEntity? intermediate,
            int movers,
            dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess)?
        getPrices,
  }) {
    return getPrices?.call(
        userLocation, destLocation, intermediate, movers, onSuccess);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(LocationEntity userLocation, double? radiusKm)? getEtas,
    TResult Function(
            LocationEntity userLocation,
            LocationEntity destLocation,
            LocationEntity? intermediate,
            int movers,
            dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess)?
        getPrices,
    required TResult orElse(),
  }) {
    if (getPrices != null) {
      return getPrices(
          userLocation, destLocation, intermediate, movers, onSuccess);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetEtas value) getEtas,
    required TResult Function(_GetPrices value) getPrices,
  }) {
    return getPrices(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetEtas value)? getEtas,
    TResult? Function(_GetPrices value)? getPrices,
  }) {
    return getPrices?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetEtas value)? getEtas,
    TResult Function(_GetPrices value)? getPrices,
    required TResult orElse(),
  }) {
    if (getPrices != null) {
      return getPrices(this);
    }
    return orElse();
  }
}

abstract class _GetPrices implements OrdersEvent {
  const factory _GetPrices(
          {required final LocationEntity userLocation,
          required final LocationEntity destLocation,
          final LocationEntity? intermediate,
          required final int movers,
          final dynamic Function(Map<String, PriceItemEntity?>?)? onSuccess}) =
      _$GetPricesImpl;

  @override
  LocationEntity get userLocation;
  LocationEntity get destLocation;
  LocationEntity? get intermediate;
  int get movers;
  dynamic Function(Map<String, PriceItemEntity?>?)? get onSuccess;

  /// Create a copy of OrdersEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetPricesImplCopyWith<_$GetPricesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OrdersState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrdersStateCopyWith<$Res> {
  factory $OrdersStateCopyWith(
          OrdersState value, $Res Function(OrdersState) then) =
      _$OrdersStateCopyWithImpl<$Res, OrdersState>;
}

/// @nodoc
class _$OrdersStateCopyWithImpl<$Res, $Val extends OrdersState>
    implements $OrdersStateCopyWith<$Res> {
  _$OrdersStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrdersState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$OrdersStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrdersState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'OrdersState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)
        loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements OrdersState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$OrdersStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrdersState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'OrdersState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements OrdersState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {Map<String, ETAItemEntity?>? etas,
      Map<String, PriceItemEntity?>? prices});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$OrdersStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrdersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? etas = freezed,
    Object? prices = freezed,
  }) {
    return _then(_$LoadedImpl(
      etas: freezed == etas
          ? _value._etas
          : etas // ignore: cast_nullable_to_non_nullable
              as Map<String, ETAItemEntity?>?,
      prices: freezed == prices
          ? _value._prices
          : prices // ignore: cast_nullable_to_non_nullable
              as Map<String, PriceItemEntity?>?,
    ));
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl(
      {required final Map<String, ETAItemEntity?>? etas,
      required final Map<String, PriceItemEntity?>? prices})
      : _etas = etas,
        _prices = prices;

  final Map<String, ETAItemEntity?>? _etas;
  @override
  Map<String, ETAItemEntity?>? get etas {
    final value = _etas;
    if (value == null) return null;
    if (_etas is EqualUnmodifiableMapView) return _etas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, PriceItemEntity?>? _prices;
  @override
  Map<String, PriceItemEntity?>? get prices {
    final value = _prices;
    if (value == null) return null;
    if (_prices is EqualUnmodifiableMapView) return _prices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'OrdersState.loaded(etas: $etas, prices: $prices)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            const DeepCollectionEquality().equals(other._etas, _etas) &&
            const DeepCollectionEquality().equals(other._prices, _prices));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_etas),
      const DeepCollectionEquality().hash(_prices));

  /// Create a copy of OrdersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(etas, prices);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(etas, prices);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(etas, prices);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements OrdersState {
  const factory _Loaded(
      {required final Map<String, ETAItemEntity?>? etas,
      required final Map<String, PriceItemEntity?>? prices}) = _$LoadedImpl;

  Map<String, ETAItemEntity?>? get etas;
  Map<String, PriceItemEntity?>? get prices;

  /// Create a copy of OrdersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$OrdersStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrdersState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'OrdersState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of OrdersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)
        loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Map<String, ETAItemEntity?>? etas,
            Map<String, PriceItemEntity?>? prices)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements OrdersState {
  const factory _Error({required final String message}) = _$ErrorImpl;

  String get message;

  /// Create a copy of OrdersState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
