import 'dart:typed_data';
import '../api/file_storage_service.dart';

/// Загрузка файла на сервер
/// Возвращает UUID файла или null при ошибке
/// (Ранее использовался Firebase Storage, теперь собственный бэкенд)
Future<String?> uploadData(String path, Uint8List data) async {
  // Извлекаем имя файла из path
  final filename = path.split('/').last;
  return FileStorageService.uploadFile(data, filename);
}
