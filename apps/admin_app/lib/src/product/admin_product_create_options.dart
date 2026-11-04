part of 'admin_product_create_page.dart';

extension on _AdminProductCreatePageState {
  Widget _productOptions() => Column(
        children: [
          for (var index = 0; index < _options.length; index++) ...[
            _optionCard(index),
            const SizedBox(height: 12),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add option'),
            ),
          ),
        ],
      );

  Widget _optionCard(int index) {
    final option = _options[index];
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Option ${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (_options.length > 1)
                  IconButton(
                    tooltip: 'Remove option ${index + 1}',
                    onPressed: () => _removeOption(index),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, constraints) {
              final title = _field(
                label: 'Title',
                controller: option.title,
                validator: (value) => _optionTitleValidator(index, value),
              );
              final values = _field(
                label: 'Values',
                controller: option.values,
                helper: 'Separate values with commas',
                validator: _optionValuesValidator,
              );
              if (constraints.maxWidth < 620) {
                return Column(
                  children: [title, const SizedBox(height: 18), values],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: values),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _addOption() {
    final option = _OptionDraft(onChanged: _syncVariants);
    _rebuild(() => _options.add(option));
  }

  void _removeOption(int index) {
    final option = _options.removeAt(index);
    option.dispose();
    _syncVariants();
  }
}

final class _OptionDraft {
  _OptionDraft({
    required this.onChanged,
    String title = '',
    String values = '',
  })  : title = TextEditingController(text: title),
        values = TextEditingController(text: values) {
    this.title.addListener(onChanged);
    this.values.addListener(onChanged);
  }

  final VoidCallback onChanged;
  final TextEditingController title;
  final TextEditingController values;

  void dispose() {
    title
      ..removeListener(onChanged)
      ..dispose();
    values
      ..removeListener(onChanged)
      ..dispose();
  }
}
