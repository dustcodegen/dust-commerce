import 'package:commerce_server/src/features/collection/repository/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// Dependencies for public collection reads.
final class CollectionDeps {
  /// Creates collection dependencies.
  const CollectionDeps({required this.collections});

  /// Public collection listing queries.
  final ProductCollectionRepository collections;
}

/// Collection dependencies attached by the application composition root.
Future<Result<CollectionDeps, Rejection>> collectionDeps(Request request) =>
    stateOf<CollectionDeps>(request);
