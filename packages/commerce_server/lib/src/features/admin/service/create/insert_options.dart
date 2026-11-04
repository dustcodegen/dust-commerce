part of '../create.dart';

/// Persists the exclusive option graph owned by a newly created product.
Future<Result<Map<String, _CreatedOption>, SqlxError>> _insertCreatedOptions(
  AdminProductCreateRepository writes,
  String productId,
  List<_PreparedOption> options,
  String Function() nextId,
) async {
  final created = <String, _CreatedOption>{};
  for (final option in options) {
    final optionId = nextId();
    final optionWrite = await writes.insertOption(optionId, option.title);
    if (optionWrite case Err(:final error)) return Err(error);
    final productOptionId = nextId();
    final linkWrite = await writes.insertProductOption(
      productOptionId,
      productId,
      optionId,
    );
    if (linkWrite case Err(:final error)) return Err(error);
    final values = <String, String>{};
    for (var rank = 0; rank < option.values.length; rank++) {
      final value = option.values[rank];
      final valueId = nextId();
      final valueWrite = await writes.insertOptionValue(
        valueId,
        optionId,
        value,
        rank,
      );
      if (valueWrite case Err(:final error)) return Err(error);
      final availabilityWrite = await writes.insertProductOptionValue(
        nextId(),
        productOptionId,
        valueId,
      );
      if (availabilityWrite case Err(:final error)) return Err(error);
      values[value] = valueId;
    }
    created[option.title] = _CreatedOption(optionId, values);
  }
  return Ok(created);
}
