import 'package:commerce_server/src/features/collection/model.dart';
import 'package:commerce_server/src/features/collection/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Lists public product collections with an optional route-handle filter.
Future<Result<ProductCollectionListResponse, SqlxError>> listCollections(
  ProductCollectionRepository collections, {
  Option<String> handle = const None(),
  int limit = 20,
  int offset = 0,
}) async {
  final result = await collections.list(nullableOf(handle), limit, offset);
  return switch (result) {
    Ok(:final value) => Ok(ProductCollectionListResponse(
        collections: value,
        count: value.length,
      )),
    Err(:final error) => Err(error),
  };
}
