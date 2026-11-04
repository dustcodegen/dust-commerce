import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/derive.dart';

part 'admin_shipping_profile_state.g.dart';

/// Lifecycle of the shipping-profile settings table.
enum AdminShippingProfileStatus {
  /// No request has started.
  idle,

  /// A bounded profile page is loading.
  loading,

  /// The requested page is ready.
  ready,

  /// The request failed with display-safe copy.
  failed,
}

/// Immutable state for shipping-profile administration.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminShippingProfileState with _$AdminShippingProfileState {
  /// Creates list state without transport objects in widgets.
  const AdminShippingProfileState({
    this.status = AdminShippingProfileStatus.idle,
    this.shippingProfiles = const [],
    this.count = 0,
    this.limit = 20,
    this.offset = 0,
    this.query = '',
    this.name = '',
    this.type = '',
    this.createdAt = const AdminDateFilter(),
    this.updatedAt = const AdminDateFilter(),
    this.order = AdminShippingProfileOrder.nameAsc,
    this.failure = const None(),
  });

  /// Total rows matching [query].
  final int count;

  /// Creation-time comparison applied by the server.
  final AdminDateFilter createdAt;

  /// Display-safe failure message.
  final Option<String> failure;

  /// Server-owned page size.
  final int limit;

  /// Dedicated normalized profile-name filter.
  final String name;

  /// Number of matching rows skipped.
  final int offset;

  /// Server-owned stable profile ordering.
  final AdminShippingProfileOrder order;

  /// Current normalized name-or-type search.
  final String query;

  /// Current explicit fulfillment rows.
  final List<AdminShippingProfile> shippingProfiles;

  /// Current request lifecycle.
  final AdminShippingProfileStatus status;

  /// Dedicated normalized fulfillment-type filter.
  final String type;

  /// Update-time comparison applied by the server.
  final AdminDateFilter updatedAt;

  /// Whether another server page exists.
  bool get hasNext => offset + shippingProfiles.length < count;

  /// Whether a preceding server page exists.
  bool get hasPrevious => offset > 0;

  /// Whether a profile filter, excluding search and ordering, is active.
  bool get hasFilters =>
      name.isNotEmpty ||
      type.isNotEmpty ||
      !createdAt.isEmpty ||
      !updatedAt.isEmpty;
}
