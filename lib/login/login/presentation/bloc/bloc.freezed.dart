// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) pop,
    required TResult Function() sendCode,
    required TResult Function() resendCode,
    required TResult Function(dynamic Function(AuthUser)? onSuccess)
        confirmCode,
    required TResult Function() sendFcmToken,
    required TResult Function(String number) sendResetCode,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? pop,
    TResult? Function()? sendCode,
    TResult? Function()? resendCode,
    TResult? Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult? Function()? sendFcmToken,
    TResult? Function(String number)? sendResetCode,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? pop,
    TResult Function()? sendCode,
    TResult Function()? resendCode,
    TResult Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult Function()? sendFcmToken,
    TResult Function(String number)? sendResetCode,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Pop value) pop,
    required TResult Function(_SendCode value) sendCode,
    required TResult Function(_ResendCode value) resendCode,
    required TResult Function(_ConfirmCode value) confirmCode,
    required TResult Function(_SendFcmToken value) sendFcmToken,
    required TResult Function(_SendResetCode value) sendResetCode,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Pop value)? pop,
    TResult? Function(_SendCode value)? sendCode,
    TResult? Function(_ResendCode value)? resendCode,
    TResult? Function(_ConfirmCode value)? confirmCode,
    TResult? Function(_SendFcmToken value)? sendFcmToken,
    TResult? Function(_SendResetCode value)? sendResetCode,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Pop value)? pop,
    TResult Function(_SendCode value)? sendCode,
    TResult Function(_ResendCode value)? resendCode,
    TResult Function(_ConfirmCode value)? confirmCode,
    TResult Function(_SendFcmToken value)? sendFcmToken,
    TResult Function(_SendResetCode value)? sendResetCode,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthEventCopyWith<$Res> {
  factory $AuthEventCopyWith(AuthEvent value, $Res Function(AuthEvent) then) =
      _$AuthEventCopyWithImpl<$Res, AuthEvent>;
}

/// @nodoc
class _$AuthEventCopyWithImpl<$Res, $Val extends AuthEvent>
    implements $AuthEventCopyWith<$Res> {
  _$AuthEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$PopImplCopyWith<$Res> {
  factory _$$PopImplCopyWith(_$PopImpl value, $Res Function(_$PopImpl) then) =
      __$$PopImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BuildContext context});
}

/// @nodoc
class __$$PopImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$PopImpl>
    implements _$$PopImplCopyWith<$Res> {
  __$$PopImplCopyWithImpl(_$PopImpl _value, $Res Function(_$PopImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
  }) {
    return _then(_$PopImpl(
      null == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as BuildContext,
    ));
  }
}

/// @nodoc

class _$PopImpl implements _Pop {
  const _$PopImpl(this.context);

  @override
  final BuildContext context;

  @override
  String toString() {
    return 'AuthEvent.pop(context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PopImpl &&
            (identical(other.context, context) || other.context == context));
  }

  @override
  int get hashCode => Object.hash(runtimeType, context);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PopImplCopyWith<_$PopImpl> get copyWith =>
      __$$PopImplCopyWithImpl<_$PopImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) pop,
    required TResult Function() sendCode,
    required TResult Function() resendCode,
    required TResult Function(dynamic Function(AuthUser)? onSuccess)
        confirmCode,
    required TResult Function() sendFcmToken,
    required TResult Function(String number) sendResetCode,
  }) {
    return pop(context);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? pop,
    TResult? Function()? sendCode,
    TResult? Function()? resendCode,
    TResult? Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult? Function()? sendFcmToken,
    TResult? Function(String number)? sendResetCode,
  }) {
    return pop?.call(context);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? pop,
    TResult Function()? sendCode,
    TResult Function()? resendCode,
    TResult Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult Function()? sendFcmToken,
    TResult Function(String number)? sendResetCode,
    required TResult orElse(),
  }) {
    if (pop != null) {
      return pop(context);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Pop value) pop,
    required TResult Function(_SendCode value) sendCode,
    required TResult Function(_ResendCode value) resendCode,
    required TResult Function(_ConfirmCode value) confirmCode,
    required TResult Function(_SendFcmToken value) sendFcmToken,
    required TResult Function(_SendResetCode value) sendResetCode,
  }) {
    return pop(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Pop value)? pop,
    TResult? Function(_SendCode value)? sendCode,
    TResult? Function(_ResendCode value)? resendCode,
    TResult? Function(_ConfirmCode value)? confirmCode,
    TResult? Function(_SendFcmToken value)? sendFcmToken,
    TResult? Function(_SendResetCode value)? sendResetCode,
  }) {
    return pop?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Pop value)? pop,
    TResult Function(_SendCode value)? sendCode,
    TResult Function(_ResendCode value)? resendCode,
    TResult Function(_ConfirmCode value)? confirmCode,
    TResult Function(_SendFcmToken value)? sendFcmToken,
    TResult Function(_SendResetCode value)? sendResetCode,
    required TResult orElse(),
  }) {
    if (pop != null) {
      return pop(this);
    }
    return orElse();
  }
}

