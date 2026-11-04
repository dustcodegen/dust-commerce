part of 'admin_product_create_page.dart';

extension on _AdminProductCreatePageState {
  Future<void> _submit(AdminProductLifecycle status) async {
    context.readAdminProductCreateViewModel().clearFailure();
    final product = _product(status);
    if (product case None()) return;
    final created = await context
        .readAdminProductCreateViewModel()
        .create((product as Some<AdminCreateProduct>).value);
    if (!mounted) return;
    if (created case Some(:final value)) Navigator.of(context).pop(value);
  }

  Option<AdminCreateProduct> _product(AdminProductLifecycle status) {
    final formValid = _form.currentState?.validate() ?? false;
    final options = _hasVariants
        ? _parsedOptions()
        : [
            (title: 'Default option', values: ['Default option value']),
          ];
    final optionsValid = !_hasVariants ||
        (options.length == _options.length &&
            _options.indexed.every(
              (entry) =>
                  _optionTitleValidator(entry.$1, entry.$2.title.text) ==
                      null &&
                  _optionValuesValidator(entry.$2.values.text) == null,
            ));
    final generalValid = _requiredTitle(_title.text) == null &&
        _optional255(_subtitle.text) == null &&
        _optionalHandle(_handle.text) == null &&
        _optional255(_material.text) == null &&
        _description.text.length <= 20000;
    if (!formValid || !generalValid || !optionsValid) {
      if (!generalValid) _rebuild(() => _step = 0);
      _showInputFailure('Complete the required product details.');
      return const None();
    }
    final currencies =
        context.readAdminProductCreateViewModel().state.currencyCodes;
    final variants = <AdminCreateProductVariant>[];
    for (final draft in _variants) {
      final inventory = int.tryParse(draft.inventory.text.trim());
      if (draft.sku.text.length > 255) {
        _rebuild(() => _step = 2);
        _showInputFailure('Use at most 255 characters for a SKU.');
        return const None();
      }
      final prices = <AdminCreateProductPrice>[];
      for (final currency in currencies) {
        final amount = parseMinorUnits(
          draft.prices[currency]!.text,
          currency,
        );
        if (amount == null) {
          _rebuild(() => _step = 2);
          _showInputFailure('Enter every price using its currency precision.');
          return const None();
        }
        prices.add(AdminCreateProductPrice(
          currencyCode: currency,
          amount: amount,
        ));
      }
      if (inventory == null || inventory < 0) {
        _rebuild(() => _step = 2);
        _showInputFailure('Enter a non-negative inventory quantity.');
        return const None();
      }
      variants.add(AdminCreateProductVariant(
        title: draft.value,
        sku: draft.sku.text,
        inventoryQuantity: inventory,
        manageInventory: draft.manageInventory,
        allowBackorder: draft.allowBackorder,
        optionValues: Map.unmodifiable(draft.selections),
        prices: prices,
      ));
    }
    return Some(AdminCreateProduct(
      status: status,
      title: _title.text,
      handle: _handle.text,
      subtitle: _subtitle.text,
      material: _material.text,
      description: _description.text,
      typeId: _typeId,
      discountable: _discountable,
      media: [
        for (final item in _media)
          AdminCreateProductMedia(
            id: item.file.id,
            url: item.file.url,
            isThumbnail: item.isThumbnail,
          ),
      ],
      options: [
        for (final option in options)
          AdminCreateProductOption(
            title: option.title,
            values: option.values,
          ),
      ],
      variants: variants,
    ));
  }
}
