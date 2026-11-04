part of 'admin_product_edit_drawer.dart';

final class _AdminProductEditDrawerState
    extends State<_AdminProductEditDrawer> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _description;
  late bool _discountable;
  late final TextEditingController _handle;
  late final TextEditingController _material;
  late AdminProductLifecycle _status;
  late final TextEditingController _subtitle;
  late final TextEditingController _title;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _description = TextEditingController(text: product.description ?? '');
    _discountable = product.discountable;
    _handle = TextEditingController(text: product.handle);
    _material = TextEditingController(text: product.material ?? '');
    _status = product.status;
    _subtitle = TextEditingController(text: product.subtitle ?? '');
    _title = TextEditingController(text: product.title);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminProductDetailViewModel().clearFailure();
    });
  }

  @override
  void dispose() {
    _description.dispose();
    _handle.dispose();
    _material.dispose();
    _subtitle.dispose();
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductDetailViewModel().value;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 16,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width.clamp(0, 520).toDouble(),
        height: double.infinity,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AdminProductEditHeader(
                saving: state.isSaving,
                onClose: _close,
              ),
              Expanded(
                child: _AdminProductEditForm(
                  description: _description,
                  discountable: _discountable,
                  failure: state.failure,
                  formKey: _form,
                  handle: _handle,
                  material: _material,
                  onDiscountableChanged: _setDiscountable,
                  onStatusChanged: (value) => _status = value,
                  saving: state.isSaving,
                  status: _status,
                  subtitle: _subtitle,
                  title: _title,
                ),
              ),
              _AdminProductEditFooter(
                saving: state.isSaving,
                onCancel: _close,
                onSave: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _close() => Navigator.of(context).pop(false);

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final saved = await context.readAdminProductDetailViewModel().update(
          widget.product.id,
          AdminUpdateProduct(
            description: _description.text,
            discountable: _discountable,
            handle: _handle.text.trim(),
            material: _material.text,
            status: _status,
            subtitle: _subtitle.text,
            title: _title.text.trim(),
          ),
        );
    if (saved && mounted) Navigator.of(context).pop(true);
  }

  void _setDiscountable(bool value) => setState(() {
        _discountable = value;
      });
}