abstract class _Pop implements AuthEvent {
  const factory _Pop(final BuildContext context) = _$PopImpl;

  BuildContext get context;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PopImplCopyWith<_$PopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SendCodeImplCopyWith<$Res> {
  factory _$$SendCodeImplCopyWith(
          _$SendCodeImpl value, $Res Function(_$SendCodeImpl) then) =
      __$$SendCodeImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SendCodeImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SendCodeImpl>
    implements _$$SendCodeImplCopyWith<$Res> {
  __$$SendCodeImplCopyWithImpl(
      _$SendCodeImpl _value, $Res Function(_$SendCodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SendCodeImpl implements _SendCode {
  const _$SendCodeImpl();

  @override
  String toString() {
    return 'AuthEvent.sendCode()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SendCodeImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) pop,
    required TResult Function() sendCode,
    required TResult Function() resendCode,
    required TResult Function(dynamic Function(AuthUser)? onSuccess)
        confirmCode,
    required TResult Function() sendFcmToken,
    required TResult Function(String number) sendResetCode,
  }) {
    return sendCode();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? pop,
    TResult? Function()? sendCode,
    TResult? Function()? resendCode,
    TResult? Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult? Function()? sendFcmToken,
    TResult? Function(String number)? sendResetCode,
  }) {
    return sendCode?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? pop,
    TResult Function()? sendCode,
    TResult Function()? resendCode,
    TResult Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult Function()? sendFcmToken,
    TResult Function(String number)? sendResetCode,
    required TResult orElse(),
  }) {
    if (sendCode != null) {
      return sendCode();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Pop value) pop,
    required TResult Function(_SendCode value) sendCode,
    required TResult Function(_ResendCode value) resendCode,
    required TResult Function(_ConfirmCode value) confirmCode,
    required TResult Function(_SendFcmToken value) sendFcmToken,
    required TResult Function(_SendResetCode value) sendResetCode,
  }) {
    return sendCode(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Pop value)? pop,
    TResult? Function(_SendCode value)? sendCode,
    TResult? Function(_ResendCode value)? resendCode,
    TResult? Function(_ConfirmCode value)? confirmCode,
    TResult? Function(_SendFcmToken value)? sendFcmToken,
    TResult? Function(_SendResetCode value)? sendResetCode,
  }) {
    return sendCode?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Pop value)? pop,
    TResult Function(_SendCode value)? sendCode,
    TResult Function(_ResendCode value)? resendCode,
    TResult Function(_ConfirmCode value)? confirmCode,
    TResult Function(_SendFcmToken value)? sendFcmToken,
    TResult Function(_SendResetCode value)? sendResetCode,
    required TResult orElse(),
  }) {
    if (sendCode != null) {
      return sendCode(this);
    }
    return orElse();
  }
}

abstract class _SendCode implements AuthEvent {
  const factory _SendCode() = _$SendCodeImpl;
}

