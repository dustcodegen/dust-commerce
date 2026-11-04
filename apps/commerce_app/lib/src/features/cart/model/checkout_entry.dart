import 'package:commerce_shared/commerce_shared.dart';

/// Returns the first incomplete checkout step used by Medusa's cart summary.
String checkoutEntryStep(Cart cart) {
  final email = cart.email;
  if (cart.shippingAddress == null || email == null || email.isEmpty) {
    return 'address';
  }
  return cart.shippingMethod == null ? 'delivery' : 'payment';
}
