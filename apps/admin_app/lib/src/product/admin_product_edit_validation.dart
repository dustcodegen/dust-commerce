part of 'admin_product_edit_drawer.dart';

String _productEditTitleCase(String input) =>
    '${input[0].toUpperCase()}${input.substring(1)}';

String? _validateProductDescription(String? value) =>
    (value?.length ?? 0) > 20000 ? 'Use at most 20000 characters' : null;

String? _validateProductHandle(String? value) {
  final handle = value?.trim() ?? '';
  if (handle.isEmpty) return 'Enter a handle';
  if (handle.length > 255) return 'Use at most 255 characters';
  return RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(handle)
      ? null
      : 'Use lowercase letters, numbers, and hyphens';
}

String? _validateProductShortText(String? value) =>
    (value?.length ?? 0) > 255 ? 'Use at most 255 characters' : null;

String? _validateProductTitle(String? value) {
  final title = value?.trim() ?? '';
  if (title.isEmpty) return 'Enter a title';
  return title.length > 255 ? 'Use at most 255 characters' : null;
}
