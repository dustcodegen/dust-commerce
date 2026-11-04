import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'address_book_state.g.dart';

/// Lifecycle of the authenticated customer's address book.
enum AddressBookStatus {
  /// No request has started.
  idle,

  /// The initial address listing is loading.
  loading,

  /// A create, update, or delete request is running.
  mutating,

  /// The current server-backed address list is ready.
  ready,

  /// The latest request failed while retaining the last good list.
  failed,
}

/// Address-book operation visible to the account UI.
enum AddressBookOperation {
  /// Fetching addresses and active selling regions.
  load,

  /// Adding a new saved address.
  create,

  /// Replacing an existing saved address.
  update,

  /// Soft-deleting an existing saved address.
  delete,
}

/// Immutable server-backed address-book state.
@Derive([ToString(), Eq(), CopyWith()])
final class AddressBookState with _$AddressBookState {
  /// Creates address-book state without nullable absence sentinels.
  const AddressBookState({
    this.addresses = const [],
    this.regions = const [],
    this.hasLoaded = false,
    this.status = AddressBookStatus.idle,
    this.operation = const None(),
    this.message = const None(),
  });

  /// Active customer-owned addresses.
  final List<CustomerAddressView> addresses;

  /// Active selling regions available to new and edited addresses.
  final List<Region> regions;

  /// Whether at least one complete server response has been accepted.
  final bool hasLoaded;

  /// Display-safe failure, when present.
  final Option<String> message;

  /// Request currently running or most recently failed.
  final Option<AddressBookOperation> operation;

  /// Current lifecycle.
  final AddressBookStatus status;

  /// Whether controls should reject duplicate submissions.
  bool get isBusy => switch (status) {
        AddressBookStatus.loading || AddressBookStatus.mutating => true,
        _ => false,
      };

  /// Distinct country codes offered by every active selling region.
  List<String> get countries => {
        for (final region in regions) ...region.countries,
      }.toList(growable: false);

  /// Saved destinations accepted by the cart's selling region.
  List<CustomerAddressView> shippingAddressesFor(
    Iterable<String> countryCodes,
  ) {
    final allowed = {
      for (final country in countryCodes) country.trim().toLowerCase(),
    };
    return addresses
        .where((address) => allowed.contains(address.countryCode.toLowerCase()))
        .toList(growable: false);
  }
}
