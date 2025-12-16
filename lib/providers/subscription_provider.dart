import 'package:flutter/foundation.dart';
import '../models/subscription.dart';

/// Manages the state of subscriptions in the application.
///
/// This provider handles adding, removing, and retrieving subscriptions.
/// It also calculates total costs and sorts subscriptions by urgency.
class SubscriptionProvider with ChangeNotifier {
  final List<Subscription> _subscriptions = [];

  // Cache for sorted subscriptions to avoid re-sorting on every access
  List<Subscription>? _cachedSortedSubscriptions;

  /// Returns a list of subscriptions sorted by days remaining (soonest first).
  ///
  /// The list is cached and only re-sorted when the subscription list changes.
  List<Subscription> get subscriptions {
    if (_cachedSortedSubscriptions != null) {
      return _cachedSortedSubscriptions!;
    }

    _cachedSortedSubscriptions = List.from(_subscriptions);
    _cachedSortedSubscriptions!.sort(
      (a, b) => a.daysRemaining.compareTo(b.daysRemaining),
    );
    return _cachedSortedSubscriptions!;
  }

  /// Adds a new [subscription] to the list.
  void addSubscription(Subscription subscription) {
    _subscriptions.add(subscription);
    _invalidateCache();
    notifyListeners();
  }

  /// Removes a subscription with the given [id].
  void removeSubscription(String id) {
    _subscriptions.removeWhere((sub) => sub.id == id);
    _invalidateCache();
    notifyListeners();
  }

  /// Calculates the total monthly cost of all subscriptions.
  double get totalMonthlyCost {
    return _subscriptions.fold(0, (sum, sub) => sum + sub.monthlyCost);
  }

  /// Calculates the projected yearly waste (total yearly cost).
  double get yearlyWasteProjection {
    return _subscriptions.fold(0, (sum, sub) => sum + sub.yearlyCost);
  }

  /// Invalidates the cached sorted list.
  void _invalidateCache() {
    _cachedSortedSubscriptions = null;
  }
}
