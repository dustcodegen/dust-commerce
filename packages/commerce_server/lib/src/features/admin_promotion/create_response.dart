import 'package:commerce_server/src/features/admin_promotion/model.dart';
import 'package:dust_dart/serde.dart';

part 'create_response.g.dart';

/// Medusa-compatible envelope returned after promotion creation.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminPromotionCreateResponse with _$AdminPromotionCreateResponse {
  /// Creates one explicit promotion response envelope.
  const AdminPromotionCreateResponse({required this.promotion});

  /// Direct SQLx promotion row without persistence-only fields.
  final AdminPromotionResponse promotion;
}
