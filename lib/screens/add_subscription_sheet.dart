import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';

class AddSubscriptionSheet extends StatefulWidget {
  const AddSubscriptionSheet({super.key});

  @override
  State<AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<AddSubscriptionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  BillingCycle _billingCycle = BillingCycle.monthly;
  DateTime _renewalDate = DateTime.now().add(const Duration(days: 30));
  bool _isTrial = false;

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _saveSubscription() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      final cost = double.parse(_costController.text);
      final subscription = Subscription(
        name: _nameController.text,
        cost: cost,
        billingCycle: _billingCycle,
        renewalDate: _renewalDate,
        isTrial: _isTrial,
      );

      context.read<SubscriptionProvider>().addSubscription(subscription);
      Navigator.pop(context);
    }
  }

  void _updateDate(int daysToAdd) {
    setState(() {
      _renewalDate = DateTime.now().add(Duration(days: daysToAdd));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.kColorBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.kColorNeonGreen, width: 2),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "ADD TARGET",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.kColorNeonGreen,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Service Name
              TextFormField(
                controller: _nameController,
                style: Theme.of(context).textTheme.headlineMedium,
                decoration: InputDecoration(
                  labelText: "SERVICE NAME",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.kColorGrey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.kColorNeonGreen),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Cost
              TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.kColorNeonRed,
                ),
                decoration: InputDecoration(
                  prefixText: "\$ ",
                  prefixStyle: Theme.of(context).textTheme.displayLarge
                      ?.copyWith(color: AppTheme.kColorNeonRed),
                  labelText: "COST",
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.kColorGrey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.kColorNeonRed),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),

              // Cycle Toggle
              Row(
                children: [
                  _CycleChip(
                    label: "MONTHLY",
                    isSelected: _billingCycle == BillingCycle.monthly,
                    onTap: () =>
                        setState(() => _billingCycle = BillingCycle.monthly),
                  ),
                  const SizedBox(width: 12),
                  _CycleChip(
                    label: "YEARLY",
                    isSelected: _billingCycle == BillingCycle.yearly,
                    onTap: () =>
                        setState(() => _billingCycle = BillingCycle.yearly),
                  ),
                  const SizedBox(width: 12),
                  _CycleChip(
                    label: "TRIAL",
                    isSelected: _isTrial,
                    onTap: () => setState(() => _isTrial = !_isTrial),
                    isTrial: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Date Picker
              Text(
                "KILL DATE (RENEWAL)",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _renewalDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    builder: (context, child) {
                      return Theme(
                        data: AppTheme.darkTheme.copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.kColorNeonGreen,
                            onPrimary: Colors.black,
                            surface: AppTheme.kColorGrey,
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _renewalDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.kColorGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_renewalDate),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickChip(label: "+1 MONTH", onTap: () => _updateDate(30)),
                    const SizedBox(width: 8),
                    _QuickChip(label: "+1 YEAR", onTap: () => _updateDate(365)),
                    const SizedBox(width: 8),
                    _QuickChip(label: "+7 DAYS", onTap: () => _updateDate(7)),
                    const SizedBox(width: 8),
                    _QuickChip(label: "+14 DAYS", onTap: () => _updateDate(14)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _saveSubscription,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kColorNeonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "ADD TO HIT LIST",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isTrial;

  const _CycleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isTrial = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isTrial ? Colors.orange : AppTheme.kColorNeonGreen;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Colors.transparent,
            border: Border.all(color: isSelected ? color : AppTheme.kColorGrey),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? color : AppTheme.kColorLightGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.kColorGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
