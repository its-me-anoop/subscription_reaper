import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_reaper/models/subscription.dart';

void main() {
  group('Subscription Model Tests', () {
    test('Monthly cost calculation is correct', () {
      final sub = Subscription(
        name: 'Test',
        cost: 10.0,
        billingCycle: BillingCycle.monthly,
        renewalDate: DateTime.now(),
      );
      expect(sub.monthlyCost, 10.0);
      expect(sub.yearlyCost, 120.0);
    });

    test('Yearly cost calculation is correct', () {
      final sub = Subscription(
        name: 'Test',
        cost: 120.0,
        billingCycle: BillingCycle.yearly,
        renewalDate: DateTime.now(),
      );
      expect(sub.monthlyCost, 10.0);
      expect(sub.yearlyCost, 120.0);
    });

    test('Status is Critical when <= 2 days', () {
      final sub = Subscription(
        name: 'Critical',
        cost: 10,
        billingCycle: BillingCycle.monthly,
        renewalDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(sub.status, SubscriptionStatus.critical);
    });

    test('Status is Warning when <= 7 days', () {
      final sub = Subscription(
        name: 'Warning',
        cost: 10,
        billingCycle: BillingCycle.monthly,
        renewalDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(sub.status, SubscriptionStatus.warning);
    });

    test('Status is Safe when > 7 days', () {
      final sub = Subscription(
        name: 'Safe',
        cost: 10,
        billingCycle: BillingCycle.monthly,
        renewalDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(sub.status, SubscriptionStatus.safe);
    });
  });
}
