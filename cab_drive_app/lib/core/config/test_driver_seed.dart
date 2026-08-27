import 'package:cloud_firestore/cloud_firestore.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/lat_lng.dart';

/// Локальный мок активного заказа для `isTest`.
class TestDriverSeed {
  TestDriverSeed._();

  static const orderId = '_local_isTest';

  static DocumentReference get orderRef =>
      FirebaseFirestore.instance.collection('order').doc(orderId);

  static OrderRecord buildOrder() {
    const pointA = LatLng(55.751244, 37.618423);
    const pointB = LatLng(55.763232, 37.621393);
    const car = LatLng(55.7495, 37.6170);
    final me = currentUserReference;

    return OrderRecord.getDocumentFromData(
      {
        'status': StatusOrder.at_work.serialize(),
        'selected_driver': me,
        'user_customer': me,
        'pointA': PointStruct(
          latlng: pointA,
          address: 'Красная площадь',
          fullAddress: 'Москва, Красная площадь, 1',
        ),
        'pointB': PointStruct(
          latlng: pointB,
          address: 'Цветной бульвар',
          fullAddress: 'Москва, Цветной бульвар, 1',
        ),
        'driver_location': car,
        'time_left': '12 мин',
        'km_left': '2.1 км',
        'description': 'Тестовый заказ (isTest)',
        'budget': 1800,
        'distance': 3500,
        'time': '15 мин',
      },
      orderRef,
    );
  }
}
