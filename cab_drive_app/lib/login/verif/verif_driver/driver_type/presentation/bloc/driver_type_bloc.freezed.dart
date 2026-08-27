// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_type_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DriverTypeEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DriverMainType type) selectMainType,
    required TResult Function(DriverLegalType type) selectLegalType,
    required TResult Function(String inn) innChanged,
    required TResult Function() verifyInn,
    required TResult Function() continuePressed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DriverMainType type)? selectMainType,
    TResult? Function(DriverLegalType type)? selectLegalType,
    TResult? Function(String inn)? innChanged,
    TResult? Function()? verifyInn,
    TResult? Function()? continuePressed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DriverMainType type)? selectMainType,
    TResult Function(DriverLegalType type)? selectLegalType,
    TResult Function(String inn)? innChanged,
    TResult Function()? verifyInn,
    TResult Function()? continuePressed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SelectMainType value) selectMainType,
    required TResult Function(_SelectLegalType value) selectLegalType,
    required TResult Function(_InnChanged value) innChanged,
    required TResult Function(_VerifyInn value) verifyInn,
    required TResult Function(_ContinuePressed value) continuePressed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SelectMainType value)? selectMainType,
    TResult? Function(_SelectLegalType value)? selectLegalType,
    TResult? Function(_InnChanged value)? innChanged,
    TResult? Function(_VerifyInn value)? verifyInn,
    TResult? Function(_ContinuePressed value)? continuePressed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SelectMainType value)? selectMainType,
    TResult Function(_SelectLegalType value)? selectLegalType,
    TResult Function(_InnChanged value)? innChanged,
    TResult Function(_VerifyInn value)? verifyInn,
    TResult Function(_ContinuePressed value)? continuePressed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverTypeEventCopyWith<$Res> {
  factory $DriverTypeEventCopyWith(
          DriverTypeEvent value, $Res Function(DriverTypeEvent) then) =
      _$DriverTypeEventCopyWithImpl<$Res, DriverTypeEvent>;
}

/// @nodoc
class _$DriverTypeEventCopyWithImpl<$Res, $Val extends DriverTypeEvent>
    implements $DriverTypeEventCopyWith<$Res> {
  _$DriverTypeEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$SelectMainTypeImplCopyWith<$Res> {
  factory _$$SelectMainTypeImplCopyWith(_$SelectMainTypeImpl value,
          $Res Function(_$SelectMainTypeImpl) then) =
      __$$SelectMainTypeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DriverMainType type});
}

/// @nodoc
class __$$SelectMainTypeImplCopyWithImpl<$Res>
    extends _$DriverTypeEventCopyWithImpl<$Res, _$SelectMainTypeImpl>
    implements _$$SelectMainTypeImplCopyWith<$Res> {
  __$$SelectMainTypeImplCopyWithImpl(
      _$SelectMainTypeImpl _value, $Res Function(_$SelectMainTypeImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
  }) {
    return _then(_$SelectMainTypeImpl(
      null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DriverMainType,
    ));
  }
}

/// @nodoc

class _$SelectMainTypeImpl implements _SelectMainType {
  const _$SelectMainTypeImpl(this.type);

  @override
  final DriverMainType type;

  @override
  String toString() {
    return 'DriverTypeEvent.selectMainType(type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectMainTypeImpl &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type);

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectMainTypeImplCopyWith<_$SelectMainTypeImpl> get copyWith =>
      __$$SelectMainTypeImplCopyWithImpl<_$SelectMainTypeImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DriverMainType type) selectMainType,
    required TResult Function(DriverLegalType type) selectLegalType,
    required TResult Function(String inn) innChanged,
    required TResult Function() verifyInn,
    required TResult Function() continuePressed,
  }) {
    return selectMainType(type);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DriverMainType type)? selectMainType,
    TResult? Function(DriverLegalType type)? selectLegalType,
    TResult? Function(String inn)? innChanged,
    TResult? Function()? verifyInn,
    TResult? Function()? continuePressed,
  }) {
    return selectMainType?.call(type);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DriverMainType type)? selectMainType,
    TResult Function(DriverLegalType type)? selectLegalType,
    TResult Function(String inn)? innChanged,
    TResult Function()? verifyInn,
    TResult Function()? continuePressed,
    required TResult orElse(),
  }) {
    if (selectMainType != null) {
      return selectMainType(type);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SelectMainType value) selectMainType,
    required TResult Function(_SelectLegalType value) selectLegalType,
    required TResult Function(_InnChanged value) innChanged,
    required TResult Function(_VerifyInn value) verifyInn,
    required TResult Function(_ContinuePressed value) continuePressed,
  }) {
    return selectMainType(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SelectMainType value)? selectMainType,
    TResult? Function(_SelectLegalType value)? selectLegalType,
    TResult? Function(_InnChanged value)? innChanged,
    TResult? Function(_VerifyInn value)? verifyInn,
    TResult? Function(_ContinuePressed value)? continuePressed,
  }) {
    return selectMainType?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SelectMainType value)? selectMainType,
    TResult Function(_SelectLegalType value)? selectLegalType,
    TResult Function(_InnChanged value)? innChanged,
    TResult Function(_VerifyInn value)? verifyInn,
    TResult Function(_ContinuePressed value)? continuePressed,
    required TResult orElse(),
  }) {
    if (selectMainType != null) {
      return selectMainType(this);
    }
    return orElse();
  }
}

