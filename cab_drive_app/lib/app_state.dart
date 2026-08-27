import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';
import '/core/utils/app_dio.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      _phone = await secureStorage.getString('ff_phone') ?? _phone;
    });
    await _safeInitAsync(() async {
      _OTP = await secureStorage.getString('ff_OTP') ?? _OTP;
    });
    await _safeInitAsync(() async {
      _Password = await secureStorage.getString('ff_Password') ?? _Password;
    });
    await _safeInitAsync(() async {
      _driver = await secureStorage.getBool('ff_driver') ?? _driver;
    });
    await _safeInitAsync(() async {
      _roleSelected = await secureStorage.getBool('ff_roleSelected') ?? _roleSelected;
    });
    await _safeInitAsync(() async {
      _mskGeo = latLngFromString(await secureStorage.getString('ff_mskGeo')) ??
          _mskGeo;
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_filter') != null) {
        try {
          final serializedData =
              await secureStorage.getString('ff_filter') ?? '{}';
          _filter =
              FiltersStruct.fromSerializableMap(jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    await _safeInitAsync(() async {
      _payMethod = await secureStorage.read(key: 'ff_payMethod') != null
          ? deserializeEnum<PayMethod>(
              (await secureStorage.getString('ff_payMethod')))
          : _payMethod;
    });
    await _safeInitAsync(() async {
      if (await secureStorage.read(key: 'ff_card') != null) {
        try {
          final serializedData =
              await secureStorage.getString('ff_card') ?? '{}';
          _card = CardStruct.fromSerializableMap(jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  String _phone = '';
  String get phone => _phone;
  set phone(String value) {
    _phone = value;
    secureStorage.setString('ff_phone', value);
  }

  void deletePhone() {
    secureStorage.delete(key: 'ff_phone');
  }

  String _OTP = '';
  String get OTP => _OTP;
  set OTP(String value) {
    _OTP = value;
    secureStorage.setString('ff_OTP', value);
  }

  void deleteOTP() {
    secureStorage.delete(key: 'ff_OTP');
  }

  String _Password = '';
  String get Password => _Password;
  set Password(String value) {
    _Password = value;
    secureStorage.setString('ff_Password', value);
  }

  void deletePassword() {
    secureStorage.delete(key: 'ff_Password');
  }

  bool _driver = false;
  bool get driver => _driver;
  set driver(bool value) {
    _driver = value;
    secureStorage.setBool('ff_driver', value);
  }

  void deleteDriver() {
    secureStorage.delete(key: 'ff_driver');
  }

  bool _roleSelected = false;
  bool get roleSelected => _roleSelected;
  set roleSelected(bool value) {
    _roleSelected = value;
    secureStorage.setBool('ff_roleSelected', value);
    debugPrint('[FFAppState] roleSelected set to: $value');
  }

  void deleteRoleSelected() {
    secureStorage.delete(key: 'ff_roleSelected');
  }

  String _selfi = '';
  String get selfi => _selfi;
  set selfi(String value) {
    _selfi = value;
  }

  LatLng? _mskGeo = LatLng(55.755826, 37.6173);
  LatLng? get mskGeo => _mskGeo;
  set mskGeo(LatLng? value) {
    _mskGeo = value;
    value != null
        ? secureStorage.setString('ff_mskGeo', value.serialize())
        : secureStorage.remove('ff_mskGeo');
  }

  void deleteMskGeo() {
    secureStorage.delete(key: 'ff_mskGeo');
  }

  PointStruct _pointA = PointStruct();
  PointStruct get pointA => _pointA;
  set pointA(PointStruct value) {
    _pointA = value;
  }

  void updatePointAStruct(Function(PointStruct) updateFn) {
    updateFn(_pointA);
  }

  PointStruct _pointB = PointStruct();
  PointStruct get pointB => _pointB;


  List<LatLng> get points => [pointA.latlng!,
    if (pointC.latlng != null) pointC.latlng!,
    pointB.latlng!, ];

  set pointB(PointStruct value) {
    _pointB = value;
  }

  void updatePointBStruct(Function(PointStruct) updateFn) {
    updateFn(_pointB);
  }


  PointStruct _pointC = PointStruct();
  PointStruct get pointC => _pointC;

  set pointC(PointStruct value) {
    _pointC = value;
  }

  void updatePointCStruct(Function(PointStruct) updateFn) {
    updateFn(_pointC);
  }

  FiltersStruct _filter = FiltersStruct();
  FiltersStruct get filter => _filter;
  set filter(FiltersStruct value) {
    _filter = value;
    secureStorage.setString('ff_filter', value.serialize());
  }

  void deleteFilter() {
    secureStorage.delete(key: 'ff_filter');
  }

  void updateFilterStruct(Function(FiltersStruct) updateFn) {
    updateFn(_filter);
    secureStorage.setString('ff_filter', _filter.serialize());
  }

  String _distanceTime = '';
  String get distanceTime => _distanceTime;
  set distanceTime(String value) {
    _distanceTime = value;
  }

  int _distanceKm = 0;
  int get distanceKm => _distanceKm;
  set distanceKm(int value) {
    _distanceKm = value;
  }

  int _priceLargus = 0;
  int get priceLargus => _priceLargus;
  set priceLargus(int value) {
    _priceLargus = value;
  }

  int _priceTermo = 0;
  int get priceTermo => _priceTermo;
  set priceTermo(int value) {
    _priceTermo = value;
  }

  int _priceFiat = 0;
  int get priceFiat => _priceFiat;
  set priceFiat(int value) {
    _priceFiat = value;
  }

  int _movers = 0;
  int get movers => _movers;
  set movers(int value) {
    _movers = value;
  }

  PayMethod? _payMethod = PayMethod.cahs;
  PayMethod? get payMethod => _payMethod;
  set payMethod(PayMethod? value) {
    _payMethod = value;
    value != null
        ? secureStorage.setString('ff_payMethod', value.serialize())
        : secureStorage.remove('ff_payMethod');
  }

  void deletePayMethod() {
    secureStorage.delete(key: 'ff_payMethod');
  }

  CardStruct _card = CardStruct();
  CardStruct get card => _card;
  set card(CardStruct value) {
    _card = value;
    secureStorage.setString('ff_card', value.serialize());
  }

  void deleteCard() {
    secureStorage.delete(key: 'ff_card');
  }

  void updateCardStruct(Function(CardStruct) updateFn) {
    updateFn(_card);
    secureStorage.setString('ff_card', _card.serialize());
  }

  // Серверные тайминги (минуты). Источник — GET /kek/settings/get.
  // Дефолты совпадают с дефолтами SiteModel на бэке.
  int _minutesForDeleteOrder = 15;
  int get minutesForDeleteOrder => _minutesForDeleteOrder;

  int _deadlineMinutes = 15;
  int get deadlineMinutes => _deadlineMinutes;

  // Последний центр и зум любой просматриваемой клиентом карты выбора адреса
  // (главный экран создания заказа + MapPicker). Используются чтобы MapPicker
  // открывался в том же месте, где юзер только что смотрел/выбирал.
  LatLng? _lastPickerMapCenter;
  LatLng? get lastPickerMapCenter => _lastPickerMapCenter;
  set lastPickerMapCenter(LatLng? value) {
    _lastPickerMapCenter = value;
  }

  double? _lastPickerMapZoom;
  double? get lastPickerMapZoom => _lastPickerMapZoom;
  set lastPickerMapZoom(double? value) {
    _lastPickerMapZoom = value;
  }

  Future<void> loadServerSettings() async {
    try {
      final res = await AppDio.dio.get('settings/get');
      final data = res.data;
      if (data is Map) {
        final m = data['minutes_for_delete_order'];
        final d = data['deadline_minutes'];
        if (m is num) _minutesForDeleteOrder = m.toInt();
        if (d is num) _deadlineMinutes = d.toInt();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[FFAppState.loadServerSettings] failed: $e');
    }
  }

  final _mychatsManager = StreamRequestManager<List<ChatsRecord>>();
  Stream<List<ChatsRecord>> mychats({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Stream<List<ChatsRecord>> Function() requestFn,
  }) =>
      _mychatsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearMychatsCache() => _mychatsManager.clear();
  void clearMychatsCacheKey(String? uniqueKey) =>
      _mychatsManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
