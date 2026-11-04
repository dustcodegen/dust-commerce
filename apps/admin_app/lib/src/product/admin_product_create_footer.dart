part of 'admin_product_create_page.dart';

final class _CreateFooter extends StatelessWidget {
  const _CreateFooter({
    required this.step,
    required this.saving,
    required this.onCancel,
    required this.onDraft,
    required this.onPrimary,
  });

  final VoidCallback? onCancel;
  final VoidCallback? onDraft;
  final VoidCallback? onPrimary;
  final bool saving;
  final int step;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onDraft,
              child: const Text('Save as draft'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onPrimary,
              child: saving
                  ? const SizedBox.square(
                      dimension: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(step < 2 ? 'Continue' : 'Publish product'),
            ),
          ],
        ),
      );
}
