import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_reaper/models/subscription.dart';
import 'package:subscription_reaper/providers/subscription_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SubscriptionProvider Tests', () {
    late SubscriptionProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = SubscriptionProvider();
    });

    test('Initial state is empty', () {
      expect(provider.subscriptions, isEmpty);
      expect(provider.totalMonthlyCost, 0.0);
    });

    test('Adding subscription updates list and costs', () {
      final sub = Subscription(
        name: 'Netflix',
        cost: 15.0,
        billingCycle: BillingCycle.monthly,
        renewalDate: DateTime.now(),
      );

      provider.addSubscription(sub);

      expect(provider.subscriptions.length, 1);
      expect(provider.subscriptions.first.name, 'Netflix');
      expect(provider.totalMonthlyCost, 15.0);
      expect(provider.yearlyWasteProjection, 180.0);
    });

    test('Removing subscription updates list and costs', () {
      final sub = Subscription(
        name: 'Netflix',
        cost: 15.0,
        billingCycle: BillingCycle.monthly,
        renewalDate: DateTime.now(),
      );

      provider.addSubscription(sub);
      provider.removeSubscription(sub.id);

      expect(provider.subscriptions, isEmpty);
      expect(provider.totalMonthlyCost, 0.0);
    });

    test('Subscriptions are sorted by days remaining', () {
      final sub1 = Subscription(
        name: 'Far',
        cost: 10,
        billingCycle: BillingCycle.monthly,
        renewalDate: DateTime.now().add(const Duration(days: 10)),
      );
      final sub2 = Subscription(
        name: 'Near',
        cost: 10,
        billingCycle: BillingCycle.monthly,
        renewalDate: DateTime.now().add(const Duration(days: 1)),
      );

      provider.addSubscription(sub1);
      provider.addSubscription(sub2);

      expect(provider.subscriptions.first.name, 'Near');
      expect(provider.subscriptions.last.name, 'Far');
    });
  });
}
