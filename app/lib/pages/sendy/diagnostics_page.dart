// Sendy diagnostics: explicit local-only checks and an allowlisted shareable report.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localsend_app/config/sendy/sendy_identity.dart';
import 'package:localsend_app/provider/network/server/server_provider.dart';
import 'package:localsend_app/provider/persistence_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/native/open_folder.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:refena_flutter/refena_flutter.dart';

class SendyDiagnosticsPage extends StatefulWidget {
  const SendyDiagnosticsPage({super.key});
  @override
  State<SendyDiagnosticsPage> createState() => _SendyDiagnosticsPageState();
}

class _SendyDiagnosticsPageState extends State<SendyDiagnosticsPage> {
  late final Future<PackageInfo> _package = PackageInfo.fromPlatform();
  bool _checking = false;
  String? _result;

  Future<void> _probe(int port, bool french) async {
    setState(() {
      _checking = true;
      _result = null;
    });
    String result;
    try {
      final socket = await Socket.connect(InternetAddress.loopbackIPv4, port, timeout: const Duration(seconds: 2));
      socket.destroy();
      result = french
          ? 'Un service répond sur le port $port. Ce test TCP seul ne vérifie pas son identité.'
          : 'A service answers on port $port. This TCP check alone does not verify its identity.';
    } catch (_) {
      result = french
          ? 'Aucune connexion locale au port $port. Vérifie si la réception est active.'
          : 'No local connection to port $port. Check whether receiving is enabled.';
    }
    if (mounted)
      setState(() {
        _checking = false;
        _result = result;
      });
  }

  @override
  Widget build(BuildContext context) {
    final french = Localizations.localeOf(context).languageCode == 'fr';
    final settings = context.watch(settingsProvider);
    final server = context.watch(serverProvider);
    final persistence = context.read(persistenceProvider);
    final settingsPath = persistence.getSettingsFilePath();
    return Scaffold(
      appBar: AppBar(title: Text(french ? 'Diagnostic Sendy' : 'Sendy diagnostics')),
      body: FutureBuilder<PackageInfo>(
        future: _package,
        builder: (context, snapshot) {
          final info = snapshot.data;
          return ResponsiveListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(french ? 'Ton installation, en clair.' : 'Understand your installation.', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                french
                    ? 'Le rapport copiable exclut les clés, PIN, adresses IP, noms de fichiers et chemins personnels.'
                    : 'The copyable report excludes keys, PINs, IP addresses, filenames and personal paths.',
              ),
              const SizedBox(height: 24),
              ListTile(leading: const Icon(Icons.person_outline), title: const Text(SendyIdentity.developer), subtitle: const Text('Sendy')),
              ListTile(
                title: Text(info?.packageName ?? '…'),
                subtitle: Text(info == null ? (snapshot.hasError ? 'Version unavailable' : '…') : '${info.version} (${info.buildNumber})'),
              ),
              ListTile(title: Text('HTTP : ${settings.port}'), subtitle: const Text('Multicast UDP : ${SendyIdentity.discoveryPort}')),
              ListTile(
                leading: Icon(server == null ? Icons.cloud_off : Icons.check_circle_outline),
                title: Text(
                  french
                      ? (server == null ? 'Réception inactive' : 'Réception active')
                      : (server == null ? 'Receiving inactive' : 'Receiving active'),
                ),
              ),
              if (settingsPath != null) ...[
                const Divider(),
                Text(french ? 'Réglages sur cet appareil (chemin exclu du rapport)' : 'Settings on this device (path excluded from report)'),
                const SizedBox(height: 8),
                SelectableText(settingsPath),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await openFolder(folderPath: File(settingsPath).parent.path);
                  },
                  icon: const Icon(Icons.folder_open),
                  label: Text(french ? 'Ouvrir les données Sendy' : 'Open Sendy data'),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: info == null
                    ? null
                    : () async {
                        final report = SendyIdentity.diagnosticReport(
                          version: info.version,
                          packageId: info.packageName,
                          platform: Platform.operatingSystem,
                          port: settings.port,
                          running: server != null,
                          portable: persistence.isPortableMode(),
                          colorMode: settings.colorMode.name,
                        );
                        await Clipboard.setData(ClipboardData(text: report));
                        if (context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(french ? 'Rapport copié.' : 'Report copied.')));
                      },
                icon: const Icon(Icons.copy),
                label: Text(french ? 'Copier le rapport de diagnostic' : 'Copy diagnostic report'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _checking
                    ? null
                    : () async {
                        await _probe(server?.port ?? settings.port, french);
                      },
                icon: const Icon(Icons.network_check),
                label: Text(french ? 'Tester le port local' : 'Test local port'),
              ),
              if (_checking) const LinearProgressIndicator(),
              if (_result != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_result!)),
            ],
          );
        },
      ),
    );
  }
}
