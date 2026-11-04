import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Opens the compact option picker as a labelled, bottom-aligned route.
Future<void> showMobileProductOptions(BuildContext context) =>
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: const Color(0xff374151).withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, routeAnimation, secondaryAnimation) =>
          const _MobileProductOptionsRoute(),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final progress = animation.drive(
          CurveTween(curve: Curves.easeOutCubic),
        );
        return FadeTransition(opacity: progress, child: child);
      },
    );

final class _MobileProductOptionsRoute extends StatelessWidget {
  const _MobileProductOptionsRoute();

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              // shortcut: native blur is deferred until Dust can resolve
              // dart:ui from Flutter's SDK source map.
              child: const ColoredBox(color: Color(0xBF374151)),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              type: MaterialType.transparency,
              child: _MobileProductOptionsSheet(),
            ),
          ),
        ],
      );
}

final class _MobileProductOptionsSheet extends StatelessWidget {
  const _MobileProductOptionsSheet();

  @override
  Widget build(BuildContext context) {
    final state = context.watchProductViewModel().value;
    final busy =
        context.watchCartViewModel().value.status == CartStatus.loading;
    if (state.product == null) return const SizedBox.shrink();
    return Semantics(
      container: true,
      namesRoute: true,
      label: context.tr('shop_select_options', defaultText: 'Select options'),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 24),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Material(
                  color: StoreColors.base,
                  shape: const CircleBorder(),
                  child: SizedBox.square(
                    dimension: 48,
                    child: IconButton(
                      tooltip:
                          MaterialLocalizations.of(context).closeButtonTooltip,
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ColoredBox(
              color: StoreColors.base,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
                child: ProductOptionGroups(
                  state: state,
                  disabled: busy,
                  axisSpacing: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
