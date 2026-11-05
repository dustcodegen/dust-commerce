part of 'admin_gate.dart';

/// Owns the authenticated Inventory/Locations route transition.
mixin _AdminInventoryActions on State<_AdminHome>, _AdminHomeActions {
  @override
  FocusNode get _stockLocationSearchFocus;

  @override
  void _showStockLocations() {
    context.readAdminStockLocationViewModel().load(offset: 0);
    setState(() {
      _route = _AdminRoute.stockLocations;
      _selectedId = '';
    });
  }

  @override
  void _requestInventorySearch() {
    _showStockLocations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _stockLocationSearchFocus.requestFocus();
    });
  }
}
