part of 'admin_product_edit_drawer.dart';

final class _AdminProductEditForm extends StatelessWidget {
  const _AdminProductEditForm({
    required this.description,
    required this.discountable,
    required this.failure,
    required this.formKey,
    required this.handle,
    required this.material,
    required this.onDiscountableChanged,
    required this.onStatusChanged,
    required this.saving,
    required this.status,
    required this.subtitle,
    required this.title,
  });

  final TextEditingController description;
  final bool discountable;
  final Option<String> failure;
  final GlobalKey<FormState> formKey;
  final TextEditingController handle;
  final TextEditingController material;
  final ValueChanged<bool> onDiscountableChanged;
  final ValueChanged<AdminProductLifecycle> onStatusChanged;
  final bool saving;
  final AdminProductLifecycle status;
  final TextEditingController subtitle;
  final TextEditingController title;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            const _AdminProductEditLabel(text: 'Status'),
            const SizedBox(height: 7),
            DropdownButtonFormField<AdminProductLifecycle>(
              initialValue: status,
              items: [
                for (final value in AdminProductLifecycle.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(_productEditTitleCase(value.name)),
                  ),
              ],
              onChanged: saving
                  ? null
                  : (value) {
                      if (value != null) onStatusChanged(value);
                    },
            ),
            const SizedBox(height: 18),
            _AdminProductEditField(
              controller: title,
              enabled: !saving,
              label: 'Title',
              validator: _validateProductTitle,
            ),
            const SizedBox(height: 18),
            _AdminProductEditField(
              controller: subtitle,
              enabled: !saving,
              label: 'Subtitle',
              optional: true,
              validator: _validateProductShortText,
            ),
            const SizedBox(height: 18),
            _AdminProductEditField(
              controller: handle,
              enabled: !saving,
              label: 'Handle',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 10, right: 2),
                child: Text('/'),
              ),
              validator: _validateProductHandle,
            ),
            const SizedBox(height: 18),
            _AdminProductEditField(
              controller: material,
              enabled: !saving,
              label: 'Material',
              optional: true,
              validator: _validateProductShortText,
            ),
            const SizedBox(height: 18),
            _AdminProductEditField(
              controller: description,
              enabled: !saving,
              label: 'Description',
              maxLines: 6,
              optional: true,
              validator: _validateProductDescription,
            ),
            const SizedBox(height: 24),
            _AdminProductDiscountableBox(
              onChanged: saving ? null : onDiscountableChanged,
              value: discountable,
            ),
            if (failure case Some(value: final message)) ...[
              const SizedBox(height: 18),
              _AdminProductEditFailure(message: message),
            ],
          ],
        ),
      );
}
