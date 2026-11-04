import 'package:commerce_server/src/features/admin_region/handler.dart';
import 'package:dust_server/server.dart';

/// Region routes merged beneath the parent Admin authentication layer.
Router adminRegionRoutes() =>
    Router()..route('/regions', get(listAdminRegionsHandler));
