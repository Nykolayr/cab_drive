import 'dart:math' as math;

import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import 'uploaded_file.dart';

int? findPhotoIndex(
  List<String> photoUrls,
  String targetPhotoUrl,
) {
  // Проверяем, не пуст ли список и существует ли целевое фото
  if (photoUrls.isEmpty || targetPhotoUrl.isEmpty) {
    return -1; // Возвращаем -1, если список пуст или целевое фото не указано
  }

  // Ищем индекс целевого фото в списке
  for (int i = 0; i < photoUrls.length; i++) {
    if (photoUrls[i] == targetPhotoUrl) {
      return i; // Возвращаем индекс, если фото найдено
    }
  }
}

String formatPhoneNumber(String phoneNumber) {
  // Удаляем все символы, кроме цифр
  String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  // Если номер начинается с '8', заменяем его на '7'
  if (cleanedNumber.startsWith('8')) {
    cleanedNumber = '7' + cleanedNumber.substring(1);
  }

  return cleanedNumber;
}

List<String> combineUploadedFile(
  String file1,
  String file2,
  String file3,
  String file4,
  String file5,
) {
  // Combine the files into a list and return
  return [file1, file2, file3, file4, file5];
}

List<FFUploadedFile> myCustomFileFunction(
  List<FFUploadedFile> pageStateList,
  List<FFUploadedFile> uploadList,
) {
  // Example: Merging two lists into one
  List<FFUploadedFile> mergedList = [];
  mergedList.addAll(pageStateList);
  mergedList.addAll(uploadList);

  // You can add additional logic here as needed

  return mergedList;
}

String formatLatLng(LatLng latLng) {
  return '${latLng.latitude}, ${latLng.longitude}';
}

LatLng convertLatLngFromStrings(
  String latString,
  String lngString,
) {
  double lat = double.parse(latString);
  double lng = double.parse(lngString);
  return LatLng(lat, lng);
}

double extractLatLong(
  LatLng inputLatLong,
  bool isLat,
) {
  if (isLat) {
    return inputLatLong.latitude;
  } else {
    return inputLatLong.longitude;
  }
}

DateTime toUtc() {
  return DateTime.now().toUtc();
}

bool isWithinFiveMinutes(DateTime lastLoginTime) {
  final now = DateTime.now().toUtc();
  final difference = now.difference(lastLoginTime);
  return difference.inMinutes <= 5;
}

String getReviewString(int number) {
  // Определяем последние две цифры числа
  int lastTwoDigits = number % 100;
  // Определяем последнюю цифру числа
  int lastDigit = number % 10;

  // Проверяем условия для правильного склонения
  if (lastTwoDigits >= 11 && lastTwoDigits <= 19) {
    return 'Отзывов о работе';
  } else if (lastDigit == 1) {
    return 'Отзыв о работе';
  } else if (lastDigit >= 2 && lastDigit <= 4) {
    return 'Отзыва о работе';
  } else {
    return 'Отзывов о работе';
  }
}

String getGreeting() {
  final now = DateTime.now();
  final hour = now.hour;

  if (hour >= 5 && hour < 12) {
    return 'Доброе утро';
  } else if (hour >= 12 && hour < 18) {
    return 'Добрый день';
  } else if (hour >= 18 && hour < 23) {
    return 'Добрый вечер';
  } else {
    return 'Доброй ночи';
  }
}

List<OrderRecord> filterOrders(
  int? ott,
  int? doo,
  int? supply,
  double? radius,
  List<OrderRecord> listPosts,
  LatLng? currentLocation,
  String? car,
) {
  if (listPosts.isEmpty) {
    return [];
  }

  List<OrderRecord> filteredOrders = listPosts;

  // Фильтрация по бюджету
  filteredOrders = filteredOrders.where((order) {
    final budget = order.budget ?? 0;

    if (ott != null && doo == null) {
      return budget >= ott;
    }

    if (ott == null && doo != null) {
      return budget <= doo;
    }

    if (ott != null && doo != null) {
      return budget >= ott && budget <= doo;
    }

    return true;
  }).toList();

  // Фильтрация по типу подачи
  if (supply != null && (supply == 1 || supply == 2)) {
    filteredOrders = filteredOrders.where((order) {
      return order.supply == supply;
    }).toList();
  }

  // Фильтрация по типу машины
  if (car != null && car.isNotEmpty) {
    final filterCar = car.toLowerCase();

    filteredOrders = filteredOrders.where((order) {
      final orderCar = order.car?.name ?? '';

      if (filterCar == 'largus') {
        return orderCar == 'largus';
      } else if (filterCar == 'fiat') {
        return orderCar == 'fiat' || orderCar == 'largus';
      } else if (filterCar == 'largustermo') {
        return orderCar == 'largustermo';
      }

      return true;
    }).toList();
  }

  // Фильтрация по радиусу (или до 200 км если radius == null)
  final LatLng effectiveLocation =
      currentLocation ?? LatLng(55.7558, 37.6173); // Центр Москвы
  final double effectiveRadius =
      (radius != null && radius > 0) ? radius : 200.0;

  filteredOrders = filteredOrders.where((order) {
    final geoPoint = order.pointA?.latlng;
    final orderLocation =
        geoPoint != null ? LatLng(geoPoint.latitude, geoPoint.longitude) : null;

    if (orderLocation == null) {
      return false;
    }

    final distance = calculateDistance(
      effectiveLocation.latitude,
      effectiveLocation.longitude,
      orderLocation.latitude,
      orderLocation.longitude,
    );

    return distance <= effectiveRadius;
  }).toList();

  return filteredOrders;
}

