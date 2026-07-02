// Синхронизирует ключи из .env в Android local.properties и iOS Info.plist.
// Запуск: dart run tool/sync_env.dart
import 'dart:io';

void main() {
  final root = _projectRoot();
  final envFile = File('${root.path}${Platform.pathSeparator}.env');
  if (!envFile.existsSync()) {
    stderr.writeln(
      'sync_env: нет .env — скопируй .env.example → .env в ${root.path}',
    );
    exit(1);
  }

  final env = _parseEnv(envFile.readAsStringSync());
  final mapkit = env['YANDEX_MAPKIT_KEY'] ?? '';
  if (mapkit.isEmpty) {
    stderr.writeln('sync_env: YANDEX_MAPKIT_KEY пустой в .env');
    exit(1);
  }

  _syncAndroidLocalProperties(root, mapkit);
  _syncIosInfoPlist(root, mapkit);

  stdout.writeln('sync_env: OK (Android + iOS MapKit key)');
}

Directory _projectRoot() {
  var dir = Directory.current;
  if (File('${dir.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
    return dir;
  }
  final parent = dir.parent;
  if (File('${parent.path}${Platform.pathSeparator}pubspec.yaml').existsSync()) {
    return parent;
  }
  return dir;
}

Map<String, String> _parseEnv(String raw) {
  final map = <String, String>{};
  for (final line in raw.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final eq = trimmed.indexOf('=');
    if (eq <= 0) continue;
    map[trimmed.substring(0, eq).trim()] =
        trimmed.substring(eq + 1).trim();
  }
  return map;
}

void _syncAndroidLocalProperties(Directory root, String mapkitKey) {
  final file = File(
    '${root.path}${Platform.pathSeparator}android${Platform.pathSeparator}local.properties',
  );
  final lines = file.existsSync()
      ? file.readAsLinesSync()
      : <String>[];
  final out = <String>[];
  var hasKey = false;
  for (final line in lines) {
    if (line.startsWith('yandex.maps.api.key=')) {
      out.add('yandex.maps.api.key=$mapkitKey');
      hasKey = true;
    } else {
      out.add(line);
    }
  }
  if (!hasKey) {
    if (out.isNotEmpty && out.last.isNotEmpty) out.add('');
    out.add('yandex.maps.api.key=$mapkitKey');
  }
  file.writeAsStringSync('${out.join('\n')}\n');
}

void _syncIosInfoPlist(Directory root, String mapkitKey) {
  final file = File(
    '${root.path}${Platform.pathSeparator}ios${Platform.pathSeparator}Runner${Platform.pathSeparator}Info.plist',
  );
  if (!file.existsSync()) {
    stderr.writeln('sync_env: Info.plist не найден, iOS пропущен');
    return;
  }
  var content = file.readAsStringSync();
  const keyTag = '<key>YandexMapsAPIKey</key>';
  final keyIdx = content.indexOf(keyTag);
  if (keyIdx < 0) {
    stderr.writeln('sync_env: YandexMapsAPIKey не найден в Info.plist');
    return;
  }
  final afterKey = content.indexOf('<string>', keyIdx);
  final endString = content.indexOf('</string>', afterKey);
  if (afterKey < 0 || endString < 0) return;

  final before = content.substring(0, afterKey + '<string>'.length);
  final after = content.substring(endString);
  content = '$before$mapkitKey$after';
  file.writeAsStringSync(content);
}
