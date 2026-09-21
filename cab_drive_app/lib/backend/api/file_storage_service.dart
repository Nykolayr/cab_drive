import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/utils/app_dio.dart';

class FileStorageService {
  /// HTTPS через nginx — надёжнее сырого http://IP:5000 с мобильной сети.
  static const String _httpsKekBase = 'https://cab.artean.ru/kek/';

  static Dio get _dio => Dio(
        BaseOptions(
          baseUrl: _httpsKekBase,
          headers: AppDio.headers,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

  /// Загрузка файла на сервер.
  /// Возвращает UUID файла или null при ошибке.
  static Future<String?> uploadFile(Uint8List bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _dio.post(
        'files/upload',
        data: formData,
      );

      if (response.data['status'] == 'ok') {
        return response.data['uuid'] as String?;
      }
      return null;
    } catch (e) {
      print('FileStorageService.uploadFile error: $e');
      return null;
    }
  }

  /// Получение URL для отображения изображения по UUID.
  static String getFileUrl(String uuid) {
    return '${_httpsKekBase}files/get?uuid=$uuid';
  }

  /// Проверяет, является ли строка Firebase URL (для обратной совместимости).
  static bool isFirebaseUrl(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.contains('firebasestorage.googleapis.com');
  }

  /// Получение URL для отображения — UUID и старые Firebase URLs.
  static String getImageUrl(String uuidOrUrl) {
    if (isFirebaseUrl(uuidOrUrl)) {
      return uuidOrUrl;
    }
    return getFileUrl(uuidOrUrl);
  }

  /// Загрузка нескольких файлов. Возвращает список UUID.
  static Future<List<String>> uploadFiles(
    List<MapEntry<Uint8List, String>> files,
  ) async {
    final results = await Future.wait(
      files.map((entry) => uploadFile(entry.key, entry.value)),
    );
    return results.where((uuid) => uuid != null).cast<String>().toList();
  }
}
