part of 'admin_product_shipping_profile_drawer.dart';

mixin _ShippingProfileDrawerActions on State<_ShippingProfileDrawer> {
  final _search = TextEditingController();
  late AdminShippingProfileList _page;
  late Option<AdminShippingProfile> _selected;
  Option<String> _failure = const None();
  Timer? _debounce;
  bool _loading = false;
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPage;
    _selected = widget.product.shippingProfile;
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
    final result = await context
        .readAdminProductDetailViewModel()
        .shippingProfileChoices(query: _search.text, offset: offset);
    if (!mounted || revision != _revision) return;
    switch (result) {
      case Some(value: final page):
        setState(() {
          _page = offset == 0
              ? page
              : AdminShippingProfileList(
                  shippingProfiles: [
                    ..._page.shippingProfiles,
                    ...page.shippingProfiles,
                  ],
                  count: page.count,
                  limit: page.limit,
                  offset: 0,
                );
          _failure = const None();
          _loading = false;
        });
      case None():
        setState(() {
          _failure = context.readAdminProductDetailViewModel().state.failure;
          _loading = false;
        });
    }
  }

  void _loadMore() => _load(_page.shippingProfiles.length);

  Future<void> _save() async {
    final id = switch (_selected) {
      Some(:final value) => value.id,
      None() => null,
    };
    final saved =
        await context.readAdminProductDetailViewModel().updateShippingProfile(
              widget.product.id,
              AdminUpdateProductShippingProfile(
                shippingProfileIdValue: id,
              ),
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

  void _select(Option<AdminShippingProfile> value) =>
      setState(() => _selected = value);
}