abstract class _SelectMainType implements DriverTypeEvent {
  const factory _SelectMainType(final DriverMainType type) =
      _$SelectMainTypeImpl;

  DriverMainType get type;

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectMainTypeImplCopyWith<_$SelectMainTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SelectLegalTypeImplCopyWith<$Res> {
  factory _$$SelectLegalTypeImplCopyWith(_$SelectLegalTypeImpl value,
          $Res Function(_$SelectLegalTypeImpl) then) =
      __$$SelectLegalTypeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DriverLegalType type});
}

/// @nodoc
class __$$SelectLegalTypeImplCopyWithImpl<$Res>
    extends _$DriverTypeEventCopyWithImpl<$Res, _$SelectLegalTypeImpl>
    implements _$$SelectLegalTypeImplCopyWith<$Res> {
  __$$SelectLegalTypeImplCopyWithImpl(
      _$SelectLegalTypeImpl _value, $Res Function(_$SelectLegalTypeImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
  }) {
    return _then(_$SelectLegalTypeImpl(
      null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DriverLegalType,
    ));
  }
}

/// @nodoc

class _$SelectLegalTypeImpl implements _SelectLegalType {
  const _$SelectLegalTypeImpl(this.type);

  @override
  final DriverLegalType type;

  @override
  String toString() {
    return 'DriverTypeEvent.selectLegalType(type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SelectLegalTypeImpl &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(runtimeType, type);

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SelectLegalTypeImplCopyWith<_$SelectLegalTypeImpl> get copyWith =>
      __$$SelectLegalTypeImplCopyWithImpl<_$SelectLegalTypeImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DriverMainType type) selectMainType,
    required TResult Function(DriverLegalType type) selectLegalType,
    required TResult Function(String inn) innChanged,
    required TResult Function() verifyInn,
    required TResult Function() continuePressed,
  }) {
    return selectLegalType(type);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DriverMainType type)? selectMainType,
    TResult? Function(DriverLegalType type)? selectLegalType,
    TResult? Function(String inn)? innChanged,
    TResult? Function()? verifyInn,
    TResult? Function()? continuePressed,
  }) {
    return selectLegalType?.call(type);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DriverMainType type)? selectMainType,
    TResult Function(DriverLegalType type)? selectLegalType,
    TResult Function(String inn)? innChanged,
    TResult Function()? verifyInn,
    TResult Function()? continuePressed,
    required TResult orElse(),
  }) {
    if (selectLegalType != null) {
      return selectLegalType(type);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SelectMainType value) selectMainType,
    required TResult Function(_SelectLegalType value) selectLegalType,
    required TResult Function(_InnChanged value) innChanged,
    required TResult Function(_VerifyInn value) verifyInn,
    required TResult Function(_ContinuePressed value) continuePressed,
  }) {
    return selectLegalType(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SelectMainType value)? selectMainType,
    TResult? Function(_SelectLegalType value)? selectLegalType,
    TResult? Function(_InnChanged value)? innChanged,
    TResult? Function(_VerifyInn value)? verifyInn,
    TResult? Function(_ContinuePressed value)? continuePressed,
  }) {
    return selectLegalType?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SelectMainType value)? selectMainType,
    TResult Function(_SelectLegalType value)? selectLegalType,
    TResult Function(_InnChanged value)? innChanged,
    TResult Function(_VerifyInn value)? verifyInn,
    TResult Function(_ContinuePressed value)? continuePressed,
    required TResult orElse(),
  }) {
    if (selectLegalType != null) {
      return selectLegalType(this);
    }
    return orElse();
  }
}

abstract class _SelectLegalType implements DriverTypeEvent {
  const factory _SelectLegalType(final DriverLegalType type) =
      _$SelectLegalTypeImpl;

  DriverLegalType get type;

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SelectLegalTypeImplCopyWith<_$SelectLegalTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$InnChangedImplCopyWith<$Res> {
  factory _$$InnChangedImplCopyWith(
          _$InnChangedImpl value, $Res Function(_$InnChangedImpl) then) =
      __$$InnChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String inn});
}

