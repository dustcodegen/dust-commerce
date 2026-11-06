import 'package:flutter/material.dart';

/// Promotion form fields with server-compatible units.
final class AdminPromotionCreateFields extends StatelessWidget {
  /// Creates the fields.
  const AdminPromotionCreateFields({
    required this.busy,
    required this.code,
    required this.currency,
    required this.type,
    required this.usageLimit,
    required this.value,
    required this.onTypeChanged,
    super.key,
  });

  /// Whether inputs are disabled.
  final bool busy;

  /// Promotion code controller.
  final TextEditingController code;

  /// Fixed currency controller.
  final TextEditingController currency;

  /// Current type.
  final String type;

  /// Usage-limit controller.
  final TextEditingController usageLimit;

  /// Value controller.
  final TextEditingController value;

  /// Type selection callback.
  final ValueChanged<String> onTypeChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Code', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: code,
            enabled: !busy,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'WELCOME10'),
            validator: _codeValidator,
          ),
          const SizedBox(height: 20),
          Text('Type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: type,
            items: const [
              DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
              DropdownMenuItem(value: 'fixed', child: Text('Fixed amount')),
            ],
            onChanged: busy ? null : (value) => onTypeChanged(value!),
          ),
          const SizedBox(height: 20),
          Text('Value', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: value,
            enabled: !busy,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '1000 basis points or minor units',
            ),
            validator: _numberValidator,
          ),
          if (type == 'fixed') ...[
            const SizedBox(height: 20),
            Text('Currency', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            TextFormField(
              controller: currency,
              enabled: !busy,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'USD'),
              validator: _currencyValidator,
            ),
          ],
          const SizedBox(height: 20),
          Text('Usage limit (optional)',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: usageLimit,
            enabled: !busy,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Unlimited'),
            validator: _optionalNumberValidator,
          ),
        ],
      );

  String? _codeValidator(String? input) {
    final value = input?.trim() ?? '';
    if (value.isEmpty) return 'Code is required';
    if (!RegExp(r'^[A-Za-z0-9_-]{1,64}$').hasMatch(value)) {
      return 'Use letters, numbers, _ or -';
    }
    return null;
  }

  String? _currencyValidator(String? input) =>
      RegExp(r'^[A-Za-z]{3}$').hasMatch(input?.trim() ?? '')
          ? null
          : 'Use a three-letter currency';

  String? _numberValidator(String? input) {
    final value = int.tryParse(input?.trim() ?? '');
    return value == null || value < 0 ? 'Enter a non-negative integer' : null;
  }

  String? _optionalNumberValidator(String? input) {
    if ((input?.trim() ?? '').isEmpty) return null;
    final value = int.tryParse(input!.trim());
    return value == null || value < 1 ? 'Enter a positive integer' : null;
  }
}
