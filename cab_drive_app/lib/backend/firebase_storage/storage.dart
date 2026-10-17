import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../api/file_storage_service.dart';

const int _targetBytes = 950 * 1024;

/// Сжимает фото до ~1 МБ: JPEG quality 85→40, при необходимости уменьшает стороны.
/// Не-изображения и нечитаемые форматы возвращает как есть.
Uint8List compressToLimit(Uint8List data) {
  if (data.length <= _targetBytes) return data;
  img.Image? decoded;
  try {
    decoded = img.decodeImage(data);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) return data;

  Uint8List best = data;
  for (final maxSide in [2048, 1600, 1280]) {
    var cur = decoded;
    if (cur.width > maxSide || cur.height > maxSide) {
      cur = img.copyResize(
        cur,
        width: cur.width >= cur.height ? maxSide : null,
        height: cur.height > cur.width ? maxSide : null,
      );
    }
    for (final q in [85, 70, 55, 40]) {
      final out = img.encodeJpg(cur, quality: q);
      if (out.length < best.length) best = out;
      if (out.length <= _targetBytes) return out;
    }
  }
  return best;
}

/// Загрузка файла на сервер
/// Возвращает URL для отображения файла или null при ошибке
/// (Ранее использовался Firebase Storage, теперь собственный бэкенд)
Future<String?> uploadData(String path, Uint8List data) async {
  var filename = path.split('/').last;
  final compressed = compressToLimit(data);
  if (!identical(compressed, data) && !filename.toLowerCase().endsWith('.jpg')) {
    filename = '${filename.split('.').first}.jpg';
  }
  final uuid = await FileStorageService.uploadFile(compressed, filename);
  if (uuid == null) return null;
  return FileStorageService.getFileUrl(uuid);
}
