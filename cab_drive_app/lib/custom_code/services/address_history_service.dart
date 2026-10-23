import 'dart:convert';

import '/core/utils/shared_prefs.dart';

/// Запись истории адресов (только устройство, SharedPrefs).
class AddressHistoryEntry {
  const AddressHistoryEntry({
    required this.text,
    this.subtitle = '',
    required this.lat,
    required this.lon,
    this.placeId = '',
    this.ts = 0,
  });

  final String text;
  final String subtitle;
  final double lat;
  final double lon;
  final String placeId;
  final int ts;

  factory AddressHistoryEntry.fromJson(Map<String, dynamic> j) {
    return AddressHistoryEntry(
      text: j['text']?.toString() ?? '',
      subtitle: j['subtitle']?.toString() ?? '',
      lat: (j['lat'] as num?)?.toDouble() ?? 0,
      lon: (j['lon'] as num?)?.toDouble() ?? 0,
      placeId: j['placeId']?.toString() ?? '',
      ts: (j['ts'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'subtitle': subtitle,
        'lat': lat,
        'lon': lon,
        'placeId': placeId,
        'ts': ts,
      };

  /// Дедуп по нормализованному тексту + координатам (~10 м).
  String get dedupKey {
    final t = text
        .toLowerCase()
        .replaceAll('ё', 'е')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return '$t|${lat.toStringAsFixed(4)}|${lon.toStringAsFixed(4)}';
  }
}

class AddressHistoryService {
  AddressHistoryService._();

  static const maxEntries = 10;
  static const maxShown = 8;

  static List<AddressHistoryEntry> entries() {
    List<String> raw;
    try {
      raw = SharedPrefs.recentAddresses;
    } catch (_) {
      return const [];
    }
    final out = <AddressHistoryEntry>[];
    for (final s in raw) {
      try {
        final j = jsonDecode(s);
        if (j is Map<String, dynamic>) {
          final e = AddressHistoryEntry.fromJson(j);
          if (e.text.isNotEmpty) out.add(e);
        }
      } catch (_) {}
    }
    return out;
  }

  /// Сохранить выбор: дубликат поднимается наверх, лимит 10.
  static Future<void> add(AddressHistoryEntry entry) async {
    if (entry.text.trim().isEmpty) return;
    if (entry.lat.abs() < 0.0001 && entry.lon.abs() < 0.0001) return;
    final list = entries();
    list.removeWhere((e) => e.dedupKey == entry.dedupKey);
    list.insert(
      0,
      AddressHistoryEntry(
        text: entry.text,
        subtitle: entry.subtitle,
        lat: entry.lat,
        lon: entry.lon,
        placeId: entry.placeId,
        ts: entry.ts > 0 ? entry.ts : DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (list.length > maxEntries) list.length = maxEntries;
    await _save(list);
  }

  static Future<void> remove(AddressHistoryEntry entry) async {
    final list = entries();
    list.removeWhere((e) => e.dedupKey == entry.dedupKey);
    await _save(list);
  }

  static Future<void> clear() async {
    await SharedPrefs.sharedPreferences
        .remove(SharedPrefsNames.recentAddresses);
  }

  static Future<void> _save(List<AddressHistoryEntry> list) async {
    await SharedPrefs.sharedPreferences.setStringList(
      SharedPrefsNames.recentAddresses,
      list.map((e) => jsonEncode(e.toJson())).toList(growable: false),
    );
  }
}
