import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'cart_preview_panel.dart';

/// Desktop cart popover translated from Medusa's `CartDropdown`.
class CartPreview extends StatefulWidget {
  /// Creates the navigation cart control.
  const CartPreview({super.key});

  @override
  State<CartPreview> createState() => _CartPreviewState();
}

class _CartPreviewState extends State<CartPreview> {
  final _controller = MenuController();
  Timer? _autoCloseTimer;
  Timer? _hoverCloseTimer;
  bool _isTimedOpen = false;
  int? _lastCount;
  CartOperation? _lastOperation;

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _hoverCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchCartViewModel().value;
    final count = state.itemCount;
    final desktop = MediaQuery.sizeOf(context).width >= 1024;
    final onCart =
        RouterController.of<CommerceRoute>(context).currentRoute is CartRoute;
    _observeCount(count, state.operation, desktop: desktop, onCart: onCart);

    final button = TextButton(
      onPressed: () {
        _close();
        context.navigator.cart().go();
      },
      child: Text(
        context.tr(
          'shop_cart_count',
          defaultText: 'Cart ({count})',
          args: {'count': count},
        ),
        style: const TextStyle(
          fontSize: 12,
          height: 20 / 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
    if (!desktop) return button;

    return MenuAnchor(
      controller: _controller,
      useRootOverlay: true,
      alignmentOffset: const Offset(0, 1),
      style: const MenuStyle(
        alignment: AlignmentDirectional.bottomEnd,
        backgroundColor: WidgetStatePropertyAll(StoreColors.base),
        elevation: WidgetStatePropertyAll(0),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      menuChildren: [
        // MenuAnchor constrains its surface to the root overlay. Padding the
        // child preserves the source panel's 24px header gutter at that edge.
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: CartPreviewPanel(
            state: state,
            onEnter: _open,
            onExit: _scheduleClose,
            onClose: _close,
          ),
        ),
      ],
      child: MouseRegion(
        onEnter: (_) => _open(),
        onExit: (_) => _scheduleClose(),
        child: button,
      ),
    );
  }

  void _observeCount(
    int count,
    CartOperation? operation, {
    required bool desktop,
    required bool onCart,
  }) {
    final previous = _lastCount;
    final previousOperation = _lastOperation;
    _lastCount = count;
    _lastOperation = operation;
    if (previous == null || previous == count || !desktop || onCart) return;
    if (previousOperation == CartOperation.restore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _open(timed: true);
    });
  }

  void _open({bool timed = false}) {
    _hoverCloseTimer?.cancel();
    if (!_controller.isOpen) _controller.open();
    if (!timed) {
      _isTimedOpen = false;
      _autoCloseTimer?.cancel();
      return;
    }
    _isTimedOpen = true;
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(seconds: 5), _close);
  }

  void _scheduleClose() {
    if (_isTimedOpen) return;
    _hoverCloseTimer?.cancel();
    _hoverCloseTimer = Timer(const Duration(milliseconds: 120), _close);
  }

  void _close() {
    _isTimedOpen = false;
    _autoCloseTimer?.cancel();
    _hoverCloseTimer?.cancel();
    if (_controller.isOpen) _controller.close();
  }
}
