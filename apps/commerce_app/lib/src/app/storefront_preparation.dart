part of 'commerce_app.dart';

extension on _CommerceAppState {
  Future<void> _prepareStorefront() async {
    await _shell.load();
    final country = storefrontCountryCode(widget.initialLocation);
    if (country != null) {
      final selected = _shell.state.regionForCountry(country);
      if (selected case Some(value: final region)) {
        await _cart.restore();
        await _cart.changeRegion(region.id);
        await _shell.selectCountry(country);
      }
    }
    if (!mounted) return;
    _showStorefront();
  }
}
