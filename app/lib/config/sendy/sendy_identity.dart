// Sendy-owned identity and storage policy. Never import a LocalSend settings file.
import 'package:path/path.dart' as path;

abstract final class SendyIdentity {
  static const developer = 'Metoushela Walker';
  static const applicationId = 'app.sendy.transfer';
  static const version = '0.1.1';
  static const httpPort = 53318;
  static const discoveryPort = 53317;
  static const defaultColorMode = 'yaru';
  static const repository = 'https://github.com/MeganAe/Sendy';

  static String windowsSettingsPath(String roamingAppData) {
    if (roamingAppData.trim().isEmpty || !path.windows.isAbsolute(roamingAppData)) {
      throw ArgumentError('An absolute APPDATA path is required for Sendy settings.');
    }
    return path.windows.join(roamingAppData, 'Sendy', 'settings.json');
  }

  static bool adoptYaru(String? previous) => previous == null || previous == 'localsend';

  /// Fixed allowlist: no device alias, IP, filename, token, certificate or user path.
  static String diagnosticReport({
    required String version,
    required String packageId,
    required String platform,
    required int port,
    required bool running,
    required bool portable,
    required String colorMode,
  }) =>
      'Sendy $version\nDeveloper: $developer\nApplication ID: $packageId\nPlatform: $platform\n'
      'HTTP port: $port\nDiscovery UDP: $discoveryPort\nServer running: $running\nPortable: $portable\nTheme: $colorMode\n'
      'No private keys, PINs, aliases, IP addresses, file names or user paths are included.\n';
}
