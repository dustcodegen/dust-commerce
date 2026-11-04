part of 'admin_customer_address_create_form.dart';

/// Responsive field grid copied from Medusa's create-address form source.
final class _AdminCustomerAddressCreateFields extends StatelessWidget {
  /// Creates fields bound to [controllers].
  const _AdminCustomerAddressCreateFields({
    required this.controllers,
    required this.enabled,
    required this.onCountrySelected,
    required this.onCountryTyped,
    required this.selectedCountryCode,
  });

  final _AdminCustomerAddressControllers controllers;
  final bool enabled;
  final ValueChanged<AdminCountry> onCountrySelected;
  final ValueChanged<String> onCountryTyped;
  final String? selectedCountryCode;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth >= 600
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;
          return Wrap(spacing: 16, runSpacing: 16, children: [
            _AdminCustomerAddressTextField(
              controller: controllers.addressName,
              enabled: enabled,
              label: 'Address name',
              required: true,
              width: width,
            ),
            if (constraints.maxWidth >= 600) SizedBox(width: width),
            _AdminCustomerAddressTextField(
              controller: controllers.line1,
              enabled: enabled,
              label: 'Address',
              required: true,
              width: width,
            ),
            _AdminCustomerAddressTextField(
              controller: controllers.line2,
              enabled: enabled,
              label: 'Address 2',
              width: width,
            ),
            _AdminCustomerAddressTextField(
              controller: controllers.postalCode,
              enabled: enabled,
              label: 'Postal code',
              width: width,
            ),
            _AdminCustomerAddressTextField(
              controller: controllers.city,
              enabled: enabled,
              label: 'City',
              width: width,
            ),
            _AdminCustomerAddressCountryField(
              controller: controllers.country,
              enabled: enabled,
              onSelected: onCountrySelected,
              onTyped: onCountryTyped,
              selectedCode: selectedCountryCode,
              width: width,
            ),
            _AdminCustomerAddressTextField(
              controller: controllers.province,
              enabled: enabled,
              label: 'State / Province',
              width: width,
            ),
            _AdminCustomerAddressTextField(
              controller: controllers.company,
              enabled: enabled,
              label: 'Company',
              width: width,
            ),
            _AdminCustomerAddressTextField(
              controller: controllers.phone,
              enabled: enabled,
              keyboardType: TextInputType.phone,
              label: 'Phone',
              width: width,
            ),
          ]);
        },
      );
}

/// One labeled address input with Medusa's optional-label treatment.
final class _AdminCustomerAddressTextField extends StatelessWidget {
  /// Creates one responsive address field.
  const _AdminCustomerAddressTextField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.width,
    this.keyboardType,
    this.required = false,
  });

  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final String label;
  final bool required;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            if (!required) ...[
              const SizedBox(width: 4),
              Text(
                '(optional)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ]),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            validator: required
                ? (value) => value == null || value.trim().isEmpty
                    ? 'This field is required'
                    : null
                : null,
          ),
        ]),
      );
}
