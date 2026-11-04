part of 'admin_product_option_edit_drawer.dart';

extension on _OptionEditDrawerState {
  Widget _header(bool busy) => Container(
        height: 62,
        padding: const EdgeInsets.only(left: 24, right: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              'Edit Product Option',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'esc',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Close',
            onPressed: busy ? null : () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ]),
      );

  Widget _footer(bool busy) => Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: busy ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: busy ? null : _save,
              style: Theme.of(context).brightness == Brightness.dark
                  ? FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF52525B),
                      foregroundColor: Colors.white,
                    )
                  : null,
              child: busy
                  ? const SizedBox.square(
                      dimension: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      );
}
