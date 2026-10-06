import 'dart:async';

import 'package:commerce_app/src/core/store_theme.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa Store search box backed by the product-listing route query.
final class ListingSearchBox extends StatefulWidget {
  /// Creates the search box.
  const ListingSearchBox({
    required this.query,
    required this.onChanged,
    super.key,
  });

  /// Current route query.
  final String query;

  /// Debounced query replacement.
  final ValueChanged<String> onChanged;

  @override
  State<ListingSearchBox> createState() => _ListingSearchBoxState();
}

final class _ListingSearchBoxState extends State<ListingSearchBox> {
  late final TextEditingController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(ListingSearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && _controller.text != widget.query) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: StoreColors.border)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              size: 20,
              color: StoreColors.foregroundMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: context.tr(
                    'shop_search_products',
                    defaultText: 'Search products',
                  ),
                  hintStyle:
                      const TextStyle(color: StoreColors.foregroundMuted),
                  isDense: true,
                ),
                style: const TextStyle(
                  color: StoreColors.foreground,
                  fontSize: 16,
                  height: 1.5,
                ),
                onChanged: _changed,
              ),
            ),
            if (_controller.text.isNotEmpty)
              Semantics(
                button: true,
                label: context.tr(
                  'shop_search_clear',
                  defaultText: 'Clear search',
                ),
                child: InkWell(
                  hoverColor: Colors.transparent,
                  onTap: _clear,
                  child: const Icon(
                    Icons.close,
                    color: StoreColors.foregroundMuted,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      );

  void _changed(String value) {
    setState(() {});
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 250), () {
      widget.onChanged(value);
    });
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    setState(() {});
    widget.onChanged('');
  }
}
