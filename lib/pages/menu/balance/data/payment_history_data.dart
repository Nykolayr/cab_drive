import 'package:cab_drive/auth/firebase_auth/auth_util.dart';
import 'package:cab_drive/backend/schema/enums/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../backend/schema/order_record.dart';

class PaymentHistoryData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<OrderRecord>> fetchUserOrders(DateTime startDate, DateTime endDate) async {
    final QuerySnapshot ordersSnapshot = await _firestore.collection('order')
        .where('selected_driver', isEqualTo: currentUserDocument!.reference)
        .where('status', isEqualTo: StatusOrder.completed.name)

        .where('dateTime_created', isGreaterThanOrEqualTo: startDate)
        .where('dateTime_created', isLessThanOrEqualTo: endDate)
        .get();

    return ordersSnapshot.docs.map((doc) => OrderRecord.fromSnapshot(doc)).toList();
  }
}