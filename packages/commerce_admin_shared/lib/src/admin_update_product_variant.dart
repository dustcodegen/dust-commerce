import 'package:dust_dart/serde.dart';

part 'admin_update_product_variant.g.dart';

/// Complete replacement of the fields in Medusa's variant detail drawer.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateProductVariant with _$AdminUpdateProductVariant {
  /// Creates one validated merchant variant update.
  const AdminUpdateProductVariant({
    required this.title,
    required this.manageInventory,
    required this.allowBackorder,
    required this.optionValues,
    this.material,
    this.sku,
    this.ean,
    this.upc,
    this.barcode,
    this.weight,
    this.width,
    this.length,
    this.height,
    this.midCode,
    this.hsCode,
    this.originCountry,
  });

  /// Decodes the generated variant input.
  factory AdminUpdateProductVariant.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateProductVariantFromJson(json);

  /// Whether sales may continue after tracked stock is exhausted.
  final bool allowBackorder;

  /// Optional machine-readable product identifier; an empty value clears it.
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? barcode;

  /// Optional European Article Number; an empty value clears it.
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? ean;

  /// Optional non-negative height in the merchant's configured unit.
  @Validate(range: Range(min: 0), message: 'Enter a non-negative height')
  final double? height;

  /// Optional Harmonized System code; an empty value clears it.
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? hsCode;

  /// Optional non-negative length in the merchant's configured unit.
  @Validate(range: Range(min: 0), message: 'Enter a non-negative length')
  final double? length;

  /// Whether checkout enforces this variant's inventory quantity.
  final bool manageInventory;

  /// Optional variant-specific material; an empty value clears it.
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? material;

  /// Optional Manufacturer Identification code; an empty value clears it.
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? midCode;

  /// Selected value keyed by stable product-option identifier.
  final Map<String, String> optionValues;

  /// Optional ISO 3166-1 alpha-2 origin country; an empty value clears it.
  @Validate(
    regex: r'^\s*$|^\s*[A-Za-z]{2}\s*$',
    message: 'Choose a two-letter country',
  )
  final String? originCountry;

  /// Optional unique merchant stock identifier; an empty value clears it.
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? sku;

  /// Required merchant-facing variant name.
  @Validate(length: Length(min: 1, max: 255), message: 'Enter a variant name')
  @Validate(regex: r'.*\S.*', message: 'Enter a variant name')
  final String title;

  /// Optional Universal Product Code; an empty value clears it.
  @Validate(length: Length(max: 255), message: 'Use at most 255 characters')
  final String? upc;

  /// Optional non-negative weight in the merchant's configured unit.
  @Validate(range: Range(min: 0), message: 'Enter a non-negative weight')
  final double? weight;

  /// Optional non-negative width in the merchant's configured unit.
  @Validate(range: Range(min: 0), message: 'Enter a non-negative width')
  final double? width;
}
