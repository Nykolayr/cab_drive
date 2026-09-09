import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '/backend/api_requests/payments_api_config.dart';

/// Клиент Data API (Postgres SoT). Firestore — только fallback / зеркало на сервере.
class AppMeApi {
  AppMeApi._();

  static Future<String?> _idToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) return null;
    return token;
  }

  static Future<Map<String, dynamic>?> _request(
    String method,
    String relative, {
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final token = await _idToken();
    if (token == null) return null;
    final uri = Uri.parse(PaymentsApiConfig.path(relative));
    try {
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      late http.Response resp;
      if (method == 'GET') {
        resp = await http.get(uri, headers: headers).timeout(timeout);
      } else if (method == 'DELETE') {
        resp = await http.delete(uri, headers: headers).timeout(timeout);
      } else if (method == 'PATCH') {
        resp = await http
            .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(timeout);
      } else {
        resp = await http
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(timeout);
      }
      final decoded = jsonDecode(resp.body);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      map['_ok'] = resp.statusCode >= 200 && resp.statusCode < 300;
      map['_status'] = resp.statusCode;
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        // ignore: avoid_print
        print('[AppMeApi] $method $relative status=${resp.statusCode} body=${resp.body}');
      }
      return map;
    } catch (e) {
      // ignore: avoid_print
      print('[AppMeApi] $method $relative FAIL $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchMeMap() async {
    final r = await _request('GET', '/api/app/me');
    if (r == null || r['_ok'] != true) return null;
    final userMap = r['user'];
    if (userMap is! Map) return null;
    return Map<String, dynamic>.from(userMap);
  }

  static Future<AppMe?> fetchMe() async {
    final map = await fetchMeMap();
    if (map == null) return null;
    return AppMe.fromJson(map);
  }

  /// Частичный апдейт профиля → PATCH /api/app/me (Postgres).
  static Future<Map<String, dynamic>?> patchMe(Map<String, dynamic> body) async {
    if (body.isEmpty) return null;
    final r = await _request('PATCH', '/api/app/me', body: body);
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) {
      final user = result['user'];
      if (user is Map) return Map<String, dynamic>.from(user);
      return Map<String, dynamic>.from(result);
    }
    return <String, dynamic>{};
  }

  static Future<bool> sendChatMessage(
    String chatId, {
    String text = '',
    List<String> listImages = const [],
  }) async {
    if (chatId.isEmpty) return false;
    final r = await _request(
      'POST',
      '/api/app/chats/$chatId/messages',
      body: {
        'text': text,
        'list_images': listImages,
      },
    );
    return r != null && r['_ok'] == true;
  }

  static Future<Map<String, dynamic>?> fetchUserPublic(String uid) async {
    if (uid.isEmpty) return null;
    final r = await _request('GET', '/api/app/users/$uid/public');
    if (r == null || r['_ok'] != true) return null;
    final user = r['user'];
    if (user is! Map) return null;
    return Map<String, dynamic>.from(user);
  }

  static Future<Map<String, dynamic>?> createReview(
    Map<String, dynamic> body,
  ) async {
    final r = await _request('POST', '/api/app/reviews', body: body);
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return <String, dynamic>{};
  }

  static Future<List<Map<String, dynamic>>> listReviews({
    String? aboutUserId,
    bool mine = false,
    int limit = 100,
  }) async {
    final q = StringBuffer('/api/app/reviews?limit=$limit');
    if (mine) {
      q.write('&mine=true');
    } else if (aboutUserId != null && aboutUserId.isNotEmpty) {
      q.write('&user_id=$aboutUserId');
    } else {
      throw StateError('listReviews: user_id or mine required');
    }
    final r = await _request('GET', q.toString());
    if (r == null || r['_ok'] != true) {
      throw StateError('listReviews failed');
    }
    final reviews = r['reviews'];
    if (reviews is! List) return const [];
    return reviews
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>?> createVerification(
    Map<String, dynamic> body,
  ) async {
    final r = await _request('POST', '/api/app/verifications', body: body);
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return <String, dynamic>{};
  }

  static Future<int> verificationCountMine() async {
    final r = await _request('GET', '/api/app/verifications/exists');
    if (r == null || r['_ok'] != true) {
      throw StateError('verificationCountMine failed');
    }
    final c = r['count'];
    if (c is int) return c;
    return int.tryParse('$c') ?? 0;
  }

  static Future<List<Map<String, dynamic>>> listVerifications({
    String? status,
    int limit = 100,
  }) async {
    final q = StringBuffer('/api/app/verifications?limit=$limit');
    if (status != null && status.isNotEmpty) {
      q.write('&status=$status');
    }
    final r = await _request('GET', q.toString());
    if (r == null || r['_ok'] != true) {
      throw StateError('listVerifications failed');
    }
    final rows = r['verifications'];
    if (rows is! List) return const [];
    return rows
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>?> getVerification(String id) async {
    if (id.isEmpty) return null;
    final r = await _request('GET', '/api/app/verifications/$id');
    if (r == null || r['_ok'] != true) return null;
    final v = r['verification'];
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  static Future<bool> approveVerification(String id) async {
    if (id.isEmpty) return false;
    final r = await _request('POST', '/api/app/verifications/$id/approve');
    return r != null && r['_ok'] == true;
  }

  static Future<bool> rejectVerification(String id) async {
    if (id.isEmpty) return false;
    final r = await _request('POST', '/api/app/verifications/$id/reject');
    return r != null && r['_ok'] == true;
  }

  static Future<bool> addAddress(Map<String, dynamic> address) async {
    final r = await _request(
      'POST',
      '/api/app/me/addresses/add',
      body: {'address': address},
    );
    return r != null && r['_ok'] == true;
  }

  static Future<bool> removeAddress(Map<String, dynamic> address) async {
    final r = await _request(
      'POST',
      '/api/app/me/addresses/remove',
      body: {'address': address},
    );
    return r != null && r['_ok'] == true;
  }

  static Future<List<Map<String, dynamic>>> listCards() async {
    final r = await _request('GET', '/api/app/cards');
    if (r == null || r['_ok'] != true) {
      throw StateError('listCards failed');
    }
    final cards = r['cards'];
    if (cards is! List) return const [];
    return cards
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>?> createCard({
    required String pan,
    String kind = 'payout',
    String? rebillId,
  }) async {
    final r = await _request(
      'POST',
      '/api/app/cards',
      body: {
        'pan': pan,
        'kind': kind,
        if (rebillId != null && rebillId.isNotEmpty) 'rebill_id': rebillId,
      },
    );
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return <String, dynamic>{};
  }

  static Future<bool> deleteCard(String id) async {
    if (id.isEmpty) return false;
    final r = await _request('DELETE', '/api/app/cards/$id');
    return r != null && r['_ok'] == true;
  }

  static Future<bool> shiftStart() async {
    final r = await _request('POST', '/api/app/me/shift/start');
    return r != null && r['_ok'] == true;
  }

  static Future<Map<String, dynamic>?> shiftEnd() async {
    final r = await _request('POST', '/api/app/me/shift/end');
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return <String, dynamic>{};
  }

  static Future<bool> applyLateCommissionFine() async {
    final r = await _request('POST', '/api/app/me/fine/late-commission');
    return r != null && r['_ok'] == true;
  }

  static Future<bool> clearFine() async {
    final r = await _request('POST', '/api/app/me/fine/clear');
    return r != null && r['_ok'] == true;
  }

  static Future<Map<String, dynamic>?> completeOrder(String orderId) async {
    if (orderId.isEmpty) return null;
    final r = await _request('POST', '/api/app/orders/$orderId/complete');
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return <String, dynamic>{};
  }

  static Future<bool> setOrderStatus(
    String orderId,
    String status, {
    Map<String, dynamic>? extra,
  }) async {
    final body = <String, dynamic>{'status': status, ...?extra};
    final r = await _request('POST', '/api/app/orders/$orderId/status', body: body);
    return r != null && r['_ok'] == true;
  }

  static Future<bool> acceptBid(
    String orderId, {
    required String driverUid,
    int? price,
    num? commissionPercent,
  }) async {
    final r = await _request(
      'POST',
      '/api/app/orders/$orderId/accept-bid',
      body: {
        'driver_uid': driverUid,
        if (price != null) 'price': price,
        if (commissionPercent != null) 'commission_percent': commissionPercent,
      },
    );
    return r != null && r['_ok'] == true;
  }

  static Future<Map<String, dynamic>?> dequeueOrder(
    String orderId, {
    bool advance = true,
  }) async {
    if (orderId.isEmpty) return null;
    final r = await _request(
      'POST',
      '/api/app/orders/$orderId/dequeue',
      body: {'advance': advance},
    );
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return <String, dynamic>{};
  }

  static Future<bool> cancelOrder(String orderId) async {
    if (orderId.isEmpty) return false;
    final r = await _request('POST', '/api/app/orders/$orderId/cancel');
    return r != null && r['_ok'] == true;
  }

  static Future<bool> hideOrder(String orderId, {bool unhide = false}) async {
    if (orderId.isEmpty) return false;
    final r = await _request(
      'POST',
      '/api/app/orders/$orderId/hide',
      body: {'unhide': unhide},
    );
    return r != null && r['_ok'] == true;
  }

  static Future<bool> pingOrderGeo(
    String orderId, {
    required double lat,
    required double lng,
    String? timeLeft,
    String? kmLeft,
  }) async {
    if (orderId.isEmpty) return false;
    final r = await _request(
      'POST',
      '/api/app/orders/$orderId/geo',
      body: {
        'lat': lat,
        'lng': lng,
        if (timeLeft != null) 'time_left': timeLeft,
        if (kmLeft != null) 'km_left': kmLeft,
      },
    );
    return r != null && r['_ok'] == true;
  }

  static Future<bool> pingMeLocation({
    required double lat,
    required double lng,
  }) async {
    final r = await _request(
      'POST',
      '/api/app/me/location',
      body: {'lat': lat, 'lng': lng},
    );
    return r != null && r['_ok'] == true;
  }

  static Future<Map<String, dynamic>?> getOrder(String orderId) async {
    if (orderId.isEmpty) return null;
    final r = await _request('GET', '/api/app/orders/$orderId');
    if (r == null || r['_ok'] != true) return null;
    final order = r['order'];
    if (order is Map) return Map<String, dynamic>.from(order);
    return null;
  }

  static Future<bool> patchOrder(
    String orderId,
    Map<String, dynamic> body,
  ) async {
    if (orderId.isEmpty) return false;
    final r = await _request('PATCH', '/api/app/orders/$orderId', body: body);
    return r != null && r['_ok'] == true;
  }

  static Future<String?> ensureSupportChat() async {
    final r = await _request(
      'POST',
      '/api/app/chats/ensure',
      body: {'support': true},
    );
    if (r == null || r['_ok'] != true) return null;
    final chat = r['chat'];
    if (chat is Map && chat['id'] != null) return chat['id'].toString();
    return null;
  }

  static Future<String?> ensurePeerChat(String peerUid) async {
    if (peerUid.isEmpty) return null;
    final r = await _request(
      'POST',
      '/api/app/chats/ensure',
      body: {'peer_uid': peerUid},
    );
    if (r == null || r['_ok'] != true) return null;
    final chat = r['chat'];
    if (chat is Map && chat['id'] != null) return chat['id'].toString();
    return null;
  }

  static Future<List<Map<String, dynamic>>> listChats({bool? support}) async {
    final q = support == null
        ? ''
        : '?support=${support ? 'true' : 'false'}';
    final r = await _request('GET', '/api/app/chats$q');
    if (r == null || r['_ok'] != true) return const [];
    final chats = r['chats'];
    if (chats is! List) return const [];
    return chats
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> body) async {
    final r = await _request('POST', '/api/app/orders/create', body: body);
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return null;
  }

  static Future<List<Map<String, dynamic>>> ordersFeed({String status = 'newOrder'}) async {
    final r = await _request('GET', '/api/app/orders/feed?status=$status');
    if (r == null || r['_ok'] != true) return const [];
    final orders = r['orders'];
    if (orders is! List) return const [];
    return orders
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> ordersMine({
    required String role,
    String? status,
    int limit = 50,
  }) async {
    final q = StringBuffer('/api/app/orders/mine?role=$role&limit=$limit');
    if (status != null && status.isNotEmpty) {
      q.write('&status=$status');
    }
    final r = await _request('GET', q.toString());
    if (r == null || r['_ok'] != true) return const [];
    final orders = r['orders'];
    if (orders is! List) return const [];
    return orders
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>?> createBid(
    String orderId, {
    required String text,
    required int? price,
    String time = '',
    String distance = '',
  }) async {
    final r = await _request(
      'POST',
      '/api/app/orders/$orderId/bids',
      body: {
        'text': text,
        'price': price,
        'time': time,
        'distance': distance,
      },
    );
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return <String, dynamic>{};
  }

  static Future<List<Map<String, dynamic>>> listBids(String orderId) async {
    if (orderId.isEmpty) return const [];
    final r = await _request('GET', '/api/app/orders/$orderId/bids');
    if (r == null || r['_ok'] != true) return const [];
    final bids = r['bids'];
    if (bids is! List) return const [];
    return bids
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<bool> deleteBid(String orderId, String bidId) async {
    final r = await _request('DELETE', '/api/app/orders/$orderId/bids/$bidId');
    return r != null && r['_ok'] == true;
  }

  static Future<bool> registerFcm(String token) async {
    final r = await _request('POST', '/api/app/me/fcm', body: {'token': token});
    return r != null && r['_ok'] == true;
  }

  static Future<bool> sendPush({
    required String title,
    required String text,
    required List<String> userIds,
    Map<String, dynamic>? data,
    String? initialPageName,
    String? parameterData,
  }) async {
    if (userIds.isEmpty) return false;
    final r = await _request(
      'POST',
      '/api/app/push',
      body: {
        'user_ids': userIds,
        'title': title,
        'text': text,
        if (data != null) 'data': data,
        if (initialPageName != null && initialPageName.isNotEmpty)
          'initial_page_name': initialPageName,
        if (parameterData != null && parameterData.isNotEmpty)
          'parameter_data': parameterData,
      },
    );
    return r != null && r['_ok'] == true;
  }

  static Future<Map<String, dynamic>?> getPayment(String payId) async {
    final r = await _request('GET', '/api/app/payments/$payId');
    if (r == null || r['_ok'] != true) return null;
    final payment = r['payment'];
    if (payment is Map) return Map<String, dynamic>.from(payment);
    return null;
  }

  static Future<Map<String, dynamic>?> createPayment(Map<String, dynamic> body) async {
    final r = await _request('POST', '/api/app/payments', body: body);
    if (r == null || r['_ok'] != true) return null;
    final result = r['result'];
    if (result is Map) return Map<String, dynamic>.from(result);
    return null;
  }

  static Future<bool> patchPayment(String payId, Map<String, dynamic> body) async {
    final token = await _idToken();
    if (token == null) return false;
    final uri = Uri.parse(PaymentsApiConfig.path('/api/app/payments/$payId'));
    try {
      final resp = await http
          .patch(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (e) {
      // ignore: avoid_print
      print('[AppMeApi] patchPayment FAIL $e');
      return false;
    }
  }
}

/// Кэш профиля с API (поверх/вместо устаревшего FS balance).
AppMe? appMeCache;

class AppMe {
  const AppMe({
    required this.id,
    required this.balance,
    required this.bonusBalance,
    this.displayName,
    this.phoneNumber,
    this.isDriver,
    this.onShift,
    this.source,
    this.currentCommision,
    this.fine,
    this.activeOrdersQueue = const [],
  });

  final String id;
  final double balance;
  final double bonusBalance;
  final String? displayName;
  final String? phoneNumber;
  final bool? isDriver;
  final bool? onShift;
  final String? source;
  final double? currentCommision;
  final bool? fine;
  final List<String> activeOrdersQueue;

  factory AppMe.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse('$v') ?? 0;
    }

    final queueRaw = json['active_orders_queue'] ?? json['activeOrdersQueue'];
    final queue = <String>[];
    if (queueRaw is List) {
      for (final x in queueRaw) {
        final s = x?.toString() ?? '';
        if (s.isNotEmpty) queue.add(s);
      }
    }

    return AppMe(
      id: '${json['id'] ?? ''}',
      balance: asDouble(json['balance']),
      bonusBalance: asDouble(json['bonus_balance'] ?? json['bonusBalance']),
      displayName:
          json['display_name']?.toString() ?? json['displayName']?.toString(),
      phoneNumber:
          json['phone_number']?.toString() ?? json['phoneNumber']?.toString(),
      isDriver: json['is_driver'] is bool
          ? json['is_driver'] as bool
          : json['isDriver'] is bool
              ? json['isDriver'] as bool
              : null,
      onShift: json['on_shift'] is bool
          ? json['on_shift'] as bool
          : json['onShift'] is bool
              ? json['onShift'] as bool
              : null,
      source: json['_source']?.toString(),
      currentCommision: json['current_commision'] != null
          ? asDouble(json['current_commision'])
          : null,
      fine: json['fine'] is bool ? json['fine'] as bool : null,
      activeOrdersQueue: queue,
    );
  }
}
