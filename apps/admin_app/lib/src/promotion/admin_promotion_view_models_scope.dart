import 'package:admin_app/src/bootstrap/admin_dependencies.dart';
import 'package:admin_app/src/promotion/admin_promotion_create_view_model.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_view_model.dart';
import 'package:admin_app/src/promotion/admin_promotion_view_model.dart';
import 'package:flutter/widgets.dart';

/// Groups the three promotion states without growing the global scope tree.
final class AdminPromotionViewModels extends StatelessWidget {
  /// Creates the promotion state group.
  const AdminPromotionViewModels({
    required this.dependencies,
    required this.child,
    super.key,
  });

  /// Long-lived Admin dependencies.
  final AdminDependencies dependencies;

  /// Descendant route tree.
  final Widget child;

  @override
  Widget build(BuildContext context) => AdminPromotionViewModelScope.value(
        value: dependencies.promotions,
        child: AdminPromotionCreateViewModelScope.value(
          value: dependencies.promotionCreate,
          child: AdminPromotionDetailViewModelScope.value(
            value: dependencies.promotionDetail,
            child: child,
          ),
        ),
      );
}
