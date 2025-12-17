import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';

import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';

class AddSubscriptionSheet extends StatefulWidget {
  final Subscription? subscriptionToEdit;

  const AddSubscriptionSheet({super.key, this.subscriptionToEdit});

  @override
  State<AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<AddSubscriptionSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _costController;

  late BillingCycle _selectedCycle;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.subscriptionToEdit != null) {
      final sub = widget.subscriptionToEdit!;
      _nameController = TextEditingController(text: sub.name);
      _costController = TextEditingController(text: sub.cost.toString());
      _selectedCycle = sub.billingCycle;
      _selectedDate = sub.renewalDate;
    } else {
      _nameController = TextEditingController();
      _costController = TextEditingController();
      _selectedCycle = BillingCycle.monthly;
      _selectedDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();

      final name = _nameController.text;
      final cost = double.parse(_costController.text);

      if (widget.subscriptionToEdit != null) {
        // Update existing
        final updatedSub = Subscription(
          id: widget.subscriptionToEdit!.id,
          name: name,
          cost: cost,
          billingCycle: _selectedCycle,
          renewalDate: _selectedDate,
        );
        context.read<SubscriptionProvider>().updateSubscription(updatedSub);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('TARGET UPDATED'),
            backgroundColor: AppTheme.kColorNeonGreen,
          ),
        );
      } else {
        // Add new
        final newSub = Subscription(
          id: const Uuid().v4(),
          name: name,
          cost: cost,
          billingCycle: _selectedCycle,
          renewalDate: _selectedDate,
        );
        context.read<SubscriptionProvider>().addSubscription(newSub);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('TARGET ACQUIRED'),
            backgroundColor: AppTheme.kColorNeonGreen,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscriptionToEdit != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.kColorBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.kColorNeonGreen, width: 2),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? "EDIT TARGET" : "ADD TARGET",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Name Input
            AdaptiveTextFormField(
              controller: _nameController,
              placeholder: "SERVICE NAME",
              prefixIcon: const Icon(Icons.label_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Cost Input
            AdaptiveTextFormField(
              controller: _costController,
              placeholder: "COST",
              prefixIcon: const Icon(Icons.attach_money),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter cost';
                }
                if (double.tryParse(value) == null) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Billing Cycle
            Text(
              "BILLING CYCLE",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.kColorGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            AdaptiveSegmentedControl(
              labels: BillingCycle.values
                  .map((c) => c.name.toUpperCase())
                  .toList(),
              selectedIndex: _selectedCycle.index,
              onValueChanged: (index) {
                setState(() {
                  _selectedCycle = BillingCycle.values[index];
                });
              },
            ),
            const SizedBox(height: 24),

            // Renewal Date
            InkWell(
              onTap: () async {
                final picked = await AdaptiveDatePicker.show(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "NEXT RENEWAL",
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    color: AppTheme.kColorNeonGreen,
                  ),
                ),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickDateChip(
                    label: "+1 MO",
                    onTap: () => setState(
                      () => _selectedDate = DateTime.now().add(
                        const Duration(days: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickDateChip(
                    label: "+1 YR",
                    onTap: () => setState(
                      () => _selectedDate = DateTime.now().add(
                        const Duration(days: 365),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _QuickDateChip(
                    label: "TODAY",
                    onTap: () => setState(() => _selectedDate = DateTime.now()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            AdaptiveButton(
              onPressed: _submit,
              label: isEditing ? "UPDATE TARGET" : "ADD TO HIT LIST",
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickDateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickDateChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      backgroundColor: AppTheme.kColorGrey.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: AppTheme.kColorNeonGreen),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
