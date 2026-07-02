import 'dart:math' as math;

import 'lat_lng.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/enums/enums.dart';

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
    cleanedNumber = '7${cleanedNumber.substring(1)}';
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
      currentLocation ?? const LatLng(55.7558, 37.6173); // Центр Москвы
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

  return '+${phoneNumber.substring(0, 1)} (${phoneNumber.substring(1, 4)}) ${phoneNumber.substring(4, 7)} ${phoneNumber.substring(7, 9)}-${phoneNumber.substring(9, 11)}';
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

int newCustomFunction(
  int loader,
  Car tarif,
  LatLng pointA,
  LatLng pointB,
  String travelTime,
  String travelDistance,
) {
  // Вспомогательная функция для перевода градусов в радианы.
  double _deg2rad(double deg) => deg * (3.141592653589793 / 180);

  // Вспомогательная функция для расчёта расстояния между двумя точками (в км) по формуле гаверсинуса.
  double calculateDistance(LatLng a, LatLng b) {
    const double R = 6371; // Радиус Земли в км.
    double dLat = _deg2rad(b.latitude - a.latitude);
    double dLon = _deg2rad(b.longitude - a.longitude);
    double lat1 = _deg2rad(a.latitude);
    double lat2 = _deg2rad(b.latitude);
    double aCalc = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(aCalc), math.sqrt(1 - aCalc));
    return R * c;
  }

  // Вспомогательная функция для проверки, находится ли точка в пределах Москвы.
  bool isInMoscow(LatLng point) {
    return (point.latitude >= 55.5 &&
        point.latitude <= 56.0 &&
        point.longitude >= 37.0 &&
        point.longitude <= 38.0);
  }

  // Вспомогательная функция для сегментированного расчёта стоимости для маршрутов "за МКАД".
  double calculateSegmentedCost(double dist) {
    double cost = 0.0;
    double remaining = dist;
    double seg;

    seg = math.min(remaining, 10);
    cost += seg * 26.46;
    remaining -= seg;

    if (remaining > 0) {
      seg = math.min(remaining, 10);
      cost += seg * 31.77;
      remaining -= seg;
    }
    if (remaining > 0) {
      seg = math.min(remaining, 10);
      cost += seg * 37.08;
      remaining -= seg;
    }
    if (remaining > 0) {
      seg = math.min(remaining, 10);
      cost += seg * 42.39;
      remaining -= seg;
    }
    if (remaining > 0) {
      seg = math.min(remaining, 10);
      cost += seg * 47.7;
      remaining -= seg;
    }
    if (remaining > 0) {
      cost += remaining * 53.01;
    }
    return cost;
  }

  // Вспомогательная функция для парсинга строки расстояния, например "14,7 км".
  double parseDistance(String s) {
    s = s
        .replaceAll(" ", "")
        .replaceAll("км", "")
        .replaceAll("km", "")
        .replaceAll(",", ".");
    return double.tryParse(s) ?? 0.0;
  }

  // Вспомогательная функция для парсинга строки времени, например "27 мин.".
  double parseTime(String s) {
    s = s.replaceAll(" ", "").replaceAll("мин.", "").replaceAll("мин", "");
    return double.tryParse(s) ?? 0.0;
  }

  // Рассчитываем расстояние между точками по координатам.
  double computedDistance = calculateDistance(pointA, pointB);
  // Парсим предоставленные строки для расстояния и времени.
  double providedDistance = parseDistance(travelDistance);
  double providedTime = parseTime(travelTime);

  // Используем предоставленные данные, если они больше нуля, иначе вычисленное расстояние.
  double effectiveDistance =
      providedDistance > 0 ? providedDistance : computedDistance;
  double effectiveTime = providedTime; // в минутах

  // Определяем тип маршрута:
  // "moscow" – если обе точки в Москве,
  // "intercity" – если хотя бы одна точка вне Москвы и effectiveDistance < 40 км,
  // "mkaD" – если effectiveDistance ≥ 40 км.
  String routeType;
  if (isInMoscow(pointA) && isInMoscow(pointB)) {
    routeType = "moscow";
  } else if (effectiveDistance < 40) {
    routeType = "intercity";
  } else {
    routeType = "mkaD";
  }

  double baseFare = 0.0;
  double extraCost = 0.0;
  double extraTimeCost = 0.0;

  // Для тарифов машин S и M (Car.largus и Car.fiat):
  if (tarif == Car.largus) {
    // Машина размера S.
    if (routeType == "moscow") {
      if (loader == 0) {
        baseFare = 797;
      } else if (loader == 1)
        baseFare = 1391;
      else if (loader == 2) baseFare = 1985;
    } else if (routeType == "intercity") {
      if (loader == 0) {
        baseFare = 835;
      } else if (loader == 1)
        baseFare = 1429;
      else if (loader == 2) baseFare = 2023;
    } else {
      // routeType == "mkaD"
      // Берём московский тариф как базовый.
      if (loader == 0) {
        baseFare = 797;
      } else if (loader == 1)
        baseFare = 1391;
      else if (loader == 2) baseFare = 1985;
    }
    // Дополнительные затраты: базовая цена покрывает стандарт до 15 км и 15 мин.
    if (routeType == "moscow" || routeType == "intercity") {
      if (effectiveDistance > 15) {
        extraCost = (effectiveDistance - 15) * 15.93;
      }
      if (effectiveTime > 15) {
        extraTimeCost = (effectiveTime - 15) * 10.62;
      }
    } else if (routeType == "mkaD") {
      extraCost = calculateSegmentedCost(effectiveDistance);
      // Дополнительное время для "mkaD" не учитывается отдельно.
    }
  } else if (tarif == Car.fiat) {
    // Машина размера M.
    if (routeType == "moscow") {
      if (loader == 0) {
        baseFare = 1035;
      } else if (loader == 1)
        baseFare = 1737;
      else if (loader == 2) baseFare = 2552;
    } else if (routeType == "intercity") {
      if (loader == 0) {
        baseFare = 1086;
      } else if (loader == 1)
        baseFare = 1788;
      else if (loader == 2) baseFare = 2490;
    } else {
      // routeType == "mkaD"
      if (loader == 0) {
        baseFare = 1035;
      } else if (loader == 1)
        baseFare = 1737;
      else if (loader == 2) baseFare = 2552;
    }
    if (routeType == "moscow" || routeType == "intercity") {
      if (effectiveDistance > 15) {
        extraCost = (effectiveDistance - 15) * 15.93;
      }
      if (effectiveTime > 15) {
        extraTimeCost = (effectiveTime - 15) * 10.62;
      }
    } else if (routeType == "mkaD") {
      extraCost = calculateSegmentedCost(effectiveDistance);
    }
  } else if (tarif == Car.largusTermo) {
    // Термобудка по новым правилам:
    // В обоих направлениях. Базовый тариф для 4 часов + 1 час подачи.
    // Дополнительно оплачивается каждый начатый час сверх 5 часов (300 минут).
    // При этом тариф зависит от количества грузчиков:
    // без грузчика: 2500 базовый, 800 руб/час дополнительно,
    // с 1 грузчиком: 3500 базовый, 1700 руб/час дополнительно,
    // с 2 грузчиками: 7500 базовый, 2800 руб/час дополнительно.
    double baseFareTermo = 0.0;
    double extraTimeFare = 0.0;

    // Базовое время – 300 минут (5 часов).
    if (loader == 0) {
      baseFareTermo = 2500;
      if (effectiveTime > 300) {
        extraTimeFare = ((effectiveTime - 300) / 60).ceil() * 800;
      }
    } else if (loader == 1) {
      baseFareTermo = 3500;
      if (effectiveTime > 300) {
        extraTimeFare = ((effectiveTime - 300) / 60).ceil() * 1700;
      }
    } else if (loader == 2) {
      baseFareTermo = 7500;
      if (effectiveTime > 300) {
        extraTimeFare = ((effectiveTime - 300) / 60).ceil() * 2800;
      }
    } else {
      // Обеспечиваем присвоение значения по умолчанию.
      baseFareTermo = 2500;
    }

    double extraDistanceFare = 0.0;
    // Если маршрут "за МКАД" и effectiveDistance больше 40 км,
    // то за каждый км свыше 40 оплачивается по ставке 22 руб/км.
    if (routeType == "mkaD" && effectiveDistance > 40) {
      extraDistanceFare = (effectiveDistance - 40) * 22;
    }

    baseFare = baseFareTermo;
    extraTimeCost = extraTimeFare;
    extraCost = extraDistanceFare;
  }

  double totalCost = baseFare + extraCost + extraTimeCost;

  // Округляем итоговую стоимость до ближайшего целого числа.
  return totalCost.round();
}

DateTime datetime24() {
  DateTime now = DateTime.now();
  return now.add(const Duration(hours: 24));
}

double proc(double balance) {
  final percent = balance * 0.03;
  return percent < 50 ? 50 : percent;
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
  const shiftDuration = Duration(hours: 12);

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
