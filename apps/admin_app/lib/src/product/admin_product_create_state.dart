import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_product_create_state.g.dart';

/// Lifecycle of the Medusa-shaped product creation surface.
enum AdminProductCreateStatus {
  /// No create-context request has started.
  idle,

  /// Active storefront currencies are loading.
  loading,

  /// The form can accept merchant input.
  ready,

  /// The product graph is being committed.
  saving,

  /// Selected image bytes are streaming into merchant storage.
  uploading,

  /// Context loading failed.
  failed,
}

/// Typed creation state without transport responses in the widget tree.
@Derive([ToString(), Eq(), CopyWith()])
final class AdminProductCreateState with _$AdminProductCreateState {
  /// Creates an empty product creation state.
  const AdminProductCreateState({
    this.status = AdminProductCreateStatus.idle,
    this.currencyCodes = const [],
    this.productTypes = const [],
    this.created = const None(),
    this.failure = const None(),
  });

  /// Product returned after one successful atomic creation.
  final Option<AdminProductDetail> created;

  /// Sorted active regional currencies required for every variant.
  final List<String> currencyCodes;

  /// Display-safe create or context failure.
  final Option<String> failure;

  /// Active classifications available in Medusa's Organize step.
  final List<AdminProductType> productTypes;

  /// Current create lifecycle.
  final AdminProductCreateStatus status;

  /// Whether form controls must reject duplicate submission.
  bool get isBusy =>
      status == AdminProductCreateStatus.saving ||
      status == AdminProductCreateStatus.uploading;
}
