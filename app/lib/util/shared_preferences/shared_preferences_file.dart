// Modified for Sendy 0.1.1: atomic writes, previous-state backup and no silent corruption reset.
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

const _beautyEncoder = JsonEncoder.withIndent('  ');
const _encoder = JsonEncoder();

class SharedPreferencesFile extends SharedPreferencesStorePlatform {
  final File _file;
  final bool beautify;
  SharedPreferencesFile({required String filePath, this.beautify = false}) : _file = File(filePath);
  late final Map<String, Object> _cache = _getAll();

  bool exists() => _file.existsSync();
  String getPath() => _file.path;

  @override
  Future<bool> clear() async {
    final cache = _cache;
    _write({});
    cache.clear();
    return true;
  }

  @override
  Future<Map<String, Object>> getAll() async => _cache;

  Map<String, Object> _getAll() {
    if (!_file.existsSync()) return {};
    try {
      final decoded = json.decode(_file.readAsStringSync());
      if (decoded is! Map) throw const FormatException('Expected a JSON object');
      return decoded.cast<String, Object>();
    } catch (_) {
      throw FormatException('Invalid Sendy settings at ${_file.path}. The file was preserved; no automatic reset was performed.');
    }
  }

  @override
  Future<bool> remove(String key) async {
    final next = Map<String, Object>.from(_cache)..remove(key);
    _write(next);
    _cache
      ..clear()
      ..addAll(next);
    return true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    final next = Map<String, Object>.from(_cache)..[key] = value;
    _write(next);
    _cache
      ..clear()
      ..addAll(next);
    return true;
  }

  void _write(Map<String, dynamic> data) {
    _file.parent.createSync(recursive: true);
    final temporary = File('${_file.path}.tmp-$pid-${DateTime.now().microsecondsSinceEpoch}');
    try {
      temporary.writeAsStringSync((beautify ? _beautyEncoder : _encoder).convert(data), flush: true);
      if (_file.existsSync()) _file.copySync('${_file.path}.bak');
      temporary.renameSync(_file.path);
    } finally {
      if (temporary.existsSync()) temporary.deleteSync();
    }
  }
}
