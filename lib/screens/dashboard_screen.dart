import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../providers/subscription_provider.dart';
import '../models/subscription.dart';
import '../theme/app_theme.dart';
import 'add_subscription_sheet.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

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
            const _DashboardHeader(),
            Expanded(
              child: Consumer<SubscriptionProvider>(
                builder: (context, provider, child) {
                  if (provider.subscriptions.isEmpty) {
                    return Center(
                      child: Text(
                        "NO TARGETS FOUND",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.subscriptions.length,
                    itemBuilder: (context, index) {
                      final sub = provider.subscriptions[index];
                      return _SubscriptionCard(subscription: sub);
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
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddSubscriptionSheet(),
          );
        },
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final monthlyCost = context.select<SubscriptionProvider, double>(
      (p) => p.totalMonthlyCost,
    );
    final yearlyWaste = context.select<SubscriptionProvider, double>(
      (p) => p.yearlyWasteProjection,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: AppTheme.kColorNeonRed, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.kColorNeonRed.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "\$${monthlyCost.toStringAsFixed(0)}/mo",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppTheme.kColorNeonRed,
              shadows: [
                Shadow(
                  color: AppTheme.kColorNeonRed.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${yearlyWaste.toStringAsFixed(0)}/year projected waste",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.kColorLightGrey),
          ),
        ],
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
    return Dismissible(
      key: Key(subscription.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: AppTheme.kColorNeonGreen,
        child: const Icon(Icons.check, color: Colors.black, size: 32),
      ),
      onDismissed: (direction) {
        HapticFeedback.heavyImpact();
        context.read<SubscriptionProvider>().removeSubscription(
          subscription.id,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${subscription.name} reaped!')));
      },
      child: GestureDetector(
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
      ),
    );
  }
}
