import 'package:dio/dio.dart';

import 'shared_prefs.dart';


class AppDio {
  static const domain = useTestDomain ? testDomain :  'http://37.252.20.248:5000/kek/';

  static const testDomain = 'http://127.0.0.1:5000/kek/';
  static const socketUrl = 'ws://37.252.20.248:8090/';
  static const useTestDomain = false;


  static Map<String, String>? get headers =>  (SharedPrefs.token ?? '').isEmpty ? null : {
    'Authorization': 'Bearer ${SharedPrefs.token}',
  };



  static Dio get dio => Dio(
    BaseOptions(
      baseUrl: domain,
      headers: headers,
    ),
  );


  Dio call () {
    return dio;
  }
}