/// @nodoc
abstract class _$$ResendCodeImplCopyWith<$Res> {
  factory _$$ResendCodeImplCopyWith(
          _$ResendCodeImpl value, $Res Function(_$ResendCodeImpl) then) =
      __$$ResendCodeImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ResendCodeImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$ResendCodeImpl>
    implements _$$ResendCodeImplCopyWith<$Res> {
  __$$ResendCodeImplCopyWithImpl(
      _$ResendCodeImpl _value, $Res Function(_$ResendCodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ResendCodeImpl implements _ResendCode {
  const _$ResendCodeImpl();

  @override
  String toString() {
    return 'AuthEvent.resendCode()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ResendCodeImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) pop,
    required TResult Function() sendCode,
    required TResult Function() resendCode,
    required TResult Function(dynamic Function(AuthUser)? onSuccess)
        confirmCode,
    required TResult Function() sendFcmToken,
    required TResult Function(String number) sendResetCode,
  }) {
    return resendCode();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? pop,
    TResult? Function()? sendCode,
    TResult? Function()? resendCode,
    TResult? Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult? Function()? sendFcmToken,
    TResult? Function(String number)? sendResetCode,
  }) {
    return resendCode?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? pop,
    TResult Function()? sendCode,
    TResult Function()? resendCode,
    TResult Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult Function()? sendFcmToken,
    TResult Function(String number)? sendResetCode,
    required TResult orElse(),
  }) {
    if (resendCode != null) {
      return resendCode();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Pop value) pop,
    required TResult Function(_SendCode value) sendCode,
    required TResult Function(_ResendCode value) resendCode,
    required TResult Function(_ConfirmCode value) confirmCode,
    required TResult Function(_SendFcmToken value) sendFcmToken,
    required TResult Function(_SendResetCode value) sendResetCode,
  }) {
    return resendCode(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Pop value)? pop,
    TResult? Function(_SendCode value)? sendCode,
    TResult? Function(_ResendCode value)? resendCode,
    TResult? Function(_ConfirmCode value)? confirmCode,
    TResult? Function(_SendFcmToken value)? sendFcmToken,
    TResult? Function(_SendResetCode value)? sendResetCode,
  }) {
    return resendCode?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Pop value)? pop,
    TResult Function(_SendCode value)? sendCode,
    TResult Function(_ResendCode value)? resendCode,
    TResult Function(_ConfirmCode value)? confirmCode,
    TResult Function(_SendFcmToken value)? sendFcmToken,
    TResult Function(_SendResetCode value)? sendResetCode,
    required TResult orElse(),
  }) {
    if (resendCode != null) {
      return resendCode(this);
    }
    return orElse();
  }
}

abstract class _ResendCode implements AuthEvent {
  const factory _ResendCode() = _$ResendCodeImpl;
}

/// @nodoc
abstract class _$$ConfirmCodeImplCopyWith<$Res> {
  factory _$$ConfirmCodeImplCopyWith(
          _$ConfirmCodeImpl value, $Res Function(_$ConfirmCodeImpl) then) =
      __$$ConfirmCodeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({dynamic Function(AuthUser)? onSuccess});
}

/// @nodoc
class __$$ConfirmCodeImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$ConfirmCodeImpl>
    implements _$$ConfirmCodeImplCopyWith<$Res> {
  __$$ConfirmCodeImplCopyWithImpl(
      _$ConfirmCodeImpl _value, $Res Function(_$ConfirmCodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? onSuccess = freezed,
  }) {
    return _then(_$ConfirmCodeImpl(
      onSuccess: freezed == onSuccess
          ? _value.onSuccess
          : onSuccess // ignore: cast_nullable_to_non_nullable
              as dynamic Function(AuthUser)?,
    ));
  }
}

/// @nodoc

class _$ConfirmCodeImpl implements _ConfirmCode {
  const _$ConfirmCodeImpl({this.onSuccess});

  @override
  final dynamic Function(AuthUser)? onSuccess;

  @override
  String toString() {
    return 'AuthEvent.confirmCode(onSuccess: $onSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfirmCodeImpl &&
            (identical(other.onSuccess, onSuccess) ||
                other.onSuccess == onSuccess));
  }

  @override
  int get hashCode => Object.hash(runtimeType, onSuccess);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfirmCodeImplCopyWith<_$ConfirmCodeImpl> get copyWith =>
      __$$ConfirmCodeImplCopyWithImpl<_$ConfirmCodeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) pop,
    required TResult Function() sendCode,
    required TResult Function() resendCode,
    required TResult Function(dynamic Function(AuthUser)? onSuccess)
        confirmCode,
    required TResult Function() sendFcmToken,
    required TResult Function(String number) sendResetCode,
  }) {
    return confirmCode(onSuccess);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? pop,
    TResult? Function()? sendCode,
    TResult? Function()? resendCode,
    TResult? Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult? Function()? sendFcmToken,
    TResult? Function(String number)? sendResetCode,
  }) {
    return confirmCode?.call(onSuccess);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? pop,
    TResult Function()? sendCode,
    TResult Function()? resendCode,
    TResult Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult Function()? sendFcmToken,
    TResult Function(String number)? sendResetCode,
    required TResult orElse(),
  }) {
    if (confirmCode != null) {
      return confirmCode(onSuccess);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Pop value) pop,
    required TResult Function(_SendCode value) sendCode,
    required TResult Function(_ResendCode value) resendCode,
    required TResult Function(_ConfirmCode value) confirmCode,
    required TResult Function(_SendFcmToken value) sendFcmToken,
    required TResult Function(_SendResetCode value) sendResetCode,
  }) {
    return confirmCode(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Pop value)? pop,
    TResult? Function(_SendCode value)? sendCode,
    TResult? Function(_ResendCode value)? resendCode,
    TResult? Function(_ConfirmCode value)? confirmCode,
    TResult? Function(_SendFcmToken value)? sendFcmToken,
    TResult? Function(_SendResetCode value)? sendResetCode,
  }) {
    return confirmCode?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Pop value)? pop,
    TResult Function(_SendCode value)? sendCode,
    TResult Function(_ResendCode value)? resendCode,
    TResult Function(_ConfirmCode value)? confirmCode,
    TResult Function(_SendFcmToken value)? sendFcmToken,
    TResult Function(_SendResetCode value)? sendResetCode,
    required TResult orElse(),
  }) {
    if (confirmCode != null) {
      return confirmCode(this);
    }
    return orElse();
  }
}

