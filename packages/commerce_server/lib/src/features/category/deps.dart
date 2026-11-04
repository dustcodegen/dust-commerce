import 'package:commerce_server/src/features/category/repository/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// Dependencies for public category reads.
final class CategoryDeps {
  /// Creates category dependencies.
  const CategoryDeps({required this.categories});

  /// Public category listing queries.
  final ProductCategoryRepository categories;
}

/// Category dependencies attached by the application composition root.
Future<Result<CategoryDeps, Rejection>> categoryDeps(Request request) =>
    stateOf<CategoryDeps>(request);
