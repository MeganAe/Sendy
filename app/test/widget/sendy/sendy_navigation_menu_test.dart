import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/widget/sendy/sendy_navigation_menu.dart';

void main() {
  testWidgets('Mobile: parcels are hidden in the menu until it is opened', (tester) async {
    var parcels = 0;
    var settings = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              SendyMobileMenu(
                parcelsLabel: 'Mes colis',
                settingsLabel: 'Paramètres',
                onOpenParcels: () => parcels++,
                onOpenSettings: () => settings++,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Mes colis'), findsNothing);
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Mes colis'), findsOneWidget);
    await tester.tap(find.text('Mes colis'));
    await tester.pumpAndSettle();
    expect(parcels, 1);
    expect(settings, 0);
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paramètres'));
    await tester.pumpAndSettle();
    expect(settings, 1);
  });
  for (final extended in [true, false]) {
    testWidgets('Rail entry opens parcels (extended: $extended)', (tester) async {
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SendyParcelsRailEntry(extended: extended, label: 'Mes colis', onOpen: () => opened = true),
            ),
          ),
        ),
      );
      if (extended) {
        await tester.tap(find.text('Mes colis'));
      } else {
        await tester.tap(find.byTooltip('Mes colis'));
      }
      expect(opened, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Phone menu fits at 320 pixels and enlarged text', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          appBar: AppBar(
            actions: [SendyMobileMenu(parcelsLabel: 'Mes colis', settingsLabel: 'Paramètres', onOpenParcels: () {}, onOpenSettings: () {})],
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Mes colis'), findsOneWidget);
  });
}