/// @nodoc
class __$$InnChangedImplCopyWithImpl<$Res>
    extends _$DriverTypeEventCopyWithImpl<$Res, _$InnChangedImpl>
    implements _$$InnChangedImplCopyWith<$Res> {
  __$$InnChangedImplCopyWithImpl(
      _$InnChangedImpl _value, $Res Function(_$InnChangedImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inn = null,
  }) {
    return _then(_$InnChangedImpl(
      null == inn
          ? _value.inn
          : inn // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$InnChangedImpl implements _InnChanged {
  const _$InnChangedImpl(this.inn);

  @override
  final String inn;

  @override
  String toString() {
    return 'DriverTypeEvent.innChanged(inn: $inn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InnChangedImpl &&
            (identical(other.inn, inn) || other.inn == inn));
  }

  @override
  int get hashCode => Object.hash(runtimeType, inn);

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InnChangedImplCopyWith<_$InnChangedImpl> get copyWith =>
      __$$InnChangedImplCopyWithImpl<_$InnChangedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DriverMainType type) selectMainType,
    required TResult Function(DriverLegalType type) selectLegalType,
    required TResult Function(String inn) innChanged,
    required TResult Function() verifyInn,
    required TResult Function() continuePressed,
  }) {
    return innChanged(inn);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DriverMainType type)? selectMainType,
    TResult? Function(DriverLegalType type)? selectLegalType,
    TResult? Function(String inn)? innChanged,
    TResult? Function()? verifyInn,
    TResult? Function()? continuePressed,
  }) {
    return innChanged?.call(inn);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DriverMainType type)? selectMainType,
    TResult Function(DriverLegalType type)? selectLegalType,
    TResult Function(String inn)? innChanged,
    TResult Function()? verifyInn,
    TResult Function()? continuePressed,
    required TResult orElse(),
  }) {
    if (innChanged != null) {
      return innChanged(inn);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SelectMainType value) selectMainType,
    required TResult Function(_SelectLegalType value) selectLegalType,
    required TResult Function(_InnChanged value) innChanged,
    required TResult Function(_VerifyInn value) verifyInn,
    required TResult Function(_ContinuePressed value) continuePressed,
  }) {
    return innChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SelectMainType value)? selectMainType,
    TResult? Function(_SelectLegalType value)? selectLegalType,
    TResult? Function(_InnChanged value)? innChanged,
    TResult? Function(_VerifyInn value)? verifyInn,
    TResult? Function(_ContinuePressed value)? continuePressed,
  }) {
    return innChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SelectMainType value)? selectMainType,
    TResult Function(_SelectLegalType value)? selectLegalType,
    TResult Function(_InnChanged value)? innChanged,
    TResult Function(_VerifyInn value)? verifyInn,
    TResult Function(_ContinuePressed value)? continuePressed,
    required TResult orElse(),
  }) {
    if (innChanged != null) {
      return innChanged(this);
    }
    return orElse();
  }
}

abstract class _InnChanged implements DriverTypeEvent {
  const factory _InnChanged(final String inn) = _$InnChangedImpl;

  String get inn;

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InnChangedImplCopyWith<_$InnChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VerifyInnImplCopyWith<$Res> {
  factory _$$VerifyInnImplCopyWith(
          _$VerifyInnImpl value, $Res Function(_$VerifyInnImpl) then) =
      __$$VerifyInnImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VerifyInnImplCopyWithImpl<$Res>
    extends _$DriverTypeEventCopyWithImpl<$Res, _$VerifyInnImpl>
    implements _$$VerifyInnImplCopyWith<$Res> {
  __$$VerifyInnImplCopyWithImpl(
      _$VerifyInnImpl _value, $Res Function(_$VerifyInnImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$VerifyInnImpl implements _VerifyInn {
  const _$VerifyInnImpl();

  @override
  String toString() {
    return 'DriverTypeEvent.verifyInn()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$VerifyInnImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DriverMainType type) selectMainType,
    required TResult Function(DriverLegalType type) selectLegalType,
    required TResult Function(String inn) innChanged,
    required TResult Function() verifyInn,
    required TResult Function() continuePressed,
  }) {
    return verifyInn();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DriverMainType type)? selectMainType,
    TResult? Function(DriverLegalType type)? selectLegalType,
    TResult? Function(String inn)? innChanged,
    TResult? Function()? verifyInn,
    TResult? Function()? continuePressed,
  }) {
    return verifyInn?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DriverMainType type)? selectMainType,
    TResult Function(DriverLegalType type)? selectLegalType,
    TResult Function(String inn)? innChanged,
    TResult Function()? verifyInn,
    TResult Function()? continuePressed,
    required TResult orElse(),
  }) {
    if (verifyInn != null) {
      return verifyInn();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SelectMainType value) selectMainType,
    required TResult Function(_SelectLegalType value) selectLegalType,
    required TResult Function(_InnChanged value) innChanged,
    required TResult Function(_VerifyInn value) verifyInn,
    required TResult Function(_ContinuePressed value) continuePressed,
  }) {
    return verifyInn(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SelectMainType value)? selectMainType,
    TResult? Function(_SelectLegalType value)? selectLegalType,
    TResult? Function(_InnChanged value)? innChanged,
    TResult? Function(_VerifyInn value)? verifyInn,
    TResult? Function(_ContinuePressed value)? continuePressed,
  }) {
    return verifyInn?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SelectMainType value)? selectMainType,
    TResult Function(_SelectLegalType value)? selectLegalType,
    TResult Function(_InnChanged value)? innChanged,
    TResult Function(_VerifyInn value)? verifyInn,
    TResult Function(_ContinuePressed value)? continuePressed,
    required TResult orElse(),
  }) {
    if (verifyInn != null) {
      return verifyInn(this);
    }
    return orElse();
  }
}

