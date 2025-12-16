import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';

class DetailScreen extends StatefulWidget {
  final Subscription subscription;

  const DetailScreen({super.key, required this.subscription});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateTimeLeft());
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final renewal = widget.subscription.renewalDate;
    // Ensure we are counting down to a future date, or showing 0 if passed (for this MVP logic)
    // In a real app, we'd find the *next* renewal.
    // For now, let's just show difference to the stored date.
    
    // To make it look cool, let's assume the renewal date is at midnight of that day.
    final target = DateTime(renewal.year, renewal.month, renewal.day, 23, 59, 59);
    
    setState(() {
      _timeLeft = target.difference(now);
      if (_timeLeft.isNegative) _timeLeft = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _reapSubscription() {
    HapticFeedback.heavyImpact();
    // Show confetti or slash animation here (simulated with a dialog/snack for now)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SUBSCRIPTION REAPED!'),
        backgroundColor: AppTheme.kColorNeonGreen,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Delay slightly for effect
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<SubscriptionProvider>().removeSubscription(widget.subscription.id);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.kColorNeonRed, width: 2),
                  color: AppTheme.kColorGrey,
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.subscription.name[0].toUpperCase(),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.subscription.name.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "\$${widget.subscription.cost.toStringAsFixed(2)} / ${widget.subscription.billingCycle.name}",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.kColorNeonRed,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 40),

            // Countdown
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: AppTheme.kColorNeonRed),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "TIME REMAINING",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.kColorNeonRed,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TimeUnit(value: _timeLeft.inDays, label: "DAYS"),
                      _TimeSeparator(),
                      _TimeUnit(value: _timeLeft.inHours % 24, label: "HRS"),
                      _TimeSeparator(),
                      _TimeUnit(value: _timeLeft.inMinutes % 60, label: "MIN"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // How to Cancel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.kColorGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "HOW TO CANCEL",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20, color: AppTheme.kColorLightGrey),
                        onPressed: () {
                          Clipboard.setData(const ClipboardData(text: "https://www.google.com/search?q=cancel+subscription"));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "• Log in via browser\n• Go to Profile > Account\n• Select 'Manage Premium'\n• Click 'Cancel Subscription'",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            
            const Spacer(),

            // Reaped Button
            SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: _reapSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kColorNeonRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: AppTheme.kColorNeonRed.withValues(alpha: 0.5),
                ),
                child: Text(
                  "I HAVE CANCELED THIS",
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 36,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Text(
        ":",
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: 36,
          color: AppTheme.kColorLightGrey,
        ),
      ),
    );
  }
}
