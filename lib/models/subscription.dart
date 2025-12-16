import 'package:uuid/uuid.dart';

/// Defines the billing cycle for a subscription.
enum BillingCycle { monthly, yearly }

/// Defines the urgency status of a subscription based on renewal date.
enum SubscriptionStatus {
  /// Expires in less than 48 hours.
  critical,

  /// Expires in less than 7 days.
  warning,

  /// Safe for now.
  safe,
}

/// Represents a single subscription service.
///
/// This model holds all the necessary data for a subscription, including
/// its cost, billing cycle, and renewal date. It also provides computed
/// properties for status and cost projections.
class Subscription {
  /// Unique identifier for the subscription.
  final String id;

  /// Name of the service (e.g., "Netflix", "Spotify").
  final String name;

  /// Cost per billing cycle.
  final double cost;

  /// The billing cycle (monthly or yearly).
  final BillingCycle billingCycle;

  /// The next renewal date.
  final DateTime renewalDate;

  /// Whether this is a trial subscription.
  final bool isTrial;

  /// Creates a new [Subscription].
  ///
  /// If [id] is not provided, a unique UUID is generated.
  Subscription({
    String? id,
    required this.name,
    required this.cost,
    required this.billingCycle,
    required this.renewalDate,
    this.isTrial = false,
  }) : id = id ?? const Uuid().v4();

  /// Calculates the number of days remaining until renewal.
  ///
  /// This calculation compares the [renewalDate] with the current date
  /// (ignoring time components).
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final renewal = DateTime(
      renewalDate.year,
      renewalDate.month,
      renewalDate.day,
    );
    return renewal.difference(today).inDays;
  }

  /// Determines the urgency status based on [daysRemaining].
  SubscriptionStatus get status {
    final days = daysRemaining;
    if (days <= 2) return SubscriptionStatus.critical;
    if (days <= 7) return SubscriptionStatus.warning;
    return SubscriptionStatus.safe;
  }

  /// Calculates the normalized monthly cost.
  ///
  /// If the cycle is yearly, the cost is divided by 12.
  double get monthlyCost {
    if (billingCycle == BillingCycle.monthly) return cost;
    return cost / 12;
  }

  /// Calculates the projected yearly cost.
  ///
  /// If the cycle is monthly, the cost is multiplied by 12.
  double get yearlyCost {
    if (billingCycle == BillingCycle.yearly) return cost;
    return cost * 12;
  }

  /// Converts the subscription to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'billingCycle': billingCycle.index,
      'renewalDate': renewalDate.toIso8601String(),
      'isTrial': isTrial,
    };
  }

  /// Creates a subscription from a JSON map.
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      name: json['name'],
      cost: json['cost'],
      billingCycle: BillingCycle.values[json['billingCycle']],
      renewalDate: DateTime.parse(json['renewalDate']),
      isTrial: json['isTrial'],
    );
  }
}
