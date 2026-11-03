import 'dart:convert';

import 'package:commerce_server/src/features/admin_customer/detail_address_response.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'detail_model.g.dart';

/// Complete customer detail populated directly from one SQLx projection.
@Derive([Serialize(), FromRow()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerDetailResponse with _$AdminCustomerDetailResponse {
  /// Creates the explicit profile and active-address response.
  const AdminCustomerDetailResponse({
    required this.id,
    required this.email,
    required this.companyName,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.hasAccount,
    required this.createdAt,
    required this.updatedAt,
    required this.addresses,
  });

  /// Active reusable destinations decoded from the same SQL projection.
  @Sqlx(
    rename: 'addresses_json',
    tryFrom: _AdminCustomerAddressesFromString(),
  )
  final List<AdminCustomerAddressResponse> addresses;

  /// Customer company when supplied.
  @Sqlx(rename: 'company_name')
  final String? companyName;

  /// Database-generated first-seen instant.
  @Sqlx(rename: 'created_at', tryFrom: _AdminCustomerDetailDateTime())
  final DateTime createdAt;

  /// Contact email when the profile supplied one.
  final String? email;

  /// Customer given name when supplied.
  @Sqlx(rename: 'first_name')
  final String? firstName;

  /// Whether this profile owns sign-in credentials.
  @Sqlx(rename: 'has_account')
  final bool hasAccount;

  /// Stable opaque customer identifier.
  final String id;

  /// Customer family name when supplied.
  @Sqlx(rename: 'last_name')
  final String? lastName;

  /// Customer contact number when supplied.
  final String? phone;

  /// Database-generated last mutation instant.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminCustomerDetailDateTime())
  final DateTime updatedAt;
}

final class _AdminCustomerAddressesFromString
    implements SqlxTryFrom<List<AdminCustomerAddressResponse>, String> {
  const _AdminCustomerAddressesFromString();

  @override
  List<AdminCustomerAddressResponse> decode(String value) =>
      (jsonDecode(value) as List<Object?>)
          .map((address) => AdminCustomerAddressResponse.fromJson(
                address! as Map<String, Object?>,
              ))
          .toList(growable: false);
}

final class _AdminCustomerDetailDateTime
    implements SqlxTryFrom<DateTime, DateTime> {
  const _AdminCustomerDetailDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}
