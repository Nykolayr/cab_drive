import 'package:collection/collection.dart';

enum Role {
  driver,
  user,
  admin,
}

enum StatusVerif {
  onVerif,
  Completed,
  otklonena,
}

enum StatusOrder {
  newOrder,
  completed,
  hidden,
  cancelled,
  spec_set,
  at_work,
  on_confirmation,
}

enum Car {
  largusTermo,
  largus,
  fiat,
}

enum PayMethod {
  card,
  cahs,
}

enum PaymentType {
  regular,
  initRecurrent,
  chargeRecurrent,
  regularCustomer,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (Role):
      return Role.values.deserialize(value) as T?;
    case (StatusVerif):
      return StatusVerif.values.deserialize(value) as T?;
    case (StatusOrder):
      return StatusOrder.values.deserialize(value) as T?;
    case (Car):
      return Car.values.deserialize(value) as T?;
    case (PayMethod):
      return PayMethod.values.deserialize(value) as T?;
    case (PaymentType):
      return PaymentType.values.deserialize(value) as T?;
    default:
      return null;
  }
}
