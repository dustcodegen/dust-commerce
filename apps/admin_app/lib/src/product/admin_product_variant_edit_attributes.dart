part of 'admin_product_variant_edit_drawer.dart';

final class _AdminVariantAttributesSection extends StatelessWidget {
  const _AdminVariantAttributesSection({
    required this.busy,
    required this.onCountrySelected,
    required this.onCountryTyped,
    required this.readOriginCountry,
    required this.values,
  });

  final bool busy;
  final ValueChanged<String?> onCountrySelected;
  final ValueChanged<String> onCountryTyped;
  final String? Function() readOriginCountry;
  final _VariantEditValues values;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Attributes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _AdminVariantNumberField(
            busy: busy,
            controller: values.weight,
            label: 'Weight',
          ),
          _AdminVariantNumberField(
            busy: busy,
            controller: values.width,
            label: 'Width',
          ),
          _AdminVariantNumberField(
            busy: busy,
            controller: values.length,
            label: 'Length',
          ),
          _AdminVariantNumberField(
            busy: busy,
            controller: values.height,
            label: 'Height',
          ),
          _AdminVariantTextField(
            controller: values.midCode,
            enabled: !busy,
            label: 'MID code',
            optional: true,
            validator: _optionalIdentifier,
          ),
          const SizedBox(height: 16),
          _AdminVariantTextField(
            controller: values.hsCode,
            enabled: !busy,
            label: 'HS code',
            optional: true,
            validator: _optionalIdentifier,
          ),
          const SizedBox(height: 16),
          _AdminVariantCountryField(
            busy: busy,
            onCountrySelected: onCountrySelected,
            onCountryTyped: onCountryTyped,
            readOriginCountry: readOriginCountry,
            values: values,
          ),
        ],
      );
}

final class _AdminVariantNumberField extends StatelessWidget {
  const _AdminVariantNumberField({
    required this.busy,
    required this.controller,
    required this.label,
  });

  final bool busy;
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AdminVariantTextField(
            controller: controller,
            enabled: !busy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            label: label,
            optional: true,
            validator: _optionalNumber,
          ),
          const SizedBox(height: 16),
        ],
      );
}