abstract class _VerifyInn implements DriverTypeEvent {
  const factory _VerifyInn() = _$VerifyInnImpl;
}

/// @nodoc
abstract class _$$ContinuePressedImplCopyWith<$Res> {
  factory _$$ContinuePressedImplCopyWith(_$ContinuePressedImpl value,
          $Res Function(_$ContinuePressedImpl) then) =
      __$$ContinuePressedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ContinuePressedImplCopyWithImpl<$Res>
    extends _$DriverTypeEventCopyWithImpl<$Res, _$ContinuePressedImpl>
    implements _$$ContinuePressedImplCopyWith<$Res> {
  __$$ContinuePressedImplCopyWithImpl(
      _$ContinuePressedImpl _value, $Res Function(_$ContinuePressedImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ContinuePressedImpl implements _ContinuePressed {
  const _$ContinuePressedImpl();

  @override
  String toString() {
    return 'DriverTypeEvent.continuePressed()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ContinuePressedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DriverMainType type) selectMainType,
    required TResult Function(DriverLegalType type) selectLegalType,
    required TResult Function(String inn) innChanged,
    required TResult Function() verifyInn,
    required TResult Function() continuePressed,
  }) {
    return continuePressed();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DriverMainType type)? selectMainType,
    TResult? Function(DriverLegalType type)? selectLegalType,
    TResult? Function(String inn)? innChanged,
    TResult? Function()? verifyInn,
    TResult? Function()? continuePressed,
  }) {
    return continuePressed?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DriverMainType type)? selectMainType,
    TResult Function(DriverLegalType type)? selectLegalType,
    TResult Function(String inn)? innChanged,
    TResult Function()? verifyInn,
    TResult Function()? continuePressed,
    required TResult orElse(),
  }) {
    if (continuePressed != null) {
      return continuePressed();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_SelectMainType value) selectMainType,
    required TResult Function(_SelectLegalType value) selectLegalType,
    required TResult Function(_InnChanged value) innChanged,
    required TResult Function(_VerifyInn value) verifyInn,
    required TResult Function(_ContinuePressed value) continuePressed,
  }) {
    return continuePressed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_SelectMainType value)? selectMainType,
    TResult? Function(_SelectLegalType value)? selectLegalType,
    TResult? Function(_InnChanged value)? innChanged,
    TResult? Function(_VerifyInn value)? verifyInn,
    TResult? Function(_ContinuePressed value)? continuePressed,
  }) {
    return continuePressed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_SelectMainType value)? selectMainType,
    TResult Function(_SelectLegalType value)? selectLegalType,
    TResult Function(_InnChanged value)? innChanged,
    TResult Function(_VerifyInn value)? verifyInn,
    TResult Function(_ContinuePressed value)? continuePressed,
    required TResult orElse(),
  }) {
    if (continuePressed != null) {
      return continuePressed(this);
    }
    return orElse();
  }
}

abstract class _ContinuePressed implements DriverTypeEvent {
  const factory _ContinuePressed() = _$ContinuePressedImpl;
}

/// @nodoc
mixin _$DriverTypeState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)
        loading,
    required TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)
        ready,
    required TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)
        error,
    required TResult Function() submitting,
    required TResult Function(int commissionPercent) successfulSubmission,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)?
        loading,
    TResult? Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult? Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult? Function()? submitting,
    TResult? Function(int commissionPercent)? successfulSubmission,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DriverMainType selectedMain, DriverLegalType selectedLegal,
            String inn)?
        loading,
    TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult Function()? submitting,
    TResult Function(int commissionPercent)? successfulSubmission,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Ready value) ready,
    required TResult Function(_Error value) error,
    required TResult Function(_Submitting value) submitting,
    required TResult Function(_SuccessfulSubmission value) successfulSubmission,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Error value)? error,
    TResult? Function(_Submitting value)? submitting,
    TResult? Function(_SuccessfulSubmission value)? successfulSubmission,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Ready value)? ready,
    TResult Function(_Error value)? error,
    TResult Function(_Submitting value)? submitting,
    TResult Function(_SuccessfulSubmission value)? successfulSubmission,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriverTypeStateCopyWith<$Res> {
  factory $DriverTypeStateCopyWith(
          DriverTypeState value, $Res Function(DriverTypeState) then) =
      _$DriverTypeStateCopyWithImpl<$Res, DriverTypeState>;
}

