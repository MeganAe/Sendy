// Sendy: derive status-bar contrast from the surface actually behind its icons.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class SendySystemBars {
  static SystemUiOverlayStyle statusBarFor(Color background) {
    final luminance = background.computeLuminance();
    final whiteContrast = 1.05 / (luminance + 0.05);
    final blackContrast = (luminance + 0.05) / 0.05;
    final lightIcons = whiteContrast >= blackContrast;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: lightIcons ? Brightness.light : Brightness.dark,
      // iOS uses background brightness; Android uses icon brightness.
      statusBarBrightness: lightIcons ? Brightness.dark : Brightness.light,
      systemStatusBarContrastEnforced: false,
    );
  }
}

/// Re-evaluated with the effective app theme, including automatic dark mode.
/// An AppBar may override this region, so its theme uses the same contrast policy.
class SendyStatusBar extends StatelessWidget {
  final Widget child;
  const SendyStatusBar({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).scaffoldBackgroundColor;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SendySystemBars.statusBarFor(surface),
      child: ColoredBox(color: surface, child: child),
    );
  }
}
