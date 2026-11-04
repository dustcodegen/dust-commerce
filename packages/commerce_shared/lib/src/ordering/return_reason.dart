import 'package:dust_dart/serde.dart';

part 'return_reason.g.dart';

/// One active merchant-controlled reason exposed by the Store API.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ReturnReasonView with _$ReturnReasonView {
  /// Creates an explicit customer-safe reason allowlist.
  const ReturnReasonView({
    required this.id,
    required this.value,
    required this.label,
    required this.createdAt,
    required this.updatedAt,
    this.descriptionValue,
    this.parentReturnReasonIdValue,
  });

  /// Decodes one Store return reason.
  factory ReturnReasonView.fromJson(Map<String, Object?> json) =>
      _$ReturnReasonViewFromJson(json);

  /// When the merchant created this reason.
  final DateTime createdAt;

  /// Optional customer guidance.
  Option<String> get description => _reasonOption(descriptionValue);

  /// Nullable wire representation of [description].
  @SerDe(rename: 'description')
  final String? descriptionValue;

  /// Stable opaque reason identifier submitted with a return item.
  final String id;

  /// Customer-facing reason label.
  final String label;

  /// Optional parent used to group a reason taxonomy.
  Option<String> get parentReturnReasonId =>
      _reasonOption(parentReturnReasonIdValue);

  /// Nullable wire representation of [parentReturnReasonId].
  @SerDe(rename: 'parent_return_reason_id')
  final String? parentReturnReasonIdValue;

  /// When the merchant last changed this reason.
  final DateTime updatedAt;

  /// Stable machine value retained when the display label changes.
  final String value;
}

/// Paginated active return reasons matching Medusa's Store list envelope.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class ReturnReasonListView with _$ReturnReasonListView {
  /// Creates one counted Store reason page.
  const ReturnReasonListView({
    required this.returnReasons,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes a Store return-reason page.
  factory ReturnReasonListView.fromJson(Map<String, Object?> json) =>
      _$ReturnReasonListViewFromJson(json);

  /// Total active reasons matching the query.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of matching rows skipped before this page.
  final int offset;

  /// Active reasons in stable taxonomy order.
  final List<ReturnReasonView> returnReasons;
}

Option<T> _reasonOption<T>(T? value) => switch (value) {
      final T value => Some(value),
      null => const None(),
    };