/// @nodoc
class _$DriverTypeStateCopyWithImpl<$Res, $Val extends DriverTypeState>
    implements $DriverTypeStateCopyWith<$Res> {
  _$DriverTypeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriverTypeState
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
    extends _$DriverTypeStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'DriverTypeState.initial()';
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
    required TResult Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)
        loading,
    required TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)
        ready,
    required TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)
        error,
    required TResult Function() submitting,
    required TResult Function(int commissionPercent) successfulSubmission,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)?
        loading,
    TResult? Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult? Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult? Function()? submitting,
    TResult? Function(int commissionPercent)? successfulSubmission,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DriverMainType selectedMain, DriverLegalType selectedLegal,
            String inn)?
        loading,
    TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult Function()? submitting,
    TResult Function(int commissionPercent)? successfulSubmission,
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
    required TResult Function(_Ready value) ready,
    required TResult Function(_Error value) error,
    required TResult Function(_Submitting value) submitting,
    required TResult Function(_SuccessfulSubmission value) successfulSubmission,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Error value)? error,
    TResult? Function(_Submitting value)? submitting,
    TResult? Function(_SuccessfulSubmission value)? successfulSubmission,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Ready value)? ready,
    TResult Function(_Error value)? error,
    TResult Function(_Submitting value)? submitting,
    TResult Function(_SuccessfulSubmission value)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements DriverTypeState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {DriverMainType selectedMain, DriverLegalType selectedLegal, String inn});
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$DriverTypeStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedMain = null,
    Object? selectedLegal = null,
    Object? inn = null,
  }) {
    return _then(_$LoadingImpl(
      selectedMain: null == selectedMain
          ? _value.selectedMain
          : selectedMain // ignore: cast_nullable_to_non_nullable
              as DriverMainType,
      selectedLegal: null == selectedLegal
          ? _value.selectedLegal
          : selectedLegal // ignore: cast_nullable_to_non_nullable
              as DriverLegalType,
      inn: null == inn
          ? _value.inn
          : inn // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl(
      {required this.selectedMain,
      required this.selectedLegal,
      required this.inn});

  @override
  final DriverMainType selectedMain;
  @override
  final DriverLegalType selectedLegal;
  @override
  final String inn;

  @override
  String toString() {
    return 'DriverTypeState.loading(selectedMain: $selectedMain, selectedLegal: $selectedLegal, inn: $inn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadingImpl &&
            (identical(other.selectedMain, selectedMain) ||
                other.selectedMain == selectedMain) &&
            (identical(other.selectedLegal, selectedLegal) ||
                other.selectedLegal == selectedLegal) &&
            (identical(other.inn, inn) || other.inn == inn));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, selectedMain, selectedLegal, inn);

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadingImplCopyWith<_$LoadingImpl> get copyWith =>
      __$$LoadingImplCopyWithImpl<_$LoadingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)
        loading,
    required TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)
        ready,
    required TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)
        error,
    required TResult Function() submitting,
    required TResult Function(int commissionPercent) successfulSubmission,
  }) {
    return loading(selectedMain, selectedLegal, inn);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)?
        loading,
    TResult? Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult? Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult? Function()? submitting,
    TResult? Function(int commissionPercent)? successfulSubmission,
  }) {
    return loading?.call(selectedMain, selectedLegal, inn);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DriverMainType selectedMain, DriverLegalType selectedLegal,
            String inn)?
        loading,
    TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult Function()? submitting,
    TResult Function(int commissionPercent)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(selectedMain, selectedLegal, inn);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Ready value) ready,
    required TResult Function(_Error value) error,
    required TResult Function(_Submitting value) submitting,
    required TResult Function(_SuccessfulSubmission value) successfulSubmission,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Error value)? error,
    TResult? Function(_Submitting value)? submitting,
    TResult? Function(_SuccessfulSubmission value)? successfulSubmission,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Ready value)? ready,
    TResult Function(_Error value)? error,
    TResult Function(_Submitting value)? submitting,
    TResult Function(_SuccessfulSubmission value)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements DriverTypeState {
  const factory _Loading(
      {required final DriverMainType selectedMain,
      required final DriverLegalType selectedLegal,
      required final String inn}) = _$LoadingImpl;

  DriverMainType get selectedMain;
  DriverLegalType get selectedLegal;
  String get inn;

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadingImplCopyWith<_$LoadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReadyImplCopyWith<$Res> {
  factory _$$ReadyImplCopyWith(
          _$ReadyImpl value, $Res Function(_$ReadyImpl) then) =
      __$$ReadyImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {DriverMainType selectedMain,
      DriverLegalType selectedLegal,
      String inn,
      bool isInnValid,
      String? innMessage,
      bool continueEnabled,
      double commissionPercent});
}

