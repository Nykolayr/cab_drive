import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../core/utils/app_dio.dart';
import '../models/check_inn_model.dart';

class CheckInnRemoteDataSource {
  CheckInnRemoteDataSource();

  Future<CheckInnResponseModel> checkInn(String inn) async {
    final resp = await AppDio.dio.get('users/check_inn', queryParameters: {
      'inn': inn,
    });



    final body = resp.data;

    // If server returns non-json or empty, throw
    return CheckInnResponseModel.fromJson(body);
  }
}