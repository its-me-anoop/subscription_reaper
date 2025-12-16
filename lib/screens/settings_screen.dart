import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.kColorBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "SYSTEM CONFIG",
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 24, letterSpacing: 2),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.kColorGrey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionHeader(title: "NOTIFICATIONS"),
          _SettingsTile(
            icon: Icons.notifications_active_outlined,
            title: "RENEWAL ALERTS",
            subtitle: "Get notified before you pay",
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (val) {
                HapticFeedback.lightImpact();
                context.read<SettingsProvider>().toggleNotifications(val);
              },
              activeColor: AppTheme.kColorNeonGreen,
              activeTrackColor: AppTheme.kColorNeonGreen.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 32),

          _SectionHeader(title: "DATA MANAGEMENT"),
          _SettingsTile(
            icon: Icons.delete_forever_outlined,
            title: "NUKE DATABASE",
            subtitle: "Delete all subscriptions",
            iconColor: AppTheme.kColorNeonRed,
            textColor: AppTheme.kColorNeonRed,
            onTap: () => _nukeDatabase(context),
          ),
          const SizedBox(height: 32),

          _SectionHeader(title: "ABOUT"),
          _SettingsTile(
            icon: Icons.info_outline,
            title: "VERSION",
            subtitle: "1.0.0 (Cyber-Utility Build)",
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppTheme.kColorNeonGreen,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppTheme.kColorLightGrey, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.kColorGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
