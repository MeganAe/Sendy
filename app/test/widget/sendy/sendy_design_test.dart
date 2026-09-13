// Sendy fork: focused widget regressions; no network/native engine required.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/sendy/sendy_brand.dart';
import 'package:localsend_app/widget/sendy/sendy_logo.dart';
import 'package:localsend_app/widget/sendy/sendy_send_header.dart';

Widget fixture(Widget child, {Brightness brightness = Brightness.light, double scale = 1}) => MaterialApp(
  locale: const Locale('fr'),
  supportedLocales: const [Locale('fr'), Locale('en')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  theme: ThemeData(
    colorScheme: SendyBrand.scheme(brightness),
    scaffoldBackgroundColor: SendyBrand.scheme(brightness).surface,
    cardColor: brightness == Brightness.light ? Colors.white : const Color(0xFF1B293D),
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

void main() {
  for (final brightness in Brightness.values) {
    test('Palette ${brightness.name}: readable text and primary buttons', () {
      final colors = SendyBrand.scheme(brightness);
      expect(contrast(colors.primary, colors.onPrimary), greaterThanOrEqualTo(4.5));
      expect(contrast(colors.surface, colors.onSurface), greaterThanOrEqualTo(4.5));
      expect(contrast(colors.surface, colors.onSurfaceVariant), greaterThanOrEqualTo(4.5));
    });
  }

  testWidgets('The logo exposes one accessible brand label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(fixture(const SendyLogo()));
    expect(find.bySemanticsLabel('Sendy'), findsOneWidget);
    expect(find.text('sendy'), findsOneWidget);
    semantics.dispose();
  });

  for (final width in [320.0, 390.0, 1100.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Picker header: width $width, text scale $scale', (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var chosen = 0;
        await tester.pumpWidget(fixture(SendySendHeader(empty: true, onChoose: () => chosen++), scale: scale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final button = find.widgetWithText(FilledButton, 'Choisir des fichiers');
        await tester.ensureVisible(button);
        await tester.tap(button);
        expect(chosen, 1);
      });
    }
  }

  testWidgets('A populated selection does not repeat the empty-state button', (tester) async {
    await tester.pumpWidget(fixture(SendySendHeader(empty: false, onChoose: () {})));
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('Dark mode renders without layout exceptions', (tester) async {
    await tester.pumpWidget(fixture(SendySendHeader(empty: true, onChoose: () {}), brightness: Brightness.dark));
    expect(tester.takeException(), isNull);
  });
}
