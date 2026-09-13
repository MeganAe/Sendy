// Sendy fork: original brand tokens. Protocol identifiers remain unchanged.
import 'package:flutter/material.dart';

abstract final class SendyBrand {
  static const name = 'Sendy';
  static const midnight = Color(0xFF19345C);
  static const ivory = Color(0xFFF4F1E9);
  static const ink = Color(0xFF202636);
  static const darkSurface = Color(0xFF111B2B);
  static const success = Color(0xFF00856B);
  static const radius = 20.0;

  static ColorScheme scheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return ColorScheme.fromSeed(seedColor: midnight, brightness: brightness).copyWith(
      primary: dark ? const Color(0xFFB0CDF7) : midnight,
      onPrimary: dark ? midnight : Colors.white,
      primaryContainer: dark ? const Color(0xFF233D60) : const Color(0xFFE4EAF2),
      onPrimaryContainer: dark ? const Color(0xFFDCE9FC) : midnight,
      secondary: dark ? const Color(0xFF70D8BA) : success,
      onSecondary: dark ? const Color(0xFF00382C) : Colors.white,
      surface: dark ? darkSurface : ivory,
      onSurface: dark ? const Color(0xFFF1F3F7) : ink,
      onSurfaceVariant: dark ? const Color(0xFFB4C0D1) : const Color(0xFF596273),
      outlineVariant: dark ? const Color(0xFF314056) : const Color(0xFFDEDDE0),
      surfaceTint: Colors.transparent,
    );
  }
}

/// French launch copy, with English fallback for the other existing locales.
/// Existing application strings continue to use the upstream translation system.
class SendyCopy {
  final bool french;
  SendyCopy(BuildContext context) : french = Localizations.localeOf(context).languageCode == 'fr';
  String get headline => french ? 'Qu’est-ce qu’on partage ?' : 'What shall we share?';
  String get desktopHeadline => french ? 'Partage sans détour.' : 'Sharing made simple.';
  String get subtitle => french ? 'Tes fichiers. Tes appareils. Tout simplement.' : 'Your files. Your devices. Simply connected.';
  String get addFiles => french ? 'Ajouter des fichiers' : 'Add files';
  String get dropFiles => french ? 'Glisse tes fichiers ici' : 'Drop your files here';
  String get chooseFiles => french ? 'Choisir des fichiers' : 'Choose files';
  String get dropHint => french ? 'Ou sélectionne-les sur ton appareil.' : 'Or choose them from your device.';
  String get ready => french ? 'Prêt à recevoir' : 'Ready to receive';
  String get nearbyHint => french ? 'Connecte tes appareils au même réseau local.' : 'Connect your devices to the same local network.';
  String get receiveHint =>
      french ? 'Garde Sendy ouvert. Tu pourras accepter ou refuser chaque demande.' : 'Keep Sendy open. You can accept or decline each request.';
  String get quickReceiveHint =>
      french ? 'Réception automatique activée. Vérifie tes réglages de réception.' : 'Automatic receiving is enabled. Check your receive settings.';
  String get history => french ? 'Historique' : 'History';
  String get tagline => french ? 'Simplement, partager.' : 'Simply, share.';
}
