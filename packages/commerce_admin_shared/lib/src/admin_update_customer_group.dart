import 'package:dust_dart/serde.dart';

part 'admin_update_customer_group.g.dart';

/// Merchant input matching Medusa's customer-group edit drawer.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateCustomerGroup with _$AdminUpdateCustomerGroup {
  /// Creates one explicit customer-group name replacement.
  const AdminUpdateCustomerGroup({required this.name});

  /// Decodes one generated Admin update request.
  factory AdminUpdateCustomerGroup.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateCustomerGroupFromJson(json);

  /// Merchant-facing group name, normalized at the SerDe boundary.
  @SerDe(using: _UpdateCustomerGroupNameCodec())
  @Validate(length: Length(min: 1, max: 255), message: 'Enter a name')
  @Validate(regex: r'.*\S.*', message: 'Enter a name')
  final String name;
}

final class _UpdateCustomerGroupNameCodec
    implements SerDeCodec<String, String> {
  const _UpdateCustomerGroupNameCodec();

  @override
  String deserialize(String value) => value.trim();

  @override
  String serialize(String value) => value.trim();
}