abstract class _ConfirmCode implements AuthEvent {
  const factory _ConfirmCode({final dynamic Function(AuthUser)? onSuccess}) =
      _$ConfirmCodeImpl;

  dynamic Function(AuthUser)? get onSuccess;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConfirmCodeImplCopyWith<_$ConfirmCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SendFcmTokenImplCopyWith<$Res> {
  factory _$$SendFcmTokenImplCopyWith(
          _$SendFcmTokenImpl value, $Res Function(_$SendFcmTokenImpl) then) =
      __$$SendFcmTokenImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SendFcmTokenImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SendFcmTokenImpl>
    implements _$$SendFcmTokenImplCopyWith<$Res> {
  __$$SendFcmTokenImplCopyWithImpl(
      _$SendFcmTokenImpl _value, $Res Function(_$SendFcmTokenImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SendFcmTokenImpl implements _SendFcmToken {
  const _$SendFcmTokenImpl();

  @override
  String toString() {
    return 'AuthEvent.sendFcmToken()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SendFcmTokenImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) pop,
    required TResult Function() sendCode,
    required TResult Function() resendCode,
    required TResult Function(dynamic Function(AuthUser)? onSuccess)
        confirmCode,
    required TResult Function() sendFcmToken,
    required TResult Function(String number) sendResetCode,
  }) {
    return sendFcmToken();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? pop,
    TResult? Function()? sendCode,
    TResult? Function()? resendCode,
    TResult? Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult? Function()? sendFcmToken,
    TResult? Function(String number)? sendResetCode,
  }) {
    return sendFcmToken?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? pop,
    TResult Function()? sendCode,
    TResult Function()? resendCode,
    TResult Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult Function()? sendFcmToken,
    TResult Function(String number)? sendResetCode,
    required TResult orElse(),
  }) {
    if (sendFcmToken != null) {
      return sendFcmToken();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Pop value) pop,
    required TResult Function(_SendCode value) sendCode,
    required TResult Function(_ResendCode value) resendCode,
    required TResult Function(_ConfirmCode value) confirmCode,
    required TResult Function(_SendFcmToken value) sendFcmToken,
    required TResult Function(_SendResetCode value) sendResetCode,
  }) {
    return sendFcmToken(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Pop value)? pop,
    TResult? Function(_SendCode value)? sendCode,
    TResult? Function(_ResendCode value)? resendCode,
    TResult? Function(_ConfirmCode value)? confirmCode,
    TResult? Function(_SendFcmToken value)? sendFcmToken,
    TResult? Function(_SendResetCode value)? sendResetCode,
  }) {
    return sendFcmToken?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Pop value)? pop,
    TResult Function(_SendCode value)? sendCode,
    TResult Function(_ResendCode value)? resendCode,
    TResult Function(_ConfirmCode value)? confirmCode,
    TResult Function(_SendFcmToken value)? sendFcmToken,
    TResult Function(_SendResetCode value)? sendResetCode,
    required TResult orElse(),
  }) {
    if (sendFcmToken != null) {
      return sendFcmToken(this);
    }
    return orElse();
  }
}

abstract class _SendFcmToken implements AuthEvent {
  const factory _SendFcmToken() = _$SendFcmTokenImpl;
}

