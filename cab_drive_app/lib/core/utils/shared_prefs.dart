import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DataType { string, bool, int }

class SharedPrefs {
  static late SharedPreferences sharedPreferences;

  /// Универсальный метод сета в SharedPreferences
  ///
  /// [title] - куда сеттим
  ///
  /// [data] - что сеттим
  ///
  /// [type] - тип данных, если надо можно и другие добавить
  ///
  /// инициализация в сплеше идёт
  static Future<void> setData({
    required String title,
    required var data,
    required DataType type,
  }) async {
    if (data == null) {
      sharedPreferences.remove(title);
      return;
    }
    switch (type) {
      case DataType.string:
        await sharedPreferences.setString(title, data);
        break;
      case DataType.bool:
        await sharedPreferences.setBool(title, data);
        break;
      case DataType.int:
        await sharedPreferences.setInt(title, data);
        break;
      default:
        break;
    }
  }

  static getData({
    required String title,
    required DataType type,
  }) {
    switch (type) {
      case DataType.string:
        return sharedPreferences.getString(title);
      case DataType.bool:
        return sharedPreferences.getBool(title);
      case DataType.int:
        return sharedPreferences.getInt(title);
      default:
    }
  }


  /// Ключ для сервера
  static bool? get isProdApi => sharedPreferences.getBool(SharedPrefsNames.isProdApi) ?? true;

  static set setApiState(bool? value) =>sharedPreferences.setBool(SharedPrefsNames.isProdApi, value ?? true);


  /// Ключ для токена
  static String get token {
    final token = /* '83275|5f7LfyMxwTowtoBfZLMUUb0zLlUDbTp3868zhGrjc61d8e5d' ??*/ sharedPreferences.getString('token');
    debugPrint(token);
    return token ?? '';
  }

  static set setToken(String? value) => setData(
    title: SharedPrefsNames.token,
    data: value,
    type: DataType.string,
  );

  static String get paymentType {
    final token =  sharedPreferences.getString(SharedPrefsNames.paymentType);
    return token ?? 'cash';
  }

  static set setPaymentType(String? value) => setData(
    title: SharedPrefsNames.paymentType,
    data: value,
    type: DataType.string,
  );


  static List<String> get recentAddresses {
    final value =  sharedPreferences.getStringList(SharedPrefsNames.recentAddresses);
    return value ?? [];
  }

  static set setRecentAddresses(List<String> value) => SharedPrefs.sharedPreferences.setStringList(SharedPrefsNames.recentAddresses, value);


  static List<String>? get cartItems {
    final token =  sharedPreferences.getStringList(SharedPrefsNames.cartItems);
    return token;
  }

  static set setCartItems(List<String>? value) => sharedPreferences.setStringList(SharedPrefsNames.cartItems, value ?? []);
}

class SharedPrefsNames {
  static String token = 'token';

  static String paymentType = 'paymentType';
  static String recentAddresses = 'recentAddresses';


  static String cartItems = 'cartItems';

  static String isProdApi = 'isProdApi';
}