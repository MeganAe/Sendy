// Sendy fork: compile the actual app graph, verify theme and navigation contracts.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/sendy/sendy_brand.dart';
import 'package:localsend_app/config/theme.dart';
import 'package:localsend_app/main.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';
import 'package:localsend_app/pages/home_page.dart';

void main() {
  test('Main application remains a Flutter widget', () {
    expect(const LocalSendApp(), isA<Widget>());
  });

  test('Navigation page order matches the HomePage PageView', () {
    expect(HomeTab.values, [HomeTab.send, HomeTab.receive, HomeTab.history, HomeTab.settings]);
  });

  test('Default application theme uses Sendy midnight and ivory', () {
    final theme = getTheme(ColorMode.localsend, Colors.red, Brightness.light, null);
    expect(theme.colorScheme.primary, SendyBrand.midnight);
    expect(theme.scaffoldBackgroundColor, SendyBrand.ivory);
    expect(theme.cardTheme.elevation, 0);
  });
}
