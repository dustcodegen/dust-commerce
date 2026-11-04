import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/account/handler/handler.dart';
import 'package:dust_server/server.dart';

/// Medusa-shaped authentication routes.
Router accountAuthRoutes() {
  final protected = Router()
    ..routeLayer(fromExtractor(const CustomerAuth()))
    ..route('/session', delete(signOutHandler));

  return Router()
    ..route('/customer/emailpass', post(signInHandler))
    ..route(
      '/customer/emailpass/verification/confirm',
      post(confirmEmailHandler),
    )
    ..merge(protected);
}

/// Customer-account routes.
Router accountStoreRoutes() {
  final protected = Router()
    ..routeLayer(fromExtractor(const CustomerAuth()))
    ..route(
      '/customers/me',
      get(readCurrentCustomerHandler).patch(updateCustomerHandler),
    )
    ..route('/customers/me/password', patch(updatePasswordHandler))
    ..route(
      '/customers/me/addresses',
      get(listAddressesHandler).post(createAddressHandler, status: 201),
    )
    ..route(
      '/customers/me/addresses/{addressId}',
      patch(updateAddressHandler).delete(deleteAddressHandler),
    );

  return Router()
    ..route('/customers', post(registerAccountHandler, status: 201))
    ..merge(protected);
}
