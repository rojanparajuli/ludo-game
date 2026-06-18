import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_app/screens/setup_screen.dart';

void main() {
  testWidgets('SetupScreen shows 4 name fields, dice presets, and a start button',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('Classic'), findsOneWidget);
    expect(find.text('Easy start'), findsOneWidget);
    expect(find.text('No extra turns'), findsOneWidget);
    expect(find.text('Start game'), findsOneWidget);
  });

  testWidgets('starting a game navigates to the game screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SetupScreen()));

    await tester.tap(find.text('Start game'));
    await tester.pumpAndSettle();

    expect(find.text('Ludo'), findsOneWidget);
    expect(find.text('Roll'), findsOneWidget);
  });
}