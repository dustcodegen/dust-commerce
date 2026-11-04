import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

import 'free_shipping_popup.dart';

/// Global popup translated from Medusa's `FreeShippingPriceNudge`.
final class FreeShippingPriceNudge extends StatefulWidget {
  /// Creates the source-shaped free-shipping popup.
  const FreeShippingPriceNudge({super.key});

  @override
  State<FreeShippingPriceNudge> createState() => _FreeShippingPriceNudgeState();
}

final class _FreeShippingPriceNudgeState extends State<FreeShippingPriceNudge> {
  Timer? _fadeTimer;
  String? _belowTargetCartId;
  String? _fadingCartId;
  String? _hiddenCartId;

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchCartViewModel().value;
    final cart = state.cart;
    if (cart == null || state.isFreeShippingNudgeDismissedFor(cart.cart.id)) {
      return const SizedBox.shrink();
    }
    final progress = freeShippingProgressOf(cart, state.shippingOptions);
    final FreeShippingProgress value;
    switch (progress) {
      case Some<FreeShippingProgress>(value: final current):
        value = current;
      case None<FreeShippingProgress>():
        return const SizedBox.shrink();
    }
    final cartId = cart.cart.id;
    if (!value.targetReached) {
      _fadeTimer?.cancel();
      _belowTargetCartId = cartId;
      _fadingCartId = null;
      _hiddenCartId = null;
    } else if (_belowTargetCartId != cartId || _hiddenCartId == cartId) {
      return const SizedBox.shrink();
    } else {
      _scheduleFade(cartId);
    }
    return FreeShippingPopup(
      progress: value,
      fading: _fadingCartId == cartId,
      onFadeEnd: () => _finishFade(cartId),
    );
  }

  void _scheduleFade(String cartId) {
    if (_fadingCartId == cartId ||
        _hiddenCartId == cartId ||
        (_fadeTimer?.isActive ?? false)) {
      return;
    }
    _fadeTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() => _fadingCartId = cartId);
    });
  }

  void _finishFade(String cartId) {
    if (_fadingCartId != cartId || !mounted) return;
    setState(() => _hiddenCartId = cartId);
  }
}
