import 'package:commerce_admin_shared/src/admin_return.dart';
import 'package:dust_dart/serde.dart';

part 'admin_return_list.g.dart';

/// One bounded page from the protected Admin return API.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminReturnList with _$AdminReturnList {
  /// Creates a merchant return page.
  const AdminReturnList({
    required this.returns,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes the generated list response.
  factory AdminReturnList.fromJson(Map<String, Object?> json) =>
      _$AdminReturnListFromJson(json);

  /// Total returns matching the active query.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Immutable return summaries in stable requested order.
  final List<AdminReturn> returns;
}
