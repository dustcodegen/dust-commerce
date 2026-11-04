import 'package:commerce_server/src/features/account/model.dart';
import 'package:commerce_server/src/features/account/repository/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists the active addresses owned by one authenticated customer.
Future<Result<List<CustomerAddressResponse>, SqlxError>> listCustomerAddresses(
  AccountListRepository lists,
  String customerId,
) =>
    lists.addresses(customerId);
