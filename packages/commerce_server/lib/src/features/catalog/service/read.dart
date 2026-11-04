import 'package:commerce_server/src/features/catalog/model.dart';
import 'package:commerce_server/src/features/catalog/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// One complete published product, or [None] when nothing matches [handle].
Future<Result<Option<ProductResponse>, SqlxError>> findProduct(
  CatalogReadRepository reads, {
  required String handle,
  required String currencyCode,
}) async {
  final found = await reads.findByHandle(handle, currencyCode);
  return switch (found) {
    Ok(:final value) => Ok(optionOf<ProductResponse>(value)),
    Err(:final error) => Err(error),
  };
}
