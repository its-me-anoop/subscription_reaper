// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_reaper/main.dart';

void main() {
  testWidgets('Intro loads and navigates to Dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SubscriptionReaperApp());

    expect(find.text('THE LEAK'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);

    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();

    expect(find.text('NO TARGETS FOUND'), findsOneWidget);
  });

  testWidgets('Can add a new subscription', (WidgetTester tester) async {
    // Set screen size to avoid overflow
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    await tester.pumpWidget(const SubscriptionReaperApp());

    // Skip Intro
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();

    // Open Add Sheet
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('ADD TARGET'), findsOneWidget);

    // Fill Form
    await tester.enterText(
      find.ancestor(
        of: find.text('SERVICE NAME'),
        matching: find.byType(TextFormField),
      ),
      'Netflix',
    );

    await tester.enterText(
      find.ancestor(
        of: find.text('COST'),
        matching: find.byType(TextFormField),
      ),
      '15.99',
    );

    // Save
    await tester.tap(find.text('ADD TO HIT LIST'));
    await tester.pumpAndSettle();

    // Verify on Dashboard
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('\$15.99'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
