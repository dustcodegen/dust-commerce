part of 'admin_product_create_page.dart';

extension on _AdminProductCreatePageState {
  Widget _body(AdminProductCreateState state) {
    if (state.status == AdminProductCreateStatus.loading ||
        state.status == AdminProductCreateStatus.idle) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (state.status == AdminProductCreateStatus.failed) {
      final message = switch (state.failure) {
        Some(:final value) => value,
        None() => 'Unable to prepare product creation.',
      };
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: context.readAdminProductCreateViewModel().load,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    for (final variant in _variants) {
      variant.ensureCurrencies(state.currencyCodes);
    }
    return Form(
      key: _form,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              child: switch (_step) {
                0 => _details(state),
                1 => _organize(state),
                _ => _variantEditor(state),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _organize(AdminProductCreateState state) => Column(
        key: const ValueKey('organize'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organize', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 32),
          Text('Product Type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            initialValue: _typeId,
            decoration: const InputDecoration(),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Unassigned'),
              ),
              for (final productType in state.productTypes)
                DropdownMenuItem<String?>(
                  value: productType.id,
                  child: Text(productType.value),
                ),
            ],
            onChanged: state.isBusy
                ? null
                : (value) => _rebuild(() => _typeId = value),
          ),
          const SizedBox(height: 24),
          _field(
            label: 'Material',
            optional: true,
            controller: _material,
            validator: _optional255,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discountable',
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Allow promotions to reduce this product price.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _discountable,
                  onChanged: (value) => _rebuild(() => _discountable = value),
                ),
              ],
            ),
          ),
          _failure(state),
        ],
      );
}
