import 'package:cab_drive/core/utils/shared_prefs.dart';
import 'package:cab_drive/custom_code/services/address_history_service.dart';
import 'package:cab_drive/custom_code/services/yandex_geocoder_service.dart';
import 'package:cab_drive/customer/create_order/searh_address/address_suggest_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

AddressHistoryEntry _entry(
  String text, {
  double lat = 55.75,
  double lon = 37.61,
  String subtitle = 'Москва',
  String placeId = '',
  int ts = 0,
}) =>
    AddressHistoryEntry(
      text: text,
      subtitle: subtitle,
      lat: lat,
      lon: lon,
      placeId: placeId,
      ts: ts,
    );

String _highlighted(String title, String query) {
  return addressTitleSegments(title, query)
      .where((s) => s.$2)
      .map((s) => s.$1)
      .join();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPrefs.sharedPreferences = await SharedPreferences.getInstance();
  });

  group('AddressHistoryService', () {
    test('add keeps newest first', () async {
      await AddressHistoryService.add(_entry('Улица А, 1', ts: 1));
      await AddressHistoryService.add(_entry('Улица Б, 2', ts: 2));
      final list = AddressHistoryService.entries();
      expect(list.length, 2);
      expect(list.first.text, 'Улица Б, 2');
      expect(list.last.text, 'Улица А, 1');
    });

    test('dedup: same text+coords collapses and bumps to top', () async {
      await AddressHistoryService.add(_entry('Улица А, 1', ts: 1));
      await AddressHistoryService.add(_entry('Улица Б, 2', ts: 2));
      // Регистр/пробелы не должны плодить дубликат.
      await AddressHistoryService.add(_entry('  улица а, 1 ', ts: 3));
      final list = AddressHistoryService.entries();
      expect(list.length, 2);
      expect(list.first.text.trim().toLowerCase(), 'улица а, 1');
      expect(list.first.ts, 3);
    });

    test('limit 10 entries', () async {
      for (var i = 0; i < 15; i++) {
        await AddressHistoryService.add(
          _entry('Улица $i, $i', lat: 55.0 + i * 0.01, ts: i),
        );
      }
      final list = AddressHistoryService.entries();
      expect(list.length, AddressHistoryService.maxEntries);
      expect(list.first.text, 'Улица 14, 14');
    });

    test('remove deletes only the matching entry', () async {
      await AddressHistoryService.add(_entry('Улица А, 1', ts: 1));
      await AddressHistoryService.add(_entry('Улица Б, 2', ts: 2));
      await AddressHistoryService.remove(_entry('Улица А, 1'));
      final list = AddressHistoryService.entries();
      expect(list.length, 1);
      expect(list.first.text, 'Улица Б, 2');
    });

    test('clear empties history', () async {
      await AddressHistoryService.add(_entry('Улица А, 1', ts: 1));
      await AddressHistoryService.clear();
      expect(AddressHistoryService.entries(), isEmpty);
    });

    test('rejects entry without text or coords', () async {
      await AddressHistoryService.add(_entry('', ts: 1));
      await AddressHistoryService.add(_entry('Ноль', lat: 0, lon: 0, ts: 2));
      expect(AddressHistoryService.entries(), isEmpty);
    });
  });

  group('keepAddressSuggestion (soft filter)', () {
    // Реальные ответы Geosuggest на «1 ду», «1 дуб», «1 дубровская ул 14/1».
    const street = YandexGeocodeResult(
      lat: 0,
      lon: 0,
      text: 'Москва, 1-я Дубровская улица',
      street: '1-я Дубровская улица',
      kind: 'street',
      titleOverride: '1-я Дубровская улица',
    );
    const house = YandexGeocodeResult(
      lat: 0,
      lon: 0,
      text: 'Москва, 1-я Дубровская улица, 14к1',
      street: '1-я Дубровская улица',
      house: '14к1',
      kind: 'house',
      titleOverride: '1-я Дубровская улица, 14к1',
    );
    const bareHouse = YandexGeocodeResult(
      lat: 0,
      lon: 0,
      text: '14к1',
      house: '14к1',
      kind: 'house',
    );

    test('street and house pass for prefix queries', () {
      for (final q in ['1 ду', '1 дуб', '1 дубровская ул 14/1']) {
        expect(
          YandexGeocoderService.keepAddressSuggestion(street),
          isTrue,
          reason: 'street must pass for "$q"',
        );
        expect(
          YandexGeocoderService.keepAddressSuggestion(house),
          isTrue,
          reason: 'house must pass for "$q"',
        );
        expect(
          YandexGeocoderService.keepAddressSuggestion(bareHouse),
          isTrue,
          reason: 'bare house must pass for "$q"',
        );
      }
    });

    test('locality and empty garbage are rejected', () {
      const locality = YandexGeocodeResult(
        lat: 0,
        lon: 0,
        text: 'Москва',
        city: 'Москва',
        kind: 'locality',
      );
      const garbage = YandexGeocodeResult(lat: 0, lon: 0, text: 'x');
      expect(YandexGeocoderService.keepAddressSuggestion(locality), isFalse);
      expect(YandexGeocoderService.keepAddressSuggestion(garbage), isFalse);
    });
  });

  group('addressTitleSegments (highlight)', () {
    test('highlights normalized query tokens as word prefixes', () {
      // Подсвечена только введённая часть: «1» в «1-я», «ул» в «улица»,
      // «14» в «14к1» (токен «1» короче «14» — берётся самый длинный).
      final hi =
          _highlighted('1-я Дубровская улица, 14к1', '1 дубровская ул 14/1');
      expect(hi, '1Дубровскаяул14');
      // Дефис, «я», разделители и остаток слова не подсвечиваются.
      final segs =
          addressTitleSegments('1-я Дубровская улица, 14к1', '1 дубровская');
      expect(segs.any((s) => s.$1 == '-' && s.$2), isFalse);
      expect(segs.any((s) => s.$1 == 'я' && s.$2), isFalse);
      expect(segs.any((s) => s.$1 == ', ' && s.$2), isFalse);
      // Введённая часть слова: «дуб» → «Дуб»ровская.
      expect(_highlighted('Дубровская', '1 дуб'), 'Дуб');
    });

    test('empty query → no highlight', () {
      final segs = addressTitleSegments('Улица, 1', '');
      expect(segs.every((s) => !s.$2), isTrue);
    });

    test('no match → no highlight', () {
      final hi = _highlighted('Ленина, 5', 'дубровская');
      expect(hi, isEmpty);
    });
  });
}
