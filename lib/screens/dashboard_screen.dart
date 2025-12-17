import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';

import '../widgets/liquid_card.dart';

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
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: "HIT LIST",
        actions: [
          AdaptiveAppBarAction(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: Icons.settings_outlined,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Stats
            Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                return LiquidCard(
                  padding: const EdgeInsets.all(24),
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
                      return Padding(
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
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AdaptiveFloatingActionButton(
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
      child: LiquidCard(
        padding: EdgeInsets.zero,
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
