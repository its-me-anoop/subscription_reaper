import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

/// Manages the state of subscriptions in the application.
///
/// Manages the list of subscriptions and provides derived data.
class SubscriptionProvider with ChangeNotifier {
  List<Subscription> _subscriptions = [];
  List<Subscription>? _cachedSortedSubscriptions;
  static const String _storageKey = 'subscriptions_data';

  SubscriptionProvider() {
    _loadSubscriptions();
  }

  /// Loads subscriptions from persistent storage.
  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _subscriptions = decoded.map((e) => Subscription.fromJson(e)).toList();
      notifyListeners();
    }
  }

  /// Saves subscriptions to persistent storage.
  Future<void> _saveSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(
      _subscriptions.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, data);
  }

  /// Returns a sorted list of subscriptions (Critical -> Warning -> Safe).
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

  /// Adds a new subscription.
  void addSubscription(Subscription subscription) {
    _subscriptions.add(subscription);
    _invalidateCache();
    _saveSubscriptions();
    notifyListeners();
  }

  /// Removes a subscription by ID.
  void removeSubscription(String id) {
    _subscriptions.removeWhere((sub) => sub.id == id);
    _invalidateCache();
    _saveSubscriptions();
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

  /// Removes all subscriptions from the list.
  void clearAllSubscriptions() {
    _subscriptions.clear();
    _invalidateCache();
    notifyListeners();
  }

  void _invalidateCache() {
    _cachedSortedSubscriptions = null;
  }
}
