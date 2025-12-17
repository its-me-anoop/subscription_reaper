import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _nukeDatabase(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.kColorBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.kColorNeonRed, width: 2),
        ),
        title: Text(
          "NUKE DATABASE?",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppTheme.kColorNeonRed,
            fontSize: 24,
          ),
        ),
        content: Text(
          "This will permanently delete all tracked subscriptions. There is no undo.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "CANCEL",
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppTheme.kColorLightGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              context.read<SubscriptionProvider>().clearAllSubscriptions();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to Dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('DATABASE PURGED'),
                  backgroundColor: AppTheme.kColorNeonRed,
                ),
              );
            },
            child: Text(
              "NUKE IT",
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppTheme.kColorNeonRed),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: "SYSTEM CONFIG",
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.kColorGrey),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "NOTIFICATIONS",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.kColorNeonGreen,
                fontSize: 14,
              ),
            ),
          ),
          AdaptiveListTile(
            leading: const Icon(
              Icons.notifications_active_outlined,
              color: AppTheme.kColorLightGrey,
            ),
            title: Text(
              "RENEWAL ALERTS",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Get notified before you pay",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.kColorGrey,
                fontSize: 12,
              ),
            ),
            trailing: AdaptiveSwitch(
              value: settings.notificationsEnabled,
              onChanged: (val) {
                HapticFeedback.lightImpact();
                context.read<SettingsProvider>().toggleNotifications(val);
              },
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "DATA MANAGEMENT",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.kColorNeonGreen,
                fontSize: 14,
              ),
            ),
          ),
          AdaptiveListTile(
            leading: const Icon(
              Icons.delete_forever_outlined,
              color: AppTheme.kColorNeonRed,
            ),
            title: Text(
              "NUKE DATABASE",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.kColorNeonRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Delete all subscriptions",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.kColorGrey,
                fontSize: 12,
              ),
            ),
            onTap: () => _nukeDatabase(context),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "ABOUT",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.kColorNeonGreen,
                fontSize: 14,
              ),
            ),
          ),
          AdaptiveListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppTheme.kColorLightGrey,
            ),
            title: Text(
              "VERSION",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "1.0.0 (Cyber-Utility Build)",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.kColorGrey,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Center(
            child: Text(
              "SUBSCRIPTION REAPER",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppTheme.kColorGrey.withValues(alpha: 0.3),
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
