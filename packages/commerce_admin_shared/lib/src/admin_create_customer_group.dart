import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_create_customer_group.g.dart';

/// Merchant input matching Medusa's focused customer-group form and API.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCreateCustomerGroup with _$AdminCreateCustomerGroup {
  /// Creates one validated customer segment input.
  const AdminCreateCustomerGroup({
    required this.name,
    required this.metadataValue,
  });

  /// Decodes one generated Admin request.
  factory AdminCreateCustomerGroup.fromJson(Map<String, Object?> json) =>
      _$AdminCreateCustomerGroupFromJson(json);

  /// Optional Medusa extension data at the request boundary.
  Option<Map<String, Object?>> get metadata => adminOptionOf(metadataValue);

  /// Nullable JSON backing for [metadata].
  @SerDe(rename: 'metadata')
  final Map<String, Object?>? metadataValue;

  /// Merchant-facing group name, normalized at the SerDe boundary.
  @SerDe(using: _CustomerGroupNameCodec())
  @Validate(length: Length(min: 1, max: 255), message: 'Enter a name')
  @Validate(regex: r'.*\S.*', message: 'Enter a name')
  final String name;
}

final class _CustomerGroupNameCodec implements SerDeCodec<String, String> {
  const _CustomerGroupNameCodec();

  @override
  String deserialize(String value) => value.trim();

  @override
  String serialize(String value) => value.trim();
}
