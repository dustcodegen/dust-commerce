import 'package:commerce_server/src/features/admin/product_option_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of global merchant product options.
Future<Result<AdminProductOptionListResponse, SqlxError>>
    listAdminProductOptions(
  AdminProductOptionRepository options, {
  required String query,
  required int limit,
  required int offset,
}) async {
  final normalized = query.trim();
  final page = await options.list(normalized, limit, offset);
  if (page case Err(:final error)) return Err(error);
  final total = await options.count(normalized);
  if (total case Err(:final error)) return Err(error);

  return Ok(AdminProductOptionListResponse(
    productOptions:
        (page as Ok<List<AdminProductOptionSummaryResponse>, SqlxError>).value,
    count: (total as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

/// Reads one active product option or [None] when it is unknown.
Future<Result<Option<AdminProductOptionDetailResponse>, SqlxError>>
    readAdminProductOption(
  AdminProductOptionRepository options,
  String id,
) async {
  final result = await options.findById(id);
  return switch (result) {
    Ok(:final value) => Ok(optionOf(value)),
    Err(:final error) => Err(error),
  };
}
