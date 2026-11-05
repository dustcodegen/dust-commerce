part of 'admin_gate.dart';

/// Owns the authenticated Inventory/Locations route transition.
mixin _AdminInventoryActions on State<_AdminHome> {
  FocusNode get _stockLocationSearchFocus;
  _AdminRoute get _route;
  set _route(_AdminRoute value);
  String get _selectedId;
  set _selectedId(String value);

  void _showStockLocations() {
    context.readAdminStockLocationViewModel().load(offset: 0);
    setState(() {
      _route = _AdminRoute.stockLocations;
      _selectedId = '';
    });
  }

  void _requestInventorySearch() {
    _showStockLocations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _stockLocationSearchFocus.requestFocus();
    });
  }
}
