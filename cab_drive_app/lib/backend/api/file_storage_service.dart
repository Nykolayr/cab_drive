import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/utils/app_dio.dart';

class FileStorageService {
  /// Загрузка файла на сервер
  /// Возвращает UUID файла или null при ошибке
  static Future<String?> uploadFile(Uint8List bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await AppDio.dio.post(
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

  /// Получение URL для отображения изображения по UUID
  static String getFileUrl(String uuid) {
    return '${AppDio.domain}files/get?uuid=$uuid';
  }

  /// Проверяет, является ли строка Firebase URL (для обратной совместимости)
  static bool isFirebaseUrl(String value) {
    return value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.contains('firebasestorage.googleapis.com');
  }

  /// Получение URL для отображения - поддержка и UUID и старых Firebase URLs
  static String getImageUrl(String uuidOrUrl) {
    if (isFirebaseUrl(uuidOrUrl)) {
      // Старый Firebase URL - возвращаем как есть
      return uuidOrUrl;
    }
    // Новый UUID - формируем URL
    return getFileUrl(uuidOrUrl);
  }

  /// Загрузка нескольких файлов
  /// Возвращает список UUIDs
  static Future<List<String>> uploadFiles(
      List<MapEntry<Uint8List, String>> files,
      ) async {
    final results = await Future.wait(
      files.map((entry) => uploadFile(entry.key, entry.value)),
    );
    return results.where((uuid) => uuid != null).cast<String>().toList();
  }
}