/// @nodoc
abstract class _$$SendResetCodeImplCopyWith<$Res> {
  factory _$$SendResetCodeImplCopyWith(
          _$SendResetCodeImpl value, $Res Function(_$SendResetCodeImpl) then) =
      __$$SendResetCodeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String number});
}

/// @nodoc
class __$$SendResetCodeImplCopyWithImpl<$Res>
    extends _$AuthEventCopyWithImpl<$Res, _$SendResetCodeImpl>
    implements _$$SendResetCodeImplCopyWith<$Res> {
  __$$SendResetCodeImplCopyWithImpl(
      _$SendResetCodeImpl _value, $Res Function(_$SendResetCodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
  }) {
    return _then(_$SendResetCodeImpl(
      null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SendResetCodeImpl implements _SendResetCode {
  const _$SendResetCodeImpl(this.number);

  @override
  final String number;

  @override
  String toString() {
    return 'AuthEvent.sendResetCode(number: $number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendResetCodeImpl &&
            (identical(other.number, number) || other.number == number));
  }

  @override
  int get hashCode => Object.hash(runtimeType, number);

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendResetCodeImplCopyWith<_$SendResetCodeImpl> get copyWith =>
      __$$SendResetCodeImplCopyWithImpl<_$SendResetCodeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(BuildContext context) pop,
    required TResult Function() sendCode,
    required TResult Function() resendCode,
    required TResult Function(dynamic Function(AuthUser)? onSuccess)
        confirmCode,
    required TResult Function() sendFcmToken,
    required TResult Function(String number) sendResetCode,
  }) {
    return sendResetCode(number);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(BuildContext context)? pop,
    TResult? Function()? sendCode,
    TResult? Function()? resendCode,
    TResult? Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult? Function()? sendFcmToken,
    TResult? Function(String number)? sendResetCode,
  }) {
    return sendResetCode?.call(number);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(BuildContext context)? pop,
    TResult Function()? sendCode,
    TResult Function()? resendCode,
    TResult Function(dynamic Function(AuthUser)? onSuccess)? confirmCode,
    TResult Function()? sendFcmToken,
    TResult Function(String number)? sendResetCode,
    required TResult orElse(),
  }) {
    if (sendResetCode != null) {
      return sendResetCode(number);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Pop value) pop,
    required TResult Function(_SendCode value) sendCode,
    required TResult Function(_ResendCode value) resendCode,
    required TResult Function(_ConfirmCode value) confirmCode,
    required TResult Function(_SendFcmToken value) sendFcmToken,
    required TResult Function(_SendResetCode value) sendResetCode,
  }) {
    return sendResetCode(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Pop value)? pop,
    TResult? Function(_SendCode value)? sendCode,
    TResult? Function(_ResendCode value)? resendCode,
    TResult? Function(_ConfirmCode value)? confirmCode,
    TResult? Function(_SendFcmToken value)? sendFcmToken,
    TResult? Function(_SendResetCode value)? sendResetCode,
  }) {
    return sendResetCode?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Pop value)? pop,
    TResult Function(_SendCode value)? sendCode,
    TResult Function(_ResendCode value)? resendCode,
    TResult Function(_ConfirmCode value)? confirmCode,
    TResult Function(_SendFcmToken value)? sendFcmToken,
    TResult Function(_SendResetCode value)? sendResetCode,
    required TResult orElse(),
  }) {
    if (sendResetCode != null) {
      return sendResetCode(this);
    }
    return orElse();
  }
}

abstract class _SendResetCode implements AuthEvent {
  const factory _SendResetCode(final String number) = _$SendResetCodeImpl;

  String get number;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendResetCodeImplCopyWith<_$SendResetCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AuthState {
  StatusEnum get status => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TextEditingController phone, StatusEnum status)
        auth,
    required TResult Function(
            TextEditingController controller, StatusEnum status)
        code,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TextEditingController phone, StatusEnum status)? auth,
    TResult? Function(TextEditingController controller, StatusEnum status)?
        code,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TextEditingController phone, StatusEnum status)? auth,
    TResult Function(TextEditingController controller, StatusEnum status)? code,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Auth value) auth,
    required TResult Function(_Code value) code,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Auth value)? auth,
    TResult? Function(_Code value)? code,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Auth value)? auth,
    TResult Function(_Code value)? code,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthStateCopyWith<AuthState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
  @useResult
  $Res call({StatusEnum status});
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusEnum,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthImplCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$$AuthImplCopyWith(
          _$AuthImpl value, $Res Function(_$AuthImpl) then) =
      __$$AuthImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TextEditingController phone, StatusEnum status});
}

