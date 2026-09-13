// Modified for Sendy: retain the legacy widget API for existing callers.
import 'package:flutter/material.dart';
import 'package:localsend_app/widget/sendy/sendy_logo.dart';

class LocalSendLogo extends StatelessWidget {
  final bool withText;
  const LocalSendLogo({required this.withText});
  @override
  Widget build(BuildContext context) => Center(
    child: SendyLogo(size: withText ? 64 : 96, withText: withText),
  );
}
