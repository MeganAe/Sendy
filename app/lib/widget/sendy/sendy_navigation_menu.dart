// Sendy: secondary actions belong in navigation, not in the file-selection header.
import 'package:flutter/material.dart';

enum _SendyMenuAction { parcels, settings }

class SendyMobileMenu extends StatelessWidget {
  final String parcelsLabel;
  final String settingsLabel;
  final VoidCallback onOpenParcels;
  final VoidCallback onOpenSettings;

  const SendyMobileMenu({
    required this.parcelsLabel,
    required this.settingsLabel,
    required this.onOpenParcels,
    required this.onOpenSettings,
    super.key,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<_SendyMenuAction>(
    tooltip: 'Menu',
    icon: const Icon(Icons.more_vert),
    onSelected: (action) {
      switch (action) {
        case _SendyMenuAction.parcels:
          onOpenParcels();
          break;
        case _SendyMenuAction.settings:
          onOpenSettings();
          break;
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: _SendyMenuAction.parcels,
        child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.inventory_2_outlined), title: Text(parcelsLabel)),
      ),
      PopupMenuItem(
        value: _SendyMenuAction.settings,
        child: ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.settings_outlined), title: Text(settingsLabel)),
      ),
    ],
  );
}

class SendyParcelsRailEntry extends StatelessWidget {
  final bool extended;
  final String label;
  final VoidCallback onOpen;

  const SendyParcelsRailEntry({required this.extended, required this.label, required this.onOpen, super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: extended
        ? SizedBox(
            width: 186,
            child: TextButton.icon(
              onPressed: onOpen,
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              icon: const Icon(Icons.inventory_2_outlined),
              label: Text(label),
            ),
          )
        : IconButton(tooltip: label, onPressed: onOpen, icon: const Icon(Icons.inventory_2_outlined)),
  );
}
