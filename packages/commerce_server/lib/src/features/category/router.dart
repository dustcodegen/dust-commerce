import 'package:commerce_server/src/features/category/handler/handler.dart';
import 'package:dust_server/server.dart';

/// Public category routes.
Router categoryRoutes() =>
    Router()..route('/product-categories', get(listCategoriesHandler));