/// @nodoc
class __$$ReadyImplCopyWithImpl<$Res>
    extends _$DriverTypeStateCopyWithImpl<$Res, _$ReadyImpl>
    implements _$$ReadyImplCopyWith<$Res> {
  __$$ReadyImplCopyWithImpl(
      _$ReadyImpl _value, $Res Function(_$ReadyImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedMain = null,
    Object? selectedLegal = null,
    Object? inn = null,
    Object? isInnValid = null,
    Object? innMessage = freezed,
    Object? continueEnabled = null,
    Object? commissionPercent = null,
  }) {
    return _then(_$ReadyImpl(
      selectedMain: null == selectedMain
          ? _value.selectedMain
          : selectedMain // ignore: cast_nullable_to_non_nullable
              as DriverMainType,
      selectedLegal: null == selectedLegal
          ? _value.selectedLegal
          : selectedLegal // ignore: cast_nullable_to_non_nullable
              as DriverLegalType,
      inn: null == inn
          ? _value.inn
          : inn // ignore: cast_nullable_to_non_nullable
              as String,
      isInnValid: null == isInnValid
          ? _value.isInnValid
          : isInnValid // ignore: cast_nullable_to_non_nullable
              as bool,
      innMessage: freezed == innMessage
          ? _value.innMessage
          : innMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      continueEnabled: null == continueEnabled
          ? _value.continueEnabled
          : continueEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      commissionPercent: null == commissionPercent
          ? _value.commissionPercent
          : commissionPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$ReadyImpl implements _Ready {
  const _$ReadyImpl(
      {required this.selectedMain,
      required this.selectedLegal,
      required this.inn,
      required this.isInnValid,
      required this.innMessage,
      required this.continueEnabled,
      required this.commissionPercent});

  @override
  final DriverMainType selectedMain;
  @override
  final DriverLegalType selectedLegal;
  @override
  final String inn;
  @override
  final bool isInnValid;
  @override
  final String? innMessage;
  @override
  final bool continueEnabled;
  @override
  final double commissionPercent;

  @override
  String toString() {
    return 'DriverTypeState.ready(selectedMain: $selectedMain, selectedLegal: $selectedLegal, inn: $inn, isInnValid: $isInnValid, innMessage: $innMessage, continueEnabled: $continueEnabled, commissionPercent: $commissionPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadyImpl &&
            (identical(other.selectedMain, selectedMain) ||
                other.selectedMain == selectedMain) &&
            (identical(other.selectedLegal, selectedLegal) ||
                other.selectedLegal == selectedLegal) &&
            (identical(other.inn, inn) || other.inn == inn) &&
            (identical(other.isInnValid, isInnValid) ||
                other.isInnValid == isInnValid) &&
            (identical(other.innMessage, innMessage) ||
                other.innMessage == innMessage) &&
            (identical(other.continueEnabled, continueEnabled) ||
                other.continueEnabled == continueEnabled) &&
            (identical(other.commissionPercent, commissionPercent) ||
                other.commissionPercent == commissionPercent));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedMain, selectedLegal, inn,
      isInnValid, innMessage, continueEnabled, commissionPercent);

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadyImplCopyWith<_$ReadyImpl> get copyWith =>
      __$$ReadyImplCopyWithImpl<_$ReadyImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)
        loading,
    required TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)
        ready,
    required TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)
        error,
    required TResult Function() submitting,
    required TResult Function(int commissionPercent) successfulSubmission,
  }) {
    return ready(selectedMain, selectedLegal, inn, isInnValid, innMessage,
        continueEnabled, commissionPercent);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)?
        loading,
    TResult? Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult? Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult? Function()? submitting,
    TResult? Function(int commissionPercent)? successfulSubmission,
  }) {
    return ready?.call(selectedMain, selectedLegal, inn, isInnValid, innMessage,
        continueEnabled, commissionPercent);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DriverMainType selectedMain, DriverLegalType selectedLegal,
            String inn)?
        loading,
    TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult Function()? submitting,
    TResult Function(int commissionPercent)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready(selectedMain, selectedLegal, inn, isInnValid, innMessage,
          continueEnabled, commissionPercent);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Ready value) ready,
    required TResult Function(_Error value) error,
    required TResult Function(_Submitting value) submitting,
    required TResult Function(_SuccessfulSubmission value) successfulSubmission,
  }) {
    return ready(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Error value)? error,
    TResult? Function(_Submitting value)? submitting,
    TResult? Function(_SuccessfulSubmission value)? successfulSubmission,
  }) {
    return ready?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Ready value)? ready,
    TResult Function(_Error value)? error,
    TResult Function(_Submitting value)? submitting,
    TResult Function(_SuccessfulSubmission value)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (ready != null) {
      return ready(this);
    }
    return orElse();
  }
}

abstract class _Ready implements DriverTypeState {
  const factory _Ready(
      {required final DriverMainType selectedMain,
      required final DriverLegalType selectedLegal,
      required final String inn,
      required final bool isInnValid,
      required final String? innMessage,
      required final bool continueEnabled,
      required final double commissionPercent}) = _$ReadyImpl;

