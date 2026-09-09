import '/backend/api/app_me_api.dart';
import '/backend/api/users_record_mapper.dart';
import '/backend/backend.dart';

/// Peer UsersRecord: API public profile only (no FS). In-memory cache by uid.
class UsersRecordApi {
  UsersRecordApi._();

  static final Map<String, UsersRecord> _cache = {};
  static final Map<String, Future<UsersRecord>> _inflight = {};

  static void clearCache([String? uid]) {
    if (uid == null) {
      _cache.clear();
      return;
    }
    _cache.remove(uid);
  }

  static Future<UsersRecord> getOnce(DocumentReference ref) {
    final uid = ref.id;
    final cached = _cache[uid];
    if (cached != null) return Future.value(cached);

    final pending = _inflight[uid];
    if (pending != null) return pending;

    final fut = () async {
      try {
        final map = await AppMeApi.fetchUserPublic(uid);
        if (map != null) {
          final rec = UsersRecordMapper.fromMeApi(map);
          _cache[uid] = rec;
          return rec;
        }
      } catch (_) {}
      // Без FS-fallback: при mirror=0 док users часто отсутствует → вечный hang.
      final stub = UsersRecordMapper.fromMeApi({
        'id': uid,
        'display_name': 'Пользователь',
        'surname': '',
        'photo_url': '',
      });
      _cache[uid] = stub;
      return stub;
    }();

    _inflight[uid] = fut;
    return fut.whenComplete(() => _inflight.remove(uid));
  }
}
