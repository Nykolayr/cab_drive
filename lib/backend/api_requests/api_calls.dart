import 'dart:convert';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class ApSmsCall {
  static Future<ApiCallResponse> call({
    String? token = 'f216e5f9710bc967c59cc36ce41a38d9b52e0ef690d6ad04',
    String? title = 'send sms',
    String? sender = 'test4sms.ru',
    String? receiver = '',
    String? msgdata = '',
  }) async {
    final ffApiRequestBody = '''
{
  "title": "send_sms",
  "sender": "${sender}",
  "receiver": "${receiver}",
  "msgdata": "${msgdata}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'AP SMS',
      apiUrl: 'https://a2p-sms-api.mcn.ru/api/a2p_sms/api/v1.1/send_sms',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token}',
        'Accept': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: true,
      decodeUtf8: true,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class AutocompleteCall {
  static Future<ApiCallResponse> call({
    String? input = '',
    String? types = 'geocode',
    String? location = '55.7558,37.6173',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'autocomplete',
      apiUrl: 'https://maps.googleapis.com/maps/api/place/autocomplete/json',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'input': input,
        'key': "AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY",
        'language': "ru",
        'components': "country:ru",
        'types': types,
        'radius': 50000,
        'location': location,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? placeid(dynamic response) => (getJsonField(
        response,
        r'''$.predictions[:].place_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? addresses(dynamic response) => (getJsonField(
        response,
        r'''$.predictions[:].structured_formatting.main_text''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? region(dynamic response) => (getJsonField(
        response,
        r'''$.predictions[:].structured_formatting.secondary_text''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List? city(dynamic response) => getJsonField(
        response,
        r'''$.predictions''',
        true,
      ) as List?;
}

class GeocodeLatLngCall {
  static Future<ApiCallResponse> call({
    String? latlng = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'geocode LatLng',
      apiUrl: 'https://maps.googleapis.com/maps/api/geocode/json',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'latlng': latlng,
        'key': "AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY",
        'language': "ru",
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? address(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].formatted_address''',
      ));
  static String? placeId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].place_id''',
      ));
  static String? areal(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'administrative_area_level_1')])].long_name''',
      ));
  static String? city(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'locality')])].long_name''',
      ));
  static String? number(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'street_number')])].long_name''',
      ));
  static String? street(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'route')])].long_name''',
      ));
  static dynamic areal3(dynamic response) => getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'administrative_area_level_3')])].long_name''',
      );
  static double? lat(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.results[0].geometry.location.lat''',
      ));
  static double? lng(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.results[0].geometry.location.lng''',
      ));
}

class GeocodePlaceIDCall {
  static Future<ApiCallResponse> call({
    String? placeId = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'geocode Place ID',
      apiUrl: 'https://maps.googleapis.com/maps/api/geocode/json',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'key': "AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY",
        'language': "ru",
        'place_id': placeId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? address(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].formatted_address''',
      ));
  static String? placeId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].place_id''',
      ));
  static String? areal(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'administrative_area_level_1')])].long_name''',
      ));
  static String? city(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'locality')])].long_name''',
      ));
  static String? number(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'street_number')])].long_name''',
      ));
  static String? street(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'route')])].long_name''',
      ));
  static dynamic areal3(dynamic response) => getJsonField(
        response,
        r'''$.results[0].address_components[?(@.types[?(@ == 'administrative_area_level_3')])].long_name''',
      );
  static double? lat(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.results[0].geometry.location.lat''',
      ));
  static double? lng(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.results[0].geometry.location.lng''',
      ));
}

class DistanceMatrixCall {
  static Future<ApiCallResponse> call({
    String? destination = '',
    String? origin = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'DistanceMatrix',
      apiUrl:
          'https://maps.googleapis.com/maps/api/distancematrix/json?destinations=${destination}&origins=${origin}&language=ru',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'key': "AIzaSyBSKcBWb1nCdTBjrOPC9okX-lVa3PdjzcY",
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? distance(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.rows[:].elements[:].distance.text''',
      ));
  static String? time(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.rows[:].elements[:].duration.text''',
      ));
}

class InitPaymentCall {
  static Future<ApiCallResponse> call({
    int? amount,
    String? description = '',
    String? orderId = '',
    String? customerKey = '',
  }) async {
    final ffApiRequestBody = '''
{
  "amount": ${amount},
  "description": "${escapeStringForJson(description)}",
  "orderId": "${escapeStringForJson(orderId)}",
  "customerKey": "${escapeStringForJson(customerKey)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Init Payment',
      apiUrl: 'https://init-payment-1070996805603.us-central1.run.app',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? paymentUrl(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.paymentUrl''',
      ));
  static String? paymentId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.paymentId''',
      ));
}

