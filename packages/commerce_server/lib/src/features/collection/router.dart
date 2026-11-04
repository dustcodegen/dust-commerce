import 'package:commerce_server/src/features/collection/handler/handler.dart';
import 'package:dust_server/server.dart';

/// Public collection routes.
Router collectionRoutes() =>
    Router()..route('/collections', get(listCollectionsHandler));
