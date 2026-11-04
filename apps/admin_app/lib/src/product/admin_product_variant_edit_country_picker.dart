part of 'admin_product_variant_edit_drawer.dart';

final class _AdminVariantCountryField extends StatelessWidget {
  const _AdminVariantCountryField({
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
          Row(children: [
            Text(
              'Country of origin',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 5),
            Text(
              '(Optional)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ]),
          const SizedBox(height: 7),
          RawAutocomplete<AdminCountry>(
            displayStringForOption: (country) => country.name,
            fieldViewBuilder: (context, controller, focusNode, submit) =>
                TextFormField(
              controller: controller,
              enabled: !busy,
              focusNode: focusNode,
              onChanged: onCountryTyped,
              onFieldSubmitted: (_) => submit(),
              validator: (value) =>
                  (value?.isNotEmpty ?? false) && readOriginCountry() == null
                      ? 'Choose a country'
                      : null,
              decoration: const InputDecoration(
                hintText: 'Select country',
                suffixIcon: Icon(Icons.unfold_more_rounded, size: 16),
                suffixIconConstraints: BoxConstraints.tightFor(
                  width: 34,
                  height: 34,
                ),
              ),
            ),
            focusNode: values.originCountryFocus,
            onSelected: (country) => onCountrySelected(country.code),
            optionsBuilder: adminCountryOptions,
            optionsViewBuilder: (context, onSelected, options) =>
                _AdminVariantCountryOptions(
              onSelected: onSelected,
              options: options.toList(growable: false),
            ),
            textEditingController: values.originCountry,
          ),
        ],
      );
}

final class _AdminVariantCountryOptions extends StatelessWidget {
  const _AdminVariantCountryOptions({
    required this.onSelected,
    required this.options,
  });

  final AutocompleteOnSelected<AdminCountry> onSelected;
  final List<AdminCountry> options;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(7),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width.clamp(0, 512).toDouble(),
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
