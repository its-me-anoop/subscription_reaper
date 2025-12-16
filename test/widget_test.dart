// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:subscription_reaper/main.dart';

void main() {
  testWidgets('Intro loads and navigates to Dashboard', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SubscriptionReaperApp());

    // Verify Intro Screen loads
    expect(find.text('THE LEAK'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);

    // Tap SKIP to go to Dashboard
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();

    // Verify Dashboard loads
    expect(find.text('NO TARGETS FOUND'), findsOneWidget);
  });
}
