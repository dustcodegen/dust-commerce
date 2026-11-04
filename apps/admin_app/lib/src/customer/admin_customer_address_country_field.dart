part of 'admin_customer_address_create_form.dart';

/// Searchable country selector matching Medusa's shared address control.
final class _AdminCustomerAddressCountryField extends StatelessWidget {
  /// Creates a country field bound to the parent form state.
  const _AdminCustomerAddressCountryField({
    required this.controller,
    required this.enabled,
    required this.onSelected,
    required this.onTyped,
    required this.selectedCode,
    required this.width,
  });

  /// Visible country label controller.
  final TextEditingController controller;

  /// Whether the selector accepts input.
  final bool enabled;

  /// Publishes one normalized ISO code.
  final ValueChanged<AdminCountry> onSelected;

  /// Invalidates a previous selection when the label changes.
  final ValueChanged<String> onTyped;

  /// Current normalized code, absent until a real option is selected.
  final String? selectedCode;

  /// Responsive grid width.
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Country', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          RawAutocomplete<AdminCountry>(
            displayStringForOption: (country) => country.name,
            fieldViewBuilder: (context, text, focus, submit) => TextFormField(
              controller: text,
              enabled: enabled,
              focusNode: focus,
              onChanged: onTyped,
              onFieldSubmitted: (_) => submit(),
              validator: (_) =>
                  selectedCode == null ? 'Choose a country' : null,
              decoration: const InputDecoration(
                hintText: 'Select country',
                suffixIcon: Icon(Icons.unfold_more_rounded, size: 16),
                suffixIconConstraints: BoxConstraints.tightFor(
                  width: 34,
                  height: 34,
                ),
              ),
            ),
            onSelected: onSelected,
            optionsBuilder: adminCountryOptions,
            optionsViewBuilder: (context, select, options) =>
                _AdminCustomerAddressCountryOptions(
              onSelected: select,
              options: options.toList(growable: false),
              width: width,
            ),
            textEditingController: controller,
          ),
        ]),
      );
}

final class _AdminCustomerAddressCountryOptions extends StatelessWidget {
  const _AdminCustomerAddressCountryOptions({
    required this.onSelected,
    required this.options,
    required this.width,
  });

  final AutocompleteOnSelected<AdminCountry> onSelected;
  final List<AdminCountry> options;
  final double width;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(7),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: width,
            height: 240,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final country in options)
                  InkWell(
                    onTap: () => onSelected(country),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Text(country.name),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
