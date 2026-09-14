// Sendy fork: compile the actual app graph, verify theme and navigation contracts.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/sendy/sendy_brand.dart';
import 'package:localsend_app/config/sendy/sendy_identity.dart';
import 'package:localsend_app/config/theme.dart';
import 'package:localsend_app/main.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';
import 'package:localsend_app/pages/home_page.dart';
import 'package:yaru/yaru.dart' as yaru;

void main() {
  test('Requested default theme is Yaru in light and dark modes', () {
    expect(SendyIdentity.defaultColorMode, ColorMode.yaru.name);
    expect(getTheme(ColorMode.yaru, Colors.red, Brightness.light, null).colorScheme, yaru.yaruLight.colorScheme);
    expect(getTheme(ColorMode.yaru, Colors.red, Brightness.dark, null).colorScheme, yaru.yaruDark.colorScheme);
  });
  test('Main application remains a Flutter widget', () {
    expect(const LocalSendApp(), isA<Widget>());
  });

  test('Navigation page order matches the HomePage PageView', () {
    expect(HomeTab.values, [HomeTab.send, HomeTab.receive, HomeTab.history, HomeTab.settings]);
  });

  test('Optional Sendy palette remains available', () {
    final theme = getTheme(ColorMode.localsend, Colors.red, Brightness.light, null);
    expect(theme.colorScheme.primary, SendyBrand.midnight);
    expect(theme.scaffoldBackgroundColor, SendyBrand.ivory);
    expect(theme.cardTheme.elevation, 0);
  });
}
