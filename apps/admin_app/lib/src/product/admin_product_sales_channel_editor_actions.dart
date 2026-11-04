part of 'admin_product_sales_channel_editor.dart';

mixin _SalesChannelEditorActions on State<_SalesChannelEditor> {
  final _horizontal = ScrollController();
  final _search = TextEditingController();
  late AdminSalesChannelDetailList _page;
  late final Set<String> _selected;
  Option<String> _failure = const None();
  Timer? _debounce;
  bool _loading = false;
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
    _selected = {for (final channel in widget.assigned) channel.id};
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _horizontal.dispose();
    _search.dispose();
    super.dispose();
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _load(0));
  }

  Future<void> _load(int offset) async {
    final revision = ++_revision;
    setState(() => _loading = true);
    final result =
        await context.readAdminProductDetailViewModel().salesChannelChoices(
              query: _search.text,
              offset: offset,
            );
    if (!mounted || revision != _revision) return;
    switch (result) {
      case Some(value: final page):
        setState(() {
          _page = page;
          _failure = const None();
          _loading = false;
        });
      case None():
        final state = context.readAdminProductDetailViewModel().state;
        setState(() {
          _failure = state.failure;
          _loading = false;
        });
    }
  }

  Future<void> _save() async {
    final ids = _selected.toList()..sort();
    final saved =
        await context.readAdminProductDetailViewModel().updateSalesChannels(
              widget.product.id,
              AdminUpdateProductSalesChannels(salesChannelIds: ids),
            );
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _failure = context.readAdminProductDetailViewModel().state.failure;
      });
    }
  }

  void _toggle(String id) => setState(() {
        _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
      });

  void _togglePage(bool selected) => setState(() {
        for (final channel in _page.salesChannels) {
          selected ? _selected.add(channel.id) : _selected.remove(channel.id);
        }
      });
}
