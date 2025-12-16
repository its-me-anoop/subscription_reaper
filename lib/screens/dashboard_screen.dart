import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../providers/subscription_provider.dart';
import '../models/subscription.dart';
import '../theme/app_theme.dart';
import 'add_subscription_sheet.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

import '../widgets/animated_counter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kColorBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "HIT LIST",
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 24, letterSpacing: 2),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.kColorGrey,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Stats
            Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.kColorBackground,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.kColorNeonRed.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MONTHLY BURN",
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: AppTheme.kColorGrey),
                              overflow: TextOverflow.ellipsis,
                            ),
                            AnimatedCounter(
                              value: provider.totalMonthlyCost,
                              prefix: '\$ ',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(color: AppTheme.kColorNeonRed),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "YEARLY WASTE",
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: AppTheme.kColorGrey),
                              overflow: TextOverflow.ellipsis,
                            ),
                            AnimatedCounter(
                              value: provider.yearlyWasteProjection,
                              prefix: '\$ ',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: AppTheme.kColorLightGrey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 1, color: AppTheme.kColorGrey),

            // Subscription List
            Expanded(
              child: Consumer<SubscriptionProvider>(
                builder: (context, provider, child) {
                  if (provider.subscriptions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.radar_outlined,
                            size: 64,
                            color: AppTheme.kColorGrey.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "NO TARGETS FOUND",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.kColorGrey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.subscriptions.length,
                    itemBuilder: (context, index) {
                      final sub = provider.subscriptions[index];
                      // Staggered Animation
                      return TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween(begin: 0, end: 1),
                        curve: Interval(
                          (1 / provider.subscriptions.length) * index,
                          1.0,
                          curve: Curves.easeOutQuad,
                        ),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: Key(sub.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppTheme.kColorNeonRed,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_forever,
                                color: Colors.black,
                                size: 32,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              HapticFeedback.mediumImpact();
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: AppTheme.kColorBackground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                        color: AppTheme.kColorNeonRed,
                                        width: 2,
                                      ),
                                    ),
                                    title: Text(
                                      "CONFIRM KILL?",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: AppTheme.kColorNeonRed,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Text(
                                      "Are you sure you want to eliminate ${sub.name}?",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(
                                          "CANCEL",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: AppTheme.kColorGrey,
                                              ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text(
                                          "EXECUTE",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: AppTheme.kColorNeonRed,
                                              ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              HapticFeedback.heavyImpact();
                              final yearlySavings =
                                  sub.cost *
                                  (sub.billingCycle == BillingCycle.monthly
                                      ? 12
                                      : 1);
                              provider.removeSubscription(sub.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'ELIMINATED! SAVED \$${yearlySavings.toStringAsFixed(0)}/YR',
                                  ),
                                  backgroundColor: AppTheme.kColorNeonGreen,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: _SubscriptionCard(subscription: sub),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddSubscriptionSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const _SubscriptionCard({required this.subscription});

  Color _getCardColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.critical:
        return AppTheme.kColorNeonRed.withValues(alpha: 0.2);
      case SubscriptionStatus.warning:
        return Colors.yellow.withValues(alpha: 0.2);
      case SubscriptionStatus.safe:
        return AppTheme.kColorGrey;
    }
  }

  Color _getBorderColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.critical:
        return AppTheme.kColorNeonRed;
      case SubscriptionStatus.warning:
        return Colors.yellow;
      case SubscriptionStatus.safe:
        return Colors.transparent;
    }
  }

  String _getStatusText(SubscriptionStatus status, int days) {
    switch (status) {
      case SubscriptionStatus.critical:
        return "CANCEL NOW";
      case SubscriptionStatus.warning:
        return "Review soon";
      case SubscriptionStatus.safe:
        return "Renews in $days days";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(subscription: subscription),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _getCardColor(subscription.status),
          border: Border.all(color: _getBorderColor(subscription.status)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          title: Text(
            subscription.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 18),
          ),
          subtitle: Text(
            _getStatusText(subscription.status, subscription.daysRemaining),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: subscription.status == SubscriptionStatus.critical
                  ? AppTheme.kColorNeonRed
                  : AppTheme.kColorLightGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Text(
            "\$${subscription.cost.toStringAsFixed(2)}",
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
