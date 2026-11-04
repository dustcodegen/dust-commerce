part of 'admin_gate.dart';

/// Owns customer-service inbox transitions and search focus.
mixin _AdminSupportActions on State<_AdminHome> {
  FocusNode get _supportSearchFocus;
  _AdminRoute get _route;
  set _route(_AdminRoute value);

  bool requestSupportSearch() {
    if (_route != _AdminRoute.customerService) return false;
    _showCustomerService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _supportSearchFocus.requestFocus();
    });
    return true;
  }

  void _showCustomerService() {
    context.readAdminCustomerServiceViewModel().load(offset: 0);
    setState(() {
      _route = _AdminRoute.customerService;
    });
  }
}
