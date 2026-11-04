import 'package:commerce_server/src/features/collection/deps.dart';
import 'package:commerce_server/src/features/collection/model.dart';
import 'package:commerce_server/src/features/collection/service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /collections` — public collections for rails and collection routes.
Future<Result<ProductCollectionListResponse, Rejection>> listCollectionsHandler(
  Request request,
) async {
  final state = await collectionDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CollectionDeps, Rejection>).value;
  final paging = pagingOf(request);

  final result = await listCollections(
    deps.collections,
    handle: queryOptionOf(request, 'handle'),
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}
