part of 'admin_product_create_page.dart';

extension on _AdminProductCreatePageState {
  void _syncHandle() {
    if (_handleEdited) return;
    _handle.text = _slug(_title.text);
  }

  void _syncVariants() {
    final next = <_VariantDraft>[];
    final selections = _hasVariants
        ? buildProductOptionPermutations(_parsedOptions())
        : [
            {'Default option': 'Default option value'},
          ];
    for (final selection in selections) {
      final key = _VariantDraft.keyFor(selection);
      final draft = _variantDrafts.putIfAbsent(
        key,
        () => _VariantDraft(selection),
      );
      draft.selections = selection;
      next.add(draft);
    }
    _variants
      ..clear()
      ..addAll(next);
    if (mounted) _rebuild(() {});
  }

  List<ProductOptionAxis> _parsedOptions() => [
        for (final option in _options)
          (
            title: option.title.text.trim(),
            values: _parsedValues(option.values.text),
          ),
      ];

  List<String> _parsedValues(String input) {
    return parseProductOptionValues(input);
  }

  void _showInputFailure(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _requiredTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    return text.length > 255 ? 'Use at most 255 characters' : null;
  }

  String? _optional255(String? value) =>
      (value?.length ?? 0) > 255 ? 'Use at most 255 characters' : null;

  String? _optionalHandle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > 255) return 'Use at most 255 characters';
    return RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(text)
        ? null
        : 'Use lowercase letters, numbers, and hyphens';
  }

  String? _optionTitleValidator(int index, String? value) {
    final required = _requiredTitle(value);
    if (required != null) return required;
    final title = value!.trim().toLowerCase();
    final duplicate = _options.indexed.any(
      (entry) =>
          entry.$1 != index &&
          entry.$2.title.text.trim().toLowerCase() == title,
    );
    return duplicate ? 'Use a unique option title' : null;
  }

  String? _optionValuesValidator(String? value) {
    final values = _parsedValues(value ?? '');
    if (values.isEmpty) return 'Enter at least one value';
    return values.any((item) => item.length > 255)
        ? 'Use at most 255 characters per value'
        : null;
  }

  String _slug(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
