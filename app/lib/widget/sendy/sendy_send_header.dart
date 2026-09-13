// Sendy fork: adaptive send header; callbacks use the real file-picker actions.
import 'package:flutter/material.dart';
import 'package:localsend_app/config/sendy/sendy_brand.dart';
import 'package:localsend_app/widget/sendy/sendy_logo.dart';

class SendySendHeader extends StatelessWidget {
  final bool empty;
  final bool desktop;
  final VoidCallback onChoose;
  const SendySendHeader({super.key, required this.empty, required this.onChoose, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final copy = SendyCopy(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = this.desktop || constraints.maxWidth >= 650;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                desktop ? copy.desktopHeadline : copy.headline,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.9),
              ),
              const SizedBox(height: 10),
              Text(copy.subtitle, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              if (empty) ...[
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(desktop ? 36 : 24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                        child: const SendyLogo(size: 32, withText: false),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        desktop ? copy.dropFiles : copy.addFiles,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        copy.dropHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(onPressed: onChoose, icon: const Icon(Icons.add_rounded), label: Text(copy.chooseFiles)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
