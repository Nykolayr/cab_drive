import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '/backend/api_requests/payments_api_config.dart';

/// WSS клиент чатов (и задел под order.updated).
class AppChatWs {
  AppChatWs._();
  static final AppChatWs instance = AppChatWs._();

  WebSocketChannel? _ch;
  StreamSubscription? _sub;
  String? _uid;
  bool _connecting = false;

  final _incoming = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _incoming.stream;

  final Map<String, List<Map<String, dynamic>>> _history = {};
  final Map<String, StreamController<List<Map<String, dynamic>>>> _chatCtrls = {};
  final Set<String> _historyLoaded = {};

  bool historyReady(String chatId) => _historyLoaded.contains(chatId);

  static String get wsUrl {
    final base = PaymentsApiConfig.baseUrl; // https://cab.artean.ru
    final uri = Uri.parse(base);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return '$scheme://${uri.host}/ws/';
  }

  Future<void> connect() async {
    if (_ch != null || _connecting) return;
    _connecting = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      if (token == null || token.isEmpty) return;

      final ch = WebSocketChannel.connect(Uri.parse(wsUrl));
      _ch = ch;
      _sub = ch.stream.listen(
        _onRaw,
        onError: (e) {
          debugPrint('[AppChatWs] error $e');
          _teardown();
        },
        onDone: () {
          debugPrint('[AppChatWs] done');
          _teardown();
        },
      );
      _send({'t': 'auth', 'p': {'token': token}});
    } catch (e) {
      debugPrint('[AppChatWs] connect FAIL $e');
      _teardown();
    } finally {
      _connecting = false;
    }
  }

  void _teardown() {
    _sub?.cancel();
    _sub = null;
    try {
      _ch?.sink.close();
    } catch (_) {}
    _ch = null;
    _uid = null;
  }

  void _send(Map<String, dynamic> msg) {
    final ch = _ch;
    if (ch == null) return;
    ch.sink.add(jsonEncode(msg));
  }

  void _onRaw(dynamic raw) {
    try {
      final data = jsonDecode(raw is String ? raw : '$raw');
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      _incoming.add(map);
      final t = map['t']?.toString() ?? '';
      final p = map['p'] is Map
          ? Map<String, dynamic>.from(map['p'] as Map)
          : <String, dynamic>{};

      if (t == 'auth.ok') {
        _uid = p['user_id']?.toString();
        return;
      }
      if (t == 'chat.history.ok') {
        final chatId = p['chat_id']?.toString() ?? '';
        final msgs = (p['messages'] is List)
            ? (p['messages'] as List)
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : <Map<String, dynamic>>[];
        _history[chatId] = msgs;
        _historyLoaded.add(chatId);
        _chatCtrls[chatId]?.add(List.from(msgs));
        return;
      }
      if (t == 'chat.new') {
        final chatId = p['chat_id']?.toString() ?? '';
        if (chatId.isEmpty) return;
        final list = _history.putIfAbsent(chatId, () => []);
        // newest first (как FS stream)
        list.removeWhere((m) => m['id'] == p['id']);
        list.insert(0, p);
        _chatCtrls[chatId]?.add(List.from(list));
      }
    } catch (e) {
      debugPrint('[AppChatWs] parse FAIL $e');
    }
  }

  Future<void> subscribeChat(String chatId) async {
    await connect();
    _send({'t': 'chat.subscribe', 'p': {'chat_id': chatId}});
    _send({'t': 'chat.history', 'p': {'chat_id': chatId, 'limit': 50}});
  }

  Stream<List<Map<String, dynamic>>> watchMessages(String chatId) {
    final ctrl = _chatCtrls.putIfAbsent(
      chatId,
      () => StreamController<List<Map<String, dynamic>>>.broadcast(),
    );
    // emit cache
    scheduleMicrotask(() {
      if (_history.containsKey(chatId)) {
        ctrl.add(List.from(_history[chatId]!));
      }
    });
    unawaited(subscribeChat(chatId));
    return ctrl.stream;
  }

  Future<bool> sendMessage(
    String chatId, {
    String text = '',
    List<String> listImages = const [],
  }) async {
    await connect();
    if (_ch == null) return false;
    _send({
      't': 'chat.send',
      'p': {
        'chat_id': chatId,
        'text': text,
        'list_images': listImages,
      },
    });
    return true;
  }

  String? get uid => _uid;
}