/// Вспомогательная функция для расчёта расстояния между двумя точками
double calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const double earthRadius = 6371; // Радиус Земли в км

  final double lat1Rad = lat1 * math.pi / 180;
  final double lon1Rad = lon1 * math.pi / 180;
  final double lat2Rad = lat2 * math.pi / 180;
  final double lon2Rad = lon2 * math.pi / 180;

  final double dLat = lat2Rad - lat1Rad;
  final double dLon = lon2Rad - lon1Rad;

  final double a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1Rad) * math.cos(lat2Rad) * math.pow(math.sin(dLon / 2), 2);

  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

double recalculateRatingWithNewReview(
  int totalReviews,
  double currentAverageRating,
  int newRating,
) {
  // Сумма всех текущих отзывов
  double totalRatingSum = currentAverageRating * totalReviews;

  // Прибавляем новый рейтинг
  totalRatingSum += newRating;

  // Пересчитываем новый средний рейтинг, увеличив количество отзывов
  double newAverageRating = totalRatingSum / (totalReviews + 1);

  return newAverageRating;
}

List<DocumentReference> comnineUsers(
  DocumentReference user1,
  DocumentReference user2,
) {
  List<DocumentReference> combinedUsers = [];
  combinedUsers.add(user1);
  combinedUsers.add(user2);

  return combinedUsers;
}

String? formatPhoneNumber1(String? phoneNumber) {
  if (phoneNumber == null || phoneNumber.length != 11) {
    // Возвращаем null, если номер пустой или некорректной длины
    return null;
  }

  return '+' +
      phoneNumber.substring(0, 1) +
      ' (' +
      phoneNumber.substring(1, 4) +
      ') ' +
      phoneNumber.substring(4, 7) +
      ' ' +
      phoneNumber.substring(7, 9) +
      '-' +
      phoneNumber.substring(9, 11);
}

List<DocumentReference> combineUsers2(DocumentReference user) {
  final fixedUser =
      FirebaseFirestore.instance.doc('users/nd5x0Adu9oSjrvHv5e1Mljzl7BB2');
  return [user, fixedUser];
}

List<DocumentReference>? deleteUser(
  List<DocumentReference>? allusers,
  DocumentReference? deleteusers,
) {
  /// Если список пользователей или пользователь для удаления равны null,
  /// возвращаем исходный список без изменений.
  if (allusers == null || deleteusers == null) return allusers;

  /// Фильтруем список, исключая документ, соответствующий пользователю,
  /// которого нужно удалить.
  final updatedList = allusers.where((user) => user != deleteusers).toList();

  return updatedList;
}

DateTime datetime24() {
  DateTime now = DateTime.now();
  return now.add(Duration(hours: 24));
}

double proc(double balance) {
  final percent = balance * 0.03;
  return percent < 50 ? 50 : percent;
}

String formatDriverBalance(double balance, double bonusBalance) {
  // Крупно — только выводимый balance; бонус отдельно.
  if (bonusBalance > 0) {
    return '${balance.toStringAsFixed(0)} ₽ (+${bonusBalance.toStringAsFixed(0)} ₽ бонус на комиссию)';
  }
  return '${balance.toStringAsFixed(0)} ₽';
}

double driverSpendableBalance(double balance, double bonusBalance) {
  final bonus = bonusBalance > 0 ? bonusBalance : 0.0;
  return balance + bonus;
}

/// Долг, блокирующий заказы/смену: суммарно (balance + bonus) в минусе.
bool driverHasWorkDebt(double balance, double bonusBalance) {
  return driverSpendableBalance(balance, bonusBalance) < 0;
}

List<DocumentReference> listusers(DocumentReference usercur) {
  final fixedUserRef =
      FirebaseFirestore.instance.doc('users/MEkzqxquE2OqdVEZi4NrxZ9K8F03');

  return [usercur, fixedUserRef];
}

bool hours48(DateTime shiftcompletiondate) {
  final now = DateTime.now();
  final difference = now.difference(shiftcompletiondate);
  return difference.inHours > 48;
}

int newCustomFunction2(DateTime datetimestart) {
  // Длительность смены — 12 часов
  final shiftDuration = Duration(hours: 12);

  // Конец смены = старт + 12 часов
  final shiftEnd = datetimestart.add(shiftDuration);

  // Текущее время
  final now = DateTime.now();

  // Разница между концом смены и текущим временем
  final remaining = shiftEnd.difference(now);

  // Если смена уже закончилась — возвращаем 0
  return remaining.isNegative ? 0 : remaining.inMilliseconds;
}

String cleanCardNumber(String cardNumber) {
  return cardNumber.replaceAll(' ', '');
}
