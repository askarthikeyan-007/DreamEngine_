// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter_test/flutter_test.dart';

import 'package:dream_engine_ai/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DreamEngineApp());

    // Wait 2 seconds for the logo screen timer to complete.
    await tester.pump(const Duration(seconds: 2));

    // Wait for the video initialization error to be caught and skip to boot sequence.
    await tester.pump();
    await tester.pump();

    // Settle the AnimatedSwitcher transition so the old screen is removed.
    await tester.pump(const Duration(seconds: 1));

    // Verify that the splash screen loads with our app title.
    expect(find.text('DREAMENGINE AI'), findsOneWidget);
  });
}
