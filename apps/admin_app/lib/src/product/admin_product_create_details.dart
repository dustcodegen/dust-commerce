part of 'admin_product_create_page.dart';

extension on _AdminProductCreatePageState {
  Widget _details(AdminProductCreateState state) => Column(
        key: const ValueKey('details'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('General', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 32),
          LayoutBuilder(builder: (context, constraints) {
            final fields = [
              _field(
                label: 'Title',
                controller: _title,
                validator: _requiredTitle,
              ),
              _field(
                label: 'Subtitle',
                optional: true,
                controller: _subtitle,
                validator: _optional255,
              ),
              _field(
                label: 'Handle',
                optional: true,
                controller: _handle,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 10, right: 2),
                  child: Text('/'),
                ),
                onChanged: (_) => _handleEdited = true,
                validator: _optionalHandle,
              ),
            ];
            if (constraints.maxWidth < 620) {
              return Column(
                children: [
                  for (final field in fields) ...[
                    field,
                    const SizedBox(height: 18),
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < fields.length; index++) ...[
                  Expanded(child: fields[index]),
                  if (index < fields.length - 1) const SizedBox(width: 16),
                ],
              ],
            );
          }),
          const SizedBox(height: 18),
          _field(
            label: 'Description',
            optional: true,
            controller: _description,
            maxLines: 6,
            validator: (value) => (value?.length ?? 0) > 20000
                ? 'Use at most 20000 characters'
                : null,
          ),
          const SizedBox(height: 24),
          _mediaSection(state),
          const SizedBox(height: 32),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 32),
          Text('Variants', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Add the option and values customers use to choose this product.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Switch(
                  value: _hasVariants,
                  onChanged: (value) {
                    _rebuild(() => _hasVariants = value);
                    _syncVariants();
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yes, this is a product with variants',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'When disabled, a default variant is created for you.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_hasVariants) ...[
            const SizedBox(height: 18),
            _productOptions(),
          ],
          _failure(state),
        ],
      );
}
