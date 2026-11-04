import 'package:commerce_server/src/features/admin_sales_channel/handler.dart';
import 'package:dust_server/server.dart';

/// Sales-channel routes merged beneath the parent Admin authentication layer.
Router adminSalesChannelRoutes() => Router()
  ..route('/sales-channels', get(listAdminSalesChannelsHandler))
  ..route(
    '/products/{id}/sales-channels',
    get(readAdminProductSalesChannelsHandler)
        .put(updateAdminProductSalesChannelsHandler),
  );