  DriverMainType get selectedMain;
  DriverLegalType get selectedLegal;
  String get inn;
  bool get isInnValid;
  String? get innMessage;
  bool get continueEnabled;
  double get commissionPercent;

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReadyImplCopyWith<_$ReadyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String message,
      DriverMainType selectedMain,
      DriverLegalType selectedLegal,
      String inn,
      bool isInnValid,
      double commissionPercent});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$DriverTypeStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? selectedMain = null,
    Object? selectedLegal = null,
    Object? inn = null,
    Object? isInnValid = null,
    Object? commissionPercent = null,
  }) {
    return _then(_$ErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      selectedMain: null == selectedMain
          ? _value.selectedMain
          : selectedMain // ignore: cast_nullable_to_non_nullable
              as DriverMainType,
      selectedLegal: null == selectedLegal
          ? _value.selectedLegal
          : selectedLegal // ignore: cast_nullable_to_non_nullable
              as DriverLegalType,
      inn: null == inn
          ? _value.inn
          : inn // ignore: cast_nullable_to_non_nullable
              as String,
      isInnValid: null == isInnValid
          ? _value.isInnValid
          : isInnValid // ignore: cast_nullable_to_non_nullable
              as bool,
      commissionPercent: null == commissionPercent
          ? _value.commissionPercent
          : commissionPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(
      {required this.message,
      required this.selectedMain,
      required this.selectedLegal,
      required this.inn,
      required this.isInnValid,
      required this.commissionPercent});

  @override
  final String message;
  @override
  final DriverMainType selectedMain;
  @override
  final DriverLegalType selectedLegal;
  @override
  final String inn;
  @override
  final bool isInnValid;
  @override
  final double commissionPercent;

  @override
  String toString() {
    return 'DriverTypeState.error(message: $message, selectedMain: $selectedMain, selectedLegal: $selectedLegal, inn: $inn, isInnValid: $isInnValid, commissionPercent: $commissionPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.selectedMain, selectedMain) ||
                other.selectedMain == selectedMain) &&
            (identical(other.selectedLegal, selectedLegal) ||
                other.selectedLegal == selectedLegal) &&
            (identical(other.inn, inn) || other.inn == inn) &&
            (identical(other.isInnValid, isInnValid) ||
                other.isInnValid == isInnValid) &&
            (identical(other.commissionPercent, commissionPercent) ||
                other.commissionPercent == commissionPercent));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, selectedMain,
      selectedLegal, inn, isInnValid, commissionPercent);

  /// Create a copy of DriverTypeState
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
    required TResult Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)
        loading,
    required TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)
        ready,
    required TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)
        error,
    required TResult Function() submitting,
    required TResult Function(int commissionPercent) successfulSubmission,
  }) {
    return error(message, selectedMain, selectedLegal, inn, isInnValid,
        commissionPercent);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)?
        loading,
    TResult? Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult? Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult? Function()? submitting,
    TResult? Function(int commissionPercent)? successfulSubmission,
  }) {
    return error?.call(message, selectedMain, selectedLegal, inn, isInnValid,
        commissionPercent);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DriverMainType selectedMain, DriverLegalType selectedLegal,
            String inn)?
        loading,
    TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult Function()? submitting,
    TResult Function(int commissionPercent)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, selectedMain, selectedLegal, inn, isInnValid,
          commissionPercent);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Ready value) ready,
    required TResult Function(_Error value) error,
    required TResult Function(_Submitting value) submitting,
    required TResult Function(_SuccessfulSubmission value) successfulSubmission,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Error value)? error,
    TResult? Function(_Submitting value)? submitting,
    TResult? Function(_SuccessfulSubmission value)? successfulSubmission,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Ready value)? ready,
    TResult Function(_Error value)? error,
    TResult Function(_Submitting value)? submitting,
    TResult Function(_SuccessfulSubmission value)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements DriverTypeState {
  const factory _Error(
      {required final String message,
      required final DriverMainType selectedMain,
      required final DriverLegalType selectedLegal,
      required final String inn,
      required final bool isInnValid,
      required final double commissionPercent}) = _$ErrorImpl;

  String get message;
  DriverMainType get selectedMain;
  DriverLegalType get selectedLegal;
  String get inn;
  bool get isInnValid;
  double get commissionPercent;

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SubmittingImplCopyWith<$Res> {
  factory _$$SubmittingImplCopyWith(
          _$SubmittingImpl value, $Res Function(_$SubmittingImpl) then) =
      __$$SubmittingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubmittingImplCopyWithImpl<$Res>
    extends _$DriverTypeStateCopyWithImpl<$Res, _$SubmittingImpl>
    implements _$$SubmittingImplCopyWith<$Res> {
  __$$SubmittingImplCopyWithImpl(
      _$SubmittingImpl _value, $Res Function(_$SubmittingImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SubmittingImpl implements _Submitting {
  const _$SubmittingImpl();

  @override
  String toString() {
    return 'DriverTypeState.submitting()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SubmittingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)
        loading,
    required TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)
        ready,
    required TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)
        error,
    required TResult Function() submitting,
    required TResult Function(int commissionPercent) successfulSubmission,
  }) {
    return submitting();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)?
        loading,
    TResult? Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult? Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult? Function()? submitting,
    TResult? Function(int commissionPercent)? successfulSubmission,
  }) {
    return submitting?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DriverMainType selectedMain, DriverLegalType selectedLegal,
            String inn)?
        loading,
    TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult Function()? submitting,
    TResult Function(int commissionPercent)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Ready value) ready,
    required TResult Function(_Error value) error,
    required TResult Function(_Submitting value) submitting,
    required TResult Function(_SuccessfulSubmission value) successfulSubmission,
  }) {
    return submitting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Error value)? error,
    TResult? Function(_Submitting value)? submitting,
    TResult? Function(_SuccessfulSubmission value)? successfulSubmission,
  }) {
    return submitting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Ready value)? ready,
    TResult Function(_Error value)? error,
    TResult Function(_Submitting value)? submitting,
    TResult Function(_SuccessfulSubmission value)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting(this);
    }
    return orElse();
  }
}

