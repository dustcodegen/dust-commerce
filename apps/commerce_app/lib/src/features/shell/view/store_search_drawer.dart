import 'dart:async';

import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_app/src/features/shell/view/store_search_field.dart';
import 'package:commerce_app/src/features/shell/view/store_search_widgets.dart';
import 'package:commerce_app/src/features/shell/view_model/store_shell_view_model.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Right-side product search drawer translated from Medusa DTC.
final class StoreSearchDrawer extends StatefulWidget {
  /// Creates the search drawer.
  const StoreSearchDrawer({
    required this.shell,
    required this.currencyCode,
    required this.onProductSelected,
    super.key,
  });

  /// Currency used by product results.
  final String currencyCode;

  /// Navigates to the chosen product handle.
  final ValueChanged<String> onProductSelected;

  /// Shared shell view model that owns public Store discovery calls.
  final StoreShellViewModel shell;

  @override
  State<StoreSearchDrawer> createState() => _StoreSearchDrawerState();
}

final class _StoreSearchDrawerState extends State<StoreSearchDrawer> {
  final _controller = TextEditingController();
  Timer? _timer;
  var _failed = false;
  var _loading = false;
  var _query = '';
  var _revision = 0;
  var _searched = false;
  List<Product> _hits = const [];

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: StoreColors.base,
        child: SizedBox(
          width: width < 448 ? width : 448,
          height: double.infinity,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: StoreColors.border)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 24,
                  color: Color(0x1a18181b),
                  offset: Offset(-8, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  StoreSearchHeader(
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  StoreSearchField(
                    controller: _controller,
                    onChanged: _changed,
                    onClear: _clear,
                  ),
                  Expanded(
                    child: StoreSearchBody(
                      failed: _failed,
                      hits: _hits,
                      loading: _loading,
                      query: _query,
                      searched: _searched,
                      onProductSelected: widget.onProductSelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changed(String value) {
    _timer?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _failed = false;
        _hits = const [];
        _loading = false;
        _query = '';
        _searched = false;
      });
      return;
    }
    setState(() {
      _failed = false;
      _loading = _hits.isEmpty;
      _query = query;
      _searched = true;
    });
    _timer = Timer(const Duration(milliseconds: 250), () => _search(query));
  }

  void _clear() {
    _controller.clear();
    _changed('');
  }

  Future<void> _search(String query) async {
    final revision = ++_revision;
    setState(() {
      _failed = false;
      _loading = true;
      _query = query;
      _searched = true;
    });
    try {
      final page = await widget.shell.searchProducts(
        query,
        currencyCode: widget.currencyCode,
      );
      if (!mounted || revision != _revision) return;
      setState(() {
        _hits = page.products;
        _loading = false;
      });
    } on Object {
      if (!mounted || revision != _revision) return;
      setState(() {
        _failed = true;
        _hits = const [];
        _loading = false;
      });
    }
  }
}

/// Drawer title row.
final class StoreSearchHeader extends StatelessWidget {
  /// Creates the title row.
  const StoreSearchHeader({required this.onClose, super.key});

  /// Closes the drawer.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: StoreColors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    context.tr('shop_search_title', defaultText: 'Search'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 28 / 18,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: context.tr(
                  'shop_search_close',
                  defaultText: 'Close search',
                ),
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      );
}
