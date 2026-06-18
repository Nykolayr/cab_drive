// lib/features/orders/data/datasources/orders_remote_data_source.dart
import 'dart:convert';

import 'package:cab_drive/core/utils/app_dio.dart';
import 'package:http/http.dart' as http;
import '../../data/models/order_models.dart';

class OrdersRemoteDataSource {

  Future<ETAResponseModel> getPickupCalculate(GetETARequestModel request) async {
    final resp = await AppDio.dio.post('orders/pickup_calculate',
        data: {
          'user_location': request.user_location.toJson(),
          if (request.radius_km != null) 'radius_km': request.radius_km.toString(),
        });



    final body = resp.data;
    // The Python utils.get_answer wraps data under {'etas': etas}
    final data = body['etas'] ?? body;
    return ETAResponseModel.fromJson({'etas': Map<String, dynamic>.from(data)});
  }

  Future<PricesResponseModel> getRouteCalculate(GetPricesRequestModel request) async {
    final qp = {
      'user_location': request.user_location.toJson(),
      'dest_location': request.dest_location.toJson(),
      'movers': request.movers,
    };

    if (request.intermediate_location != null) {
      qp['intermediate_location'] = request.intermediate_location!.toJson();
    }

    final resp = await AppDio.dio.post('orders/route_calculate', data: qp);



    final body = resp.data;
    final data = body['prices'] ?? body;
    return PricesResponseModel.fromJson({'prices': Map<String, dynamic>.from(data)});
  }
}