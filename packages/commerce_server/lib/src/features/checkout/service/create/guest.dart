import 'package:commerce_server/src/features/checkout/repository/create.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Persists the latest checkout contact as a non-authenticating profile.
Future<Result<ExecResult, SqlxError>> persistGuestCustomer(
  CheckoutCreateRepository customers,
  String Function() nextId,
  String email,
  Address shippingAddress,
) =>
    customers.upsertGuestCustomer(
      nextId(),
      email,
      shippingAddress.company,
      shippingAddress.firstName,
      shippingAddress.lastName,
      shippingAddress.phone,
    );
