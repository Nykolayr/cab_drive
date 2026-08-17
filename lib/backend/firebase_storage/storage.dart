import 'dart:typed_data';
import '../api/file_storage_service.dart';

/// Загрузка файла на сервер
/// Возвращает URL для отображения файла или null при ошибке
/// (Ранее использовался Firebase Storage, теперь собственный бэкенд)
Future<String?> uploadData(String path, Uint8List data) async {
  final filename = path.split('/').last;
  final uuid = await FileStorageService.uploadFile(data, filename);
  if (uuid == null) return null;
  return FileStorageService.getFileUrl(uuid);
}
