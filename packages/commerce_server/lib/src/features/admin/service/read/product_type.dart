import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Reads one active product type without exposing persistence fields.
Future<Result<Option<AdminProductTypeResponse>, SqlxError>>
    readAdminProductType(
  AdminProductTypeReadRepository productTypes,
  String id,
) async {
  final result = await productTypes.findProductType(id);
  return switch (result) {
    Ok(:final value) => Ok(optionOf(value)),
    Err(:final error) => Err(error),
  };
}
