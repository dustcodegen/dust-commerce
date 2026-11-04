part of 'admin_product_variant_edit_drawer.dart';

final class _AdminVariantEditFailure extends StatelessWidget {
  const _AdminVariantEditFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
      );
}

final class _AdminVariantEditForm extends StatelessWidget {
  const _AdminVariantEditForm({
    required this.allowBackorder,
    required this.busy,
    required this.failure,
    required this.formKey,
    required this.manageInventory,
    required this.onAllowBackorderChanged,
    required this.onCountrySelected,
    required this.onCountryTyped,
    required this.onManageInventoryChanged,
    required this.options,
    required this.readOriginCountry,
    required this.scrollController,
    required this.selections,
    required this.values,
  });

  final bool allowBackorder;
  final bool busy;
  final Option<String> failure;
  final GlobalKey<FormState> formKey;
  final bool manageInventory;
  final ValueChanged<bool> onAllowBackorderChanged;
  final ValueChanged<String?> onCountrySelected;
  final ValueChanged<String> onCountryTyped;
  final ValueChanged<bool> onManageInventoryChanged;
  final List<AdminProductOption> options;
  final String? Function() readOriginCountry;
  final ScrollController scrollController;
  final Map<String, String> selections;
  final _VariantEditValues values;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              _AdminVariantTextField(
                controller: values.title,
                enabled: !busy,
                label: 'Title',
                validator: _requiredTitle,
              ),
              const SizedBox(height: 16),
              _AdminVariantTextField(
                controller: values.material,
                enabled: !busy,
                label: 'Material',
                optional: true,
                validator: _optionalIdentifier,
              ),
              for (final option in options) ...[
                const SizedBox(height: 16),
                _AdminVariantOptionField(
                  busy: busy,
                  onSelected: (value) => selections[option.id] = value,
                  option: option,
                  selectedValue: selections[option.id],
                ),
              ],
              const SizedBox(height: 32),
              const Divider(height: 1),
              const SizedBox(height: 32),
              _AdminVariantInventorySection(
                allowBackorder: allowBackorder,
                busy: busy,
                manageInventory: manageInventory,
                onAllowBackorderChanged: onAllowBackorderChanged,
                onManageInventoryChanged: onManageInventoryChanged,
                values: values,
              ),
              const SizedBox(height: 32),
              const Divider(height: 1),
              const SizedBox(height: 32),
              _AdminVariantAttributesSection(
                busy: busy,
                onCountrySelected: onCountrySelected,
                onCountryTyped: onCountryTyped,
                readOriginCountry: readOriginCountry,
                values: values,
              ),
              if (failure case Some(value: final message)) ...[
                const SizedBox(height: 24),
                _AdminVariantEditFailure(message: message),
              ],
            ],
          ),
        ),
      );
}

final class _AdminVariantOptionField extends StatelessWidget {
  const _AdminVariantOptionField({
    required this.busy,
    required this.onSelected,
    required this.option,
    required this.selectedValue,
  });

  final bool busy;
  final ValueChanged<String> onSelected;
  final AdminProductOption option;
  final String? selectedValue;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(option.title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            initialValue: selectedValue,
            icon: const Icon(Icons.unfold_more_rounded, size: 16),
            items: [
              for (final value in option.values)
                DropdownMenuItem(value: value, child: Text(value)),
            ],
            onChanged: busy
                ? null
                : (value) {
                    if (value != null) onSelected(value);
                  },
            validator: (value) => value == null ? 'Choose a value' : null,
          ),
        ],
      );
}
