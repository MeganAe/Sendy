// Regression coverage for the shared Windows/portable settings defect.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/sendy/sendy_identity.dart';
import 'package:localsend_app/util/shared_preferences/shared_preferences_file.dart';
import 'package:localsend_app/util/shared_preferences/shared_preferences_portable.dart';
import 'package:path/path.dart' as path;

void main() {
  test('Windows settings belong exclusively to Sendy', () {
    expect(SendyIdentity.windowsSettingsPath(r'C:\Users\Test\AppData\Roaming'), r'C:\Users\Test\AppData\Roaming\Sendy\settings.json');
    expect(SendyIdentity.windowsSettingsPath(r'C:\Users\Test\AppData\Roaming'), isNot(contains('LocalSend')));
  });
  test('An invalid APPDATA cannot silently select a relative directory', () {
    expect(() => SendyIdentity.windowsSettingsPath(''), throwsArgumentError);
    expect(() => SendyIdentity.windowsSettingsPath('relative'), throwsArgumentError);
  });
  test('Portable data cannot collide with the upstream settings.json', () {
    expect(buildSettingsPath(executablePath: '/tmp/shared/sendy', fallbackDirectory: () => '/tmp'), path.join('/tmp/shared', 'sendy-settings.json'));
  });
  test('HTTP is separate, but discovery remains on the common multicast port', () {
    expect(SendyIdentity.httpPort, 53318);
    expect(SendyIdentity.discoveryPort, 53317);
    expect(SendyIdentity.httpPort, isNot(SendyIdentity.discoveryPort));
  });
  test('Yaru becomes the default without replacing an explicitly custom theme', () {
    expect(SendyIdentity.defaultColorMode, 'yaru');
    expect(SendyIdentity.adoptYaru(null), isTrue);
    expect(SendyIdentity.adoptYaru('localsend'), isTrue);
    for (final mode in ['yaru', 'custom', 'system', 'oled']) {
      expect(SendyIdentity.adoptYaru(mode), isFalse);
    }
  });
  test('Diagnostic report contains only the declared non-private fields', () {
    final report = SendyIdentity.diagnosticReport(
      version: '0.1.1',
      packageId: SendyIdentity.applicationId,
      platform: 'windows',
      port: 53318,
      running: true,
      portable: false,
      colorMode: 'yaru',
    );
    expect(report, contains('Metoushela Walker'));
    expect(report, contains('HTTP port: 53318'));
    expect(report, isNot(contains('BEGIN PRIVATE KEY')));
    expect(report, isNot(contains('ls_show_token')));
    expect(report, isNot(contains(r'C:\Users')));
  });
  group('Sendy file store', () {
    late Directory temp;
    setUp(() => temp = Directory.systemTemp.createTempSync('sendy-isolation-test-'));
    tearDown(() => temp.deleteSync(recursive: true));
    test('Writes never change a neighbouring LocalSend directory', () async {
      final original = File(path.join(temp.path, 'LocalSend', 'settings.json'));
      original.parent.createSync();
      original.writeAsStringSync('{"keep":"untouched"}');
      final store = SharedPreferencesFile(filePath: path.join(temp.path, 'Sendy', 'settings.json'));
      await store.setValue('String', 'flutter.theme', 'yaru');
      await store.clear();
      expect(original.readAsStringSync(), '{"keep":"untouched"}');
      expect(await store.getAll(), isEmpty);
    });
    test('A previous valid version is backed up; no temporary file remains', () async {
      final file = File(path.join(temp.path, 'sendy-settings.json'));
      final store = SharedPreferencesFile(filePath: file.path);
      await store.setValue('String', 'flutter.theme', 'yaru');
      final previous = file.readAsStringSync();
      await store.setValue('Int', 'flutter.port', 53318);
      expect(File('${file.path}.bak').readAsStringSync(), previous);
      expect(jsonDecode(file.readAsStringSync())['flutter.port'], 53318);
      expect(temp.listSync().where((f) => f.path.contains('.tmp-')), isEmpty);
    });
    test('Malformed preferences are preserved, not silently overwritten', () async {
      final file = File(path.join(temp.path, 'sendy-settings.json'))..writeAsStringSync('{BROKEN');
      final store = SharedPreferencesFile(filePath: file.path);
      await expectLater(store.getAll(), throwsFormatException);
      await expectLater(store.setValue('String', 'flutter.theme', 'yaru'), throwsFormatException);
      expect(file.readAsStringSync(), '{BROKEN');
    });
    test('Removing and clearing settings updates memory and disk together', () async {
      final file = File(path.join(temp.path, 'sendy-settings.json'));
      final store = SharedPreferencesFile(filePath: file.path);
      await store.setValue('Int', 'flutter.port', 53318);
      await store.remove('flutter.port');
      expect(await store.getAll(), isEmpty);
      await store.setValue('String', 'flutter.theme', 'yaru');
      await store.clear();
      expect(await store.getAll(), isEmpty);
      expect(jsonDecode(file.readAsStringSync()), isEmpty);
    });
  });
}
