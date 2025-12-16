import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';

import '../widgets/glitch_effect.dart';
import 'add_subscription_sheet.dart';

class DetailScreen extends StatefulWidget {
  final Subscription subscription;

  const DetailScreen({super.key, required this.subscription});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  late Duration _timeLeft;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isReaping = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateTimeLeft();
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final renewal = widget.subscription.renewalDate;
    if (renewal.isAfter(now)) {
      _timeLeft = renewal.difference(now);
    } else {
      _timeLeft = Duration.zero;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _reapSubscription() async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.kColorBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.kColorNeonRed, width: 2),
          ),
          title: Text(
            "CONFIRM KILL?",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppTheme.kColorNeonRed),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Are you sure you want to eliminate ${widget.subscription.name}?",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "CANCEL",
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppTheme.kColorGrey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "EXECUTE",
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppTheme.kColorNeonRed),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _isReaping = true;
    });

    // Delay for effect then delete
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final yearlySavings =
          widget.subscription.cost *
          (widget.subscription.billingCycle == BillingCycle.monthly ? 12 : 1);

      context.read<SubscriptionProvider>().removeSubscription(
        widget.subscription.id,
      );
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'TARGET ELIMINATED! SAVED \$${yearlySavings.toStringAsFixed(0)}/YR',
          ),
          backgroundColor: AppTheme.kColorNeonGreen,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlitchEffect(
      active: _isReaping,
      child: Scaffold(
        backgroundColor: AppTheme.kColorBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.kColorGrey),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "EXECUTION ROOM",
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: 20, letterSpacing: 2),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.kColorGrey),
              onPressed: () async {
                HapticFeedback.lightImpact();
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddSubscriptionSheet(
                    key: const Key('add_subscription_sheet'),
                    subscriptionToEdit: widget.subscription,
                  ),
                );
                // After editing, we need to refresh or pop.
                // Since the provider updates the object in place, and this widget holds a reference,
                // we might see stale data unless we pop or listen.
                // Simplest UX: Pop back to dashboard to see changes.
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ... (Existing UI code for Target, Cost, etc.)
                  _DetailItem(label: "TARGET", value: widget.subscription.name),
                  const SizedBox(height: 24),
                  _DetailItem(
                    label: "COST",
                    value: "\$${widget.subscription.cost.toStringAsFixed(2)}",
                    valueColor: AppTheme.kColorNeonRed,
                  ),
                  const SizedBox(height: 24),
                  _DetailItem(
                    label: "RENEWS IN",
                    value: _formatDuration(_timeLeft),
                    valueColor: _timeLeft.inDays < 3
                        ? AppTheme.kColorNeonRed
                        : AppTheme.kColorNeonGreen,
                  ),
                  const SizedBox(height: 48),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.kColorGrey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.terminal,
                              color: AppTheme.kColorNeonGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "MISSION BRIEF",
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(color: AppTheme.kColorNeonGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "To cancel ${widget.subscription.name}, log in to their portal and navigate to billing settings. Execute immediately.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: "Cancel ${widget.subscription.name}",
                              ),
                            );
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('COPIED TO CLIPBOARD'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.copy,
                                size: 16,
                                color: AppTheme.kColorGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "COPY SEARCH QUERY",
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Reap Button
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.kColorNeonGreen.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _reapSubscription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.kColorNeonGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "I HAVE CANCELED THIS",
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      "CONFIRM KILL",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.kColorGrey,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Terminated Overlay
            if (_isReaping)
              Container(
                color: Colors.black.withValues(alpha: 0.8),
                child: Center(
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.kColorNeonRed,
                          width: 4,
                        ),
                      ),
                      child: Text(
                        "TERMINATED",
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: AppTheme.kColorNeonRed,
                              fontSize: 48,
                              letterSpacing: 4,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return "${duration.inDays} DAYS";
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return "$hours H $minutes M";
    }
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppTheme.kColorGrey),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 32,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
