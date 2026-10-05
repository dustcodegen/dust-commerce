import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// Responsive product composition with source-matched sticky behavior.
class ProductLayout extends StatefulWidget {
  /// Creates the complete product page body for [state].
  const ProductLayout({required this.state, super.key});

  /// Current product, recommendation and option-selection state.
  final ProductDetailState state;

  @override
  State<ProductLayout> createState() => _ProductLayoutState();
}

class _ProductLayoutState extends State<ProductLayout> {
  final GlobalKey<State<StatefulWidget>> _actionsKey =
      GlobalKey<State<StatefulWidget>>();
  final GlobalKey<State<StatefulWidget>> _scrollKey =
      GlobalKey<State<StatefulWidget>>();
  final _scrollController = ScrollController();
  var _showMobileActions = false;
  var _visibilityScheduled = false;
  var _wide = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scheduleVisibility);
    _scheduleVisibility();
  }

  @override
  void didUpdateWidget(ProductLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleVisibility();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_scheduleVisibility)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          _wide = constraints.maxWidth >= 1024;
          _scheduleVisibility();
          final horizontal =
              (((constraints.maxWidth - 1440) / 2).clamp(0, double.infinity) +
                      24)
                  .toDouble();
          return Stack(
            children: [
              CustomScrollView(
                key: _scrollKey,
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding:
                        EdgeInsets.fromLTRB(horizontal, 24, horizontal, 24),
                    sliver: ProductSection(
                      state: widget.state,
                      wide: _wide,
                      inlineActionsKey: _actionsKey,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    sliver: SliverToBoxAdapter(
                      child: RelatedProducts(state: widget.state),
                    ),
                  ),
                  const SliverToBoxAdapter(child: StoreFooter()),
                  if (!_wide)
                    const SliverToBoxAdapter(child: SizedBox(height: 144)),
                ],
              ),
              if (!_wide)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    ignoring: !_showMobileActions,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      offset:
                          _showMobileActions ? Offset.zero : const Offset(0, 1),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _showMobileActions ? 1 : 0,
                        child: MobileProductActions(state: widget.state),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );

  void _scheduleVisibility() {
    if (_visibilityScheduled || !mounted) return;
    _visibilityScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityScheduled = false;
      if (!mounted) return;
      final actions = _actionsKey.currentContext?.findRenderObject();
      final viewport = _scrollKey.currentContext?.findRenderObject();
      var show = false;
      if (!_wide && actions is RenderBox && viewport is RenderBox) {
        final actionsRect = actions.localToGlobal(Offset.zero) & actions.size;
        final viewportRect =
            viewport.localToGlobal(Offset.zero) & viewport.size;
        show = !actionsRect.overlaps(viewportRect);
      }
      if (show != _showMobileActions) {
        setState(() => _showMobileActions = show);
      }
    });
  }
}