abstract class _Submitting implements DriverTypeState {
  const factory _Submitting() = _$SubmittingImpl;
}

/// @nodoc
abstract class _$$SuccessfulSubmissionImplCopyWith<$Res> {
  factory _$$SuccessfulSubmissionImplCopyWith(_$SuccessfulSubmissionImpl value,
          $Res Function(_$SuccessfulSubmissionImpl) then) =
      __$$SuccessfulSubmissionImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int commissionPercent});
}

/// @nodoc
class __$$SuccessfulSubmissionImplCopyWithImpl<$Res>
    extends _$DriverTypeStateCopyWithImpl<$Res, _$SuccessfulSubmissionImpl>
    implements _$$SuccessfulSubmissionImplCopyWith<$Res> {
  __$$SuccessfulSubmissionImplCopyWithImpl(_$SuccessfulSubmissionImpl _value,
      $Res Function(_$SuccessfulSubmissionImpl) _then)
      : super(_value, _then);

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? commissionPercent = null,
  }) {
    return _then(_$SuccessfulSubmissionImpl(
      null == commissionPercent
          ? _value.commissionPercent
          : commissionPercent // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SuccessfulSubmissionImpl implements _SuccessfulSubmission {
  const _$SuccessfulSubmissionImpl(this.commissionPercent);

  @override
  final int commissionPercent;

  @override
  String toString() {
    return 'DriverTypeState.successfulSubmission(commissionPercent: $commissionPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessfulSubmissionImpl &&
            (identical(other.commissionPercent, commissionPercent) ||
                other.commissionPercent == commissionPercent));
  }

  @override
  int get hashCode => Object.hash(runtimeType, commissionPercent);

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessfulSubmissionImplCopyWith<_$SuccessfulSubmissionImpl>
      get copyWith =>
          __$$SuccessfulSubmissionImplCopyWithImpl<_$SuccessfulSubmissionImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)
        loading,
    required TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)
        ready,
    required TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)
        error,
    required TResult Function() submitting,
    required TResult Function(int commissionPercent) successfulSubmission,
  }) {
    return successfulSubmission(commissionPercent);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DriverMainType selectedMain,
            DriverLegalType selectedLegal, String inn)?
        loading,
    TResult? Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult? Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult? Function()? submitting,
    TResult? Function(int commissionPercent)? successfulSubmission,
  }) {
    return successfulSubmission?.call(commissionPercent);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DriverMainType selectedMain, DriverLegalType selectedLegal,
            String inn)?
        loading,
    TResult Function(
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            String? innMessage,
            bool continueEnabled,
            double commissionPercent)?
        ready,
    TResult Function(
            String message,
            DriverMainType selectedMain,
            DriverLegalType selectedLegal,
            String inn,
            bool isInnValid,
            double commissionPercent)?
        error,
    TResult Function()? submitting,
    TResult Function(int commissionPercent)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (successfulSubmission != null) {
      return successfulSubmission(commissionPercent);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Ready value) ready,
    required TResult Function(_Error value) error,
    required TResult Function(_Submitting value) submitting,
    required TResult Function(_SuccessfulSubmission value) successfulSubmission,
  }) {
    return successfulSubmission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Ready value)? ready,
    TResult? Function(_Error value)? error,
    TResult? Function(_Submitting value)? submitting,
    TResult? Function(_SuccessfulSubmission value)? successfulSubmission,
  }) {
    return successfulSubmission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Ready value)? ready,
    TResult Function(_Error value)? error,
    TResult Function(_Submitting value)? submitting,
    TResult Function(_SuccessfulSubmission value)? successfulSubmission,
    required TResult orElse(),
  }) {
    if (successfulSubmission != null) {
      return successfulSubmission(this);
    }
    return orElse();
  }
}

abstract class _SuccessfulSubmission implements DriverTypeState {
  const factory _SuccessfulSubmission(final int commissionPercent) =
      _$SuccessfulSubmissionImpl;

  int get commissionPercent;

  /// Create a copy of DriverTypeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessfulSubmissionImplCopyWith<_$SuccessfulSubmissionImpl>
      get copyWith => throw _privateConstructorUsedError;
}