/// @nodoc
class __$$AuthImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthImpl>
    implements _$$AuthImplCopyWith<$Res> {
  __$$AuthImplCopyWithImpl(_$AuthImpl _value, $Res Function(_$AuthImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = null,
    Object? status = null,
  }) {
    return _then(_$AuthImpl(
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as TextEditingController,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusEnum,
    ));
  }
}

/// @nodoc

class _$AuthImpl implements _Auth {
  const _$AuthImpl({required this.phone, required this.status});

  @override
  final TextEditingController phone;
  @override
  final StatusEnum status;

  @override
  String toString() {
    return 'AuthState.auth(phone: $phone, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthImpl &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, phone, status);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthImplCopyWith<_$AuthImpl> get copyWith =>
      __$$AuthImplCopyWithImpl<_$AuthImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TextEditingController phone, StatusEnum status)
        auth,
    required TResult Function(
            TextEditingController controller, StatusEnum status)
        code,
  }) {
    return auth(phone, status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TextEditingController phone, StatusEnum status)? auth,
    TResult? Function(TextEditingController controller, StatusEnum status)?
        code,
  }) {
    return auth?.call(phone, status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TextEditingController phone, StatusEnum status)? auth,
    TResult Function(TextEditingController controller, StatusEnum status)? code,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(phone, status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Auth value) auth,
    required TResult Function(_Code value) code,
  }) {
    return auth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Auth value)? auth,
    TResult? Function(_Code value)? code,
  }) {
    return auth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Auth value)? auth,
    TResult Function(_Code value)? code,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(this);
    }
    return orElse();
  }
}

abstract class _Auth implements AuthState {
  const factory _Auth(
      {required final TextEditingController phone,
      required final StatusEnum status}) = _$AuthImpl;

  TextEditingController get phone;
  @override
  StatusEnum get status;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthImplCopyWith<_$AuthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CodeImplCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory _$$CodeImplCopyWith(
          _$CodeImpl value, $Res Function(_$CodeImpl) then) =
      __$$CodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TextEditingController controller, StatusEnum status});
}

/// @nodoc
class __$$CodeImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$CodeImpl>
    implements _$$CodeImplCopyWith<$Res> {
  __$$CodeImplCopyWithImpl(_$CodeImpl _value, $Res Function(_$CodeImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = null,
    Object? status = null,
  }) {
    return _then(_$CodeImpl(
      controller: null == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as TextEditingController,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as StatusEnum,
    ));
  }
}

/// @nodoc

class _$CodeImpl implements _Code {
  const _$CodeImpl({required this.controller, required this.status});

  @override
  final TextEditingController controller;
  @override
  final StatusEnum status;

  @override
  String toString() {
    return 'AuthState.code(controller: $controller, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CodeImpl &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, controller, status);

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CodeImplCopyWith<_$CodeImpl> get copyWith =>
      __$$CodeImplCopyWithImpl<_$CodeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(TextEditingController phone, StatusEnum status)
        auth,
    required TResult Function(
            TextEditingController controller, StatusEnum status)
        code,
  }) {
    return code(controller, status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(TextEditingController phone, StatusEnum status)? auth,
    TResult? Function(TextEditingController controller, StatusEnum status)?
        code,
  }) {
    return code?.call(controller, status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(TextEditingController phone, StatusEnum status)? auth,
    TResult Function(TextEditingController controller, StatusEnum status)? code,
    required TResult orElse(),
  }) {
    if (code != null) {
      return code(controller, status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Auth value) auth,
    required TResult Function(_Code value) code,
  }) {
    return code(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Auth value)? auth,
    TResult? Function(_Code value)? code,
  }) {
    return code?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Auth value)? auth,
    TResult Function(_Code value)? code,
    required TResult orElse(),
  }) {
    if (code != null) {
      return code(this);
    }
    return orElse();
  }
}

abstract class _Code implements AuthState {
  const factory _Code(
      {required final TextEditingController controller,
      required final StatusEnum status}) = _$CodeImpl;

  TextEditingController get controller;
  @override
  StatusEnum get status;

  /// Create a copy of AuthState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CodeImplCopyWith<_$CodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
