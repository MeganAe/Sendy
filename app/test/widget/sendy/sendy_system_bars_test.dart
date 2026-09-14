import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/sendy/sendy_system_bars.dart';
import 'package:yaru/yaru.dart' as yaru;

void main() {
  test('Dark backgrounds have light Android status icons', () {
    for (final color in [Colors.black, const Color(0xFF212121), const Color(0xFF101D32), yaru.yaruDark.colorScheme.surface]) {
      final style = SendySystemBars.statusBarFor(color);
      expect(style.statusBarIconBrightness, Brightness.light);
      expect(style.statusBarBrightness, Brightness.dark);
      expect(style.statusBarColor, Colors.transparent);
    }
  });
  test('Light backgrounds have dark Android status icons', () {
    for (final color in [Colors.white, const Color(0xFFF8F5EE), yaru.yaruLight.colorScheme.surface]) {
      final style = SendySystemBars.statusBarFor(color);
      expect(style.statusBarIconBrightness, Brightness.dark);
      expect(style.statusBarBrightness, Brightness.light);
    }
  });
  test('Use the higher contrast for custom surfaces', () {
    for (final value in [0, 32, 100, 117, 128, 190, 255]) {
      final background = Color.fromARGB(255, value, value, value);
      final style = SendySystemBars.statusBarFor(background);
      final luminance = background.computeLuminance();
      final chosen = style.statusBarIconBrightness == Brightness.light ? 1.05 / (luminance + 0.05) : (luminance + 0.05) / 0.05;
      expect(chosen, greaterThanOrEqualTo(4.5));
    }
  });
  testWidgets('App theme changes rebuild the status style without restarting', (tester) async {
    Future<void> draw(ThemeData theme) => tester.pumpWidget(
      MaterialApp(
        theme: theme,
        builder: (context, child) => SendyStatusBar(child: child!),
        home: const Scaffold(body: Text('Sendy')),
      ),
    );
    SystemUiOverlayStyle style() => tester
        .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find.descendant(of: find.byType(SendyStatusBar), matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>)).first,
        )
        .value;
    await draw(yaru.yaruDark);
    await tester.pumpAndSettle();
    expect(style().statusBarIconBrightness, Brightness.light);
    await draw(yaru.yaruLight);
    await tester.pumpAndSettle();
    expect(style().statusBarIconBrightness, Brightness.dark);
  });
  testWidgets('AppBar uses an explicit overlay rather than a conflicting default', (tester) async {
    final base = yaru.yaruDark;
    final theme = base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: base.colorScheme.surface,
        systemOverlayStyle: SendySystemBars.statusBarFor(base.colorScheme.surface),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(appBar: AppBar(title: const Text('Sendy'))),
      ),
    );
    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.descendant(of: find.byType(AppBar), matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>)).first,
    );
    expect(region.value.statusBarIconBrightness, Brightness.light);
  });
}
