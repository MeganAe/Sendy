// Sendy regression tests: never display success for a failed/cancelled session.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localsend_app/config/sendy/sendy_brand.dart';
import 'package:localsend_app/config/sendy/sendy_transfer_state.dart';
import 'package:localsend_app/widget/sendy/sendy_transfer_summary.dart';
import 'package:localsend_isolates/model/session_status.dart';

Widget fixture(Widget child, {bool reducedMotion = false}) => MaterialApp(
  theme: ThemeData(colorScheme: SendyBrand.scheme(Brightness.light)),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reducedMotion),
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  test('Only a completely finished session is successful', () {
    for (final status in SessionStatus.values) {
      expect(sendyTransferPhase(status) == SendyTransferPhase.success, status == SessionStatus.finished, reason: status.name);
    }
  });
  test('Waiting and transferring are distinct', () {
    expect(sendyTransferPhase(SessionStatus.waiting), SendyTransferPhase.waiting);
    expect(sendyTransferPhase(SessionStatus.sending), SendyTransferPhase.active);
    expect(sendyTransferPhase(SessionStatus.finishedWithErrors), SendyTransferPhase.problem);
  });
  testWidgets('Display real progress, not a simulated percentage', (tester) async {
    await tester.pumpWidget(
      fixture(
        const SendyTransferSummary(
          phase: SendyTransferPhase.active,
          statusLabel: 'Envoi en cours',
          peer: 'Mon ordinateur',
          details: '68 Mo / 100 Mo',
          progress: .68,
        ),
      ),
    );
    expect(find.text('68 %'), findsOneWidget);
    expect(find.text('68 Mo / 100 Mo'), findsOneWidget);
    expect(find.byType(SendySuccessMark), findsNothing);
  });
  testWidgets('Unknown progress does not claim a percentage', (tester) async {
    await tester.pumpWidget(
      fixture(
        const SendyTransferSummary(
          phase: SendyTransferPhase.waiting,
          statusLabel: 'En attente',
          peer: 'Mon ordinateur',
          details: '',
          progress: null,
        ),
      ),
    );
    expect(find.text('0 %'), findsNothing);
    expect(find.byType(SendySuccessMark), findsNothing);
    await tester.pumpAndSettle();
  });
  testWidgets('Failure at full byte count must not look successful', (tester) async {
    await tester.pumpWidget(
      fixture(
        const SendyTransferSummary(
          phase: SendyTransferPhase.problem,
          statusLabel: 'Transfert avec erreurs',
          peer: 'Mon ordinateur',
          details: '100 Mo / 100 Mo',
          progress: 1,
        ),
      ),
    );
    expect(find.byType(SendySuccessMark), findsNothing);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });
  testWidgets('Success animation finishes and does not repeat', (tester) async {
    await tester.pumpWidget(fixture(const SendySuccessMark(color: Colors.teal)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
  testWidgets('Reduced motion is honored immediately and after a change', (tester) async {
    await tester.pumpWidget(fixture(const SendySuccessMark(color: Colors.teal)));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpWidget(fixture(const SendySuccessMark(color: Colors.teal), reducedMotion: true));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
  testWidgets('Transfer panel supports narrow screens and large text', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SendyTransferSummary(
                phase: SendyTransferPhase.active,
                statusLabel: 'Envoi en cours',
                peer: 'Un nom d’appareil particulièrement long pour vérifier la mise en page',
                details: '68 Mo sur 100 Mo',
                progress: .68,
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
