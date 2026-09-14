// Sendy development: reusable selections, without copying the referenced files.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localsend_app/model/cross_file.dart';
import 'package:localsend_app/model/sendy/parcel.dart';
import 'package:localsend_app/provider/selection/selected_sending_files_provider.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:localsend_isolates/util/file_path_helper.dart';
import 'package:localsend_isolates/util/file_size_helper.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uri_content/uri_content.dart';
import 'package:uuid/uuid.dart';

class SendyParcelsPage extends StatefulWidget {
  const SendyParcelsPage({super.key});

  @override
  State<SendyParcelsPage> createState() => _SendyParcelsPageState();
}

class _SendyParcelsPageState extends State<SendyParcelsPage> {
  static const _key = 'sendy_parcels_v1';
  List<SendyParcel>? _parcels;
  bool _busy = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final parcels = SendyParcel.decodeLibrary(prefs.getString(_key));
      if (mounted)
        setState(() {
          _parcels = parcels;
          _loadError = null;
        });
    } catch (_) {
      if (mounted) setState(() => _loadError = 'Impossible de lire les colis. Les données ont été conservées sans réinitialisation.');
    }
  }

  void _message(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _save(List<SendyParcel> parcels) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_key, SendyParcel.encodeLibrary(parcels))) {
      throw const FileSystemException('Parcel save failed');
    }
    if (mounted) setState(() => _parcels = parcels);
  }

  Future<void> _create() async {
    final selected = List<CrossFile>.of(context.read(selectedSendingFilesProvider));
    if (selected.isEmpty) {
      _message('Sélectionne d’abord tes fichiers dans Envoyer.');
      return;
    }
    if (selected.any((file) => file.path == null || file.path!.isEmpty || file.size < 0)) {
      _message('Le colis exige des fichiers référencés sur l’appareil. Retire les textes et contenus en mémoire ; utilise la note du colis.');
      return;
    }
    final details = await showDialog<(String, String)>(context: context, builder: (_) => const _ParcelDetailsDialog());
    if (details == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final parcel = SendyParcel(
        id: const Uuid().v4(),
        title: details.$1,
        note: details.$2,
        createdAt: DateTime.now(),
        entries: selected.map((file) => ParcelEntry(name: file.name, reference: file.path!, size: file.size)).toList(),
      );
      await _save([..._parcels!, parcel]);
      _message('Colis enregistré sans copie. Garde les fichiers à leur emplacement.');
    } catch (_) {
      _message('Impossible d’enregistrer ce colis. La sélection est conservée.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _use(SendyParcel parcel) async {
    setState(() => _busy = true);
    try {
      final files = <CrossFile>[];
      final inaccessible = <String>[];
      final changed = <String>[];
      for (final entry in parcel.entries) {
        try {
          final int? size;
          if (entry.reference.startsWith('content://')) {
            size = await UriContent().getContentLength(Uri.parse(entry.reference));
          } else {
            final file = File(entry.reference);
            // Opening also checks current permission, without reading the full file.
            final handle = await file.open();
            try {
              size = await handle.length();
            } finally {
              await handle.close();
            }
          }
          if (size == null || size < 0) throw const FileSystemException('Unavailable reference');
          if (size != entry.size) changed.add(entry.name);
          files.add(
            CrossFile(
              name: entry.name,
              fileType: entry.name.guessFileType(),
              size: size,
              thumbnail: null,
              asset: null,
              path: entry.reference,
              bytes: null,
              lastModified: null,
              lastAccessed: null,
            ),
          );
        } catch (_) {
          inaccessible.add(entry.name);
        }
      }
      if (!mounted) return;
      if (inaccessible.isNotEmpty) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Fichiers à retrouver'),
            content: SingleChildScrollView(
              child: Text('Aucun fichier du colis n’a été ajouté. Resélectionne les fichiers et recrée le colis.\n\n${inaccessible.join('\n')}'),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))],
          ),
        );
        return;
      }
      final approved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Charger « ${parcel.title} » ?'),
          content: SingleChildScrollView(
            child: Text(
              '${files.length} fichiers seront ajoutés à ta sélection actuelle. Rien ne sera envoyé automatiquement.\n\n'
              'Les versions actuelles des fichiers seront utilisées : un colis sans copie ne fige pas leur contenu.'
              '${changed.isEmpty ? '' : '\n\nTaille modifiée :\n${changed.join('\n')}'}'
              '${parcel.note.isEmpty ? '' : '\n\nNote envoyée comme texte :\n${parcel.note}'}',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ajouter à la sélection')),
          ],
        ),
      );
      if (approved != true || !mounted) return;
      final selection = context.ref.redux(selectedSendingFilesProvider);
      selection.dispatch(LoadParcelSelectionAction(files));
      if (parcel.note.isNotEmpty) selection.dispatch(AddMessageAction(message: parcel.note));
      _message('Colis chargé. Reviens dans Envoyer et choisis un destinataire.');
    } catch (_) {
      _message('Impossible de charger le colis. Aucun transfert n’a été démarré.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(SendyParcel parcel) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer « ${parcel.title} » ?'),
        content: const Text('Seule la liste du colis sera supprimée. Tes fichiers ne seront pas effacés.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer le colis')),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _save(_parcels!.where((item) => item.id != parcel.id).toList());
    } catch (_) {
      _message('La suppression n’a pas pu être enregistrée.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mes colis')),
    body: ResponsiveListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Prépare une sélection et réutilise-la sans copier tes fichiers.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Les fichiers déplacés, supprimés, temporaires ou devenus inaccessibles devront être resélectionnés. '
          'Les noms, emplacements et notes restent dans les réglages privés de Sendy ; ne publie pas ces réglages.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy || _parcels == null ? null : _create,
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Enregistrer la sélection actuelle'),
        ),
        if (_busy || (_parcels == null && _loadError == null)) const LinearProgressIndicator(),
        if (_loadError != null) Text(_loadError!),
        if (_parcels?.isEmpty == true) const Padding(padding: EdgeInsets.all(24), child: Text('Aucun colis pour le moment.')),
        for (final parcel in _parcels ?? <SendyParcel>[])
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parcel.title, style: Theme.of(context).textTheme.titleLarge),
                  Text('${parcel.entries.length} fichiers · ${parcel.totalSize.asReadableFileSize} à la création'),
                  if (parcel.note.isNotEmpty) Text(parcel.note, maxLines: 3, overflow: TextOverflow.ellipsis),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: _busy ? null : () => _use(parcel),
                        icon: const Icon(Icons.playlist_add_check),
                        label: const Text('Vérifier et charger'),
                      ),
                      TextButton(onPressed: _busy ? null : () => _delete(parcel), child: const Text('Supprimer')),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class _ParcelDetailsDialog extends StatefulWidget {
  const _ParcelDetailsDialog();
  @override
  State<_ParcelDetailsDialog> createState() => _ParcelDetailsDialogState();
}

class _ParcelDetailsDialogState extends State<_ParcelDetailsDialog> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nouveau colis'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            maxLength: 120,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nom du colis'),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            controller: _note,
            maxLength: 4000,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Note à joindre (facultative)'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
      FilledButton(
        onPressed: _title.text.trim().isEmpty ? null : () => Navigator.pop(context, (_title.text.trim(), _note.text.trim())),
        child: const Text('Enregistrer'),
      ),
    ],
  );
}
