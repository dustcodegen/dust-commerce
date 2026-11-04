import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_sales_channel.g.dart';

/// Merchant-visible sales-channel choice used only by Admin clients.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminSalesChannel with _$AdminSalesChannel {
  /// Creates one immutable order-filter choice.
  const AdminSalesChannel({required this.id, required this.name});

  /// Decodes the generated Admin response.
  factory AdminSalesChannel.fromJson(Map<String, Object?> json) =>
      _$AdminSalesChannelFromJson(json);

  /// Stable commercial-origin identifier.
  final String id;

  /// Merchant-facing sales-channel name.
  final String name;
}

/// One bounded sales-channel page from the protected Admin API.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminSalesChannelList with _$AdminSalesChannelList {
  /// Creates a protected Admin sales-channel page.
  const AdminSalesChannelList({
    required this.salesChannels,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes the generated list response.
  factory AdminSalesChannelList.fromJson(Map<String, Object?> json) =>
      _$AdminSalesChannelListFromJson(json);

  /// Total matching non-deleted channels.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit sales-channel choices.
  final List<AdminSalesChannel> salesChannels;
}

/// Merchant editor row with only the fields shown by the Medusa table.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminSalesChannelDetail with _$AdminSalesChannelDetail {
  /// Creates one explicit editor row without exposing the database model.
  const AdminSalesChannelDetail({
    required this.id,
    required this.name,
    required this.descriptionValue,
    required this.isDisabled,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes the generated Admin response.
  factory AdminSalesChannelDetail.fromJson(Map<String, Object?> json) =>
      _$AdminSalesChannelDetailFromJson(json);

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Nullable JSON backing for [description].
  @SerDe(rename: 'description')
  final String? descriptionValue;

  /// Optional merchant context shown below the channel name.
  Option<String> get description => adminOptionOf(descriptionValue);

  /// Stable commercial-origin identifier.
  final String id;

  /// Whether new product assignments should be discouraged.
  final bool isDisabled;

  /// Merchant-facing sales-channel name.
  final String name;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}

/// One bounded page used by the product sales-channel editor.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminSalesChannelDetailList with _$AdminSalesChannelDetailList {
  /// Creates editor rows and their paging metadata.
  const AdminSalesChannelDetailList({
    required this.salesChannels,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes the generated editor response.
  factory AdminSalesChannelDetailList.fromJson(Map<String, Object?> json) =>
      _$AdminSalesChannelDetailListFromJson(json);

  /// Total matching non-deleted channels.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit editor rows.
  final List<AdminSalesChannelDetail> salesChannels;
}

/// Complete replacement of one product's sales-channel availability.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminUpdateProductSalesChannels
    with _$AdminUpdateProductSalesChannels {
  /// Creates one bounded product-channel selection.
  const AdminUpdateProductSalesChannels({required this.salesChannelIds});

  /// Decodes the generated Admin request.
  factory AdminUpdateProductSalesChannels.fromJson(
    Map<String, Object?> json,
  ) =>
      _$AdminUpdateProductSalesChannelsFromJson(json);

  /// Stable channel ids to keep attached; empty removes every assignment.
  @Validate(
    length: Length(max: 1000),
    message: 'Choose at most 1000 sales channels',
  )
  final List<String> salesChannelIds;
}
