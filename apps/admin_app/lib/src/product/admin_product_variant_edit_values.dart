part of 'admin_product_variant_edit_drawer.dart';

final class _VariantEditValues {
  _VariantEditValues(AdminProductVariant variant)
      : title = TextEditingController(text: variant.title),
        material = TextEditingController(text: variant.material ?? ''),
        sku = TextEditingController(text: variant.sku ?? ''),
        ean = TextEditingController(text: variant.ean ?? ''),
        upc = TextEditingController(text: variant.upc ?? ''),
        barcode = TextEditingController(text: variant.barcode ?? ''),
        weight = TextEditingController(text: _number(variant.weight)),
        width = TextEditingController(text: _number(variant.width)),
        length = TextEditingController(text: _number(variant.length)),
        height = TextEditingController(text: _number(variant.height)),
        midCode = TextEditingController(text: variant.midCode ?? ''),
        hsCode = TextEditingController(text: variant.hsCode ?? ''),
        originCountry = TextEditingController(
          text: adminCountryName(variant.originCountry),
        );

  final TextEditingController barcode;
  final TextEditingController ean;
  final TextEditingController height;
  final TextEditingController hsCode;
  final TextEditingController length;
  final TextEditingController material;
  final TextEditingController midCode;
  final TextEditingController originCountry;
  final FocusNode originCountryFocus = FocusNode();
  final TextEditingController sku;
  final TextEditingController title;
  final TextEditingController upc;
  final TextEditingController weight;
  final TextEditingController width;

  AdminUpdateProductVariant request({
    required bool manageInventory,
    required bool allowBackorder,
    required String? originCountry,
    required Map<String, String> optionValues,
  }) =>
      AdminUpdateProductVariant(
        title: title.text.trim(),
        material: material.text,
        sku: sku.text,
        ean: ean.text,
        upc: upc.text,
        barcode: barcode.text,
        manageInventory: manageInventory,
        allowBackorder: allowBackorder,
        weight: _parse(weight),
        width: _parse(width),
        length: _parse(length),
        height: _parse(height),
        midCode: midCode.text,
        hsCode: hsCode.text,
        originCountry: originCountry,
        optionValues: optionValues,
      );

  void dispose() {
    for (final controller in [
      title,
      material,
      sku,
      ean,
      upc,
      barcode,
      weight,
      width,
      length,
      height,
      midCode,
      hsCode,
      originCountry,
    ]) {
      controller.dispose();
    }
    originCountryFocus.dispose();
  }

  static String _number(double? value) => value?.toString() ?? '';

  static double? _parse(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : double.parse(value);
  }
}