class InitRecurrentPaymentCall {
  static Future<ApiCallResponse> call({
    int? amount,
    String? description = '',
    String? orderId = '',
    String? customerKey = '',
  }) async {
    final ffApiRequestBody = '''
{
  "amount": ${amount},
  "description": "${escapeStringForJson(description)}",
  "orderId": "${escapeStringForJson(orderId)}",
  "customerKey": "${escapeStringForJson(customerKey)}"

}''';
    return ApiManager.instance.makeApiCall(
      callName: 'initRecurrentPayment',
      apiUrl:
          'https://init-recurrent-payment-1070996805603.us-central1.run.app',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? paymentUrl(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.paymentUrl''',
      ));
  static String? paymentId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.paymentId''',
      ));
}

class ChargeRecurrentPaymentCall {
  static Future<ApiCallResponse> call({
    String? paymentId = '',
    String? rebillId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "paymentId": ${escapeStringForJson(paymentId)},
  "rebillId": "${escapeStringForJson(rebillId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'chargeRecurrentPayment',
      apiUrl:
          'https://charge-recurrent-payment-1070996805603.us-central1.run.app',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? paymentUrl(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.paymentUrl''',
      ));
  static String? paymentId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.paymentId''',
      ));
  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.Success''',
      ));
  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.Message''',
      ));
  static String? errorCode(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.ErrorCode''',
      ));
}

class PrepareRecurrentPaymentCall {
  static Future<ApiCallResponse> call({
    int? amount,
    String? description = '',
    String? orderId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "amount": ${amount},
  "description": "${escapeStringForJson(description)}",
  "orderId": "${escapeStringForJson(orderId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'prepareRecurrentPayment',
      apiUrl:
          'https://prepare-recurrent-payment-1070996805603.us-central1.run.app',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? paymentId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.paymentId''',
      ));
}

class GetCardListCall {
  static Future<ApiCallResponse> call({
    String? customerKey = '',
  }) async {
    final ffApiRequestBody = '''
{
  "customerKey": "${escapeStringForJson(customerKey)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'GetCardList',
      apiUrl: 'https://getcardlist-1070996805603.us-central1.run.app',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? cardId(dynamic response) => getJsonField(
        response,
        r'''$.cards[:].CardId''',
        true,
      ) as List?;
  static List? pan(dynamic response) => getJsonField(
        response,
        r'''$.cards[:].Pan''',
        true,
      ) as List?;
  static dynamic cards(dynamic response) => getJsonField(
        response,
        r'''$.cards''',
      );
}

class CreateClientAndPayoutCall {
  static Future<ApiCallResponse> call({
    String? phone = '',
    String? lastName = '',
    String? firstName = '',
    String? accountNumber = '',
    double? amount,
    String? customerPaymentId = '',
  }) async {
    final ffApiRequestBody = '''
{
  "customer_payment_id": "${escapeStringForJson(customerPaymentId)}",
  "phone": "${escapeStringForJson(phone)}",
  "last_name": "${escapeStringForJson(lastName)}",
  "first_name": "${escapeStringForJson(firstName)}",
  "requisite": {
    "type_id": 8,
    "account_number": "${escapeStringForJson(accountNumber)}"
  },
  "amount": ${amount}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Create Client And Payout',
      apiUrl: 'https://api.jump.finance/services/openapi/payments/smart',
      callType: ApiCallType.POST,
      headers: {
        'Client-Key': '12b46b45-f258-4e3c-9509-9dc7280cdeed',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? errordetail(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.error.detail''',
      ));
  static List<String>? messages(dynamic response) => (getJsonField(
        response,
        r'''$.error.fields[:].messages''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static int? errorcode(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.error.code''',
      ));
  static int? contractorID(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.item.contractor.id''',
      ));
}

class PayoutCall {
  static Future<ApiCallResponse> call({
    int? contractorId,
    String? accountNumber = '',
    double? amount,
  }) async {
    final ffApiRequestBody = '''
{
  "requisite": {
    "type_id": 8,
    "account_number": "${escapeStringForJson(accountNumber)}"
  },
  "contractor_id": ${contractorId},
  "amount": ${amount}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'Payout',
      apiUrl: 'https://api.jump.finance/services/openapi/payments',
      callType: ApiCallType.POST,
      headers: {
        'Client-Key': '12b46b45-f258-4e3c-9509-9dc7280cdeed',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? title(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.error.title''',
      ));
  static List<String>? messages(dynamic response) => (getJsonField(
        response,
        r'''$.error.fields[:].messages''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static int? errorcode(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.error.code''',
      ));
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
