part of 'admin_product_option_edit_drawer.dart';

extension on _OptionEditDrawerState {
  List<Widget> _fields(AdminProductOptionDetailState state, bool busy) => [
        Text('Title', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          controller: _title,
          enabled: !busy,
          decoration: const InputDecoration(hintText: 'Size'),
          validator: (value) {
            final title = value?.trim() ?? '';
            if (title.isEmpty) return 'Title is required';
            if (title.length > 255) return 'Use at most 255 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text('Values', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        _valueInput(busy),
        if (_valueError case final error?) ...[
          const SizedBox(height: 6),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
        if (_values.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Rank', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          _rankList(busy),
        ],
        if (state.failure case Some(value: final message)) ...[
          const SizedBox(height: 16),
          _failure(message),
        ],
      ];

  Widget _valueInput(bool busy) => Container(
        constraints: const BoxConstraints(minHeight: 34),
        padding: const EdgeInsets.fromLTRB(6, 3, 4, 3),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final value in _values)
              Chip(
                label: Text(value),
                onDeleted: busy ? null : () => _removeValue(value),
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF414145)
                    : const Color(0xFFE4E4E7),
                deleteIcon: const Icon(Icons.close_rounded, size: 14),
                labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.zero,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            SizedBox(
              width: 118,
              child: TextField(
                controller: _pending,
                enabled: !busy,
                decoration: InputDecoration(
                  hintText: _values.isEmpty ? 'S, M, L' : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                ),
                onSubmitted: (_) => _addValue(),
              ),
            ),
          ],
        ),
      );

  Widget _rankList(bool busy) => ReorderableListView.builder(
        buildDefaultDragHandles: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _values.length,
        onReorderItem: busy ? (_, __) {} : _reorder,
        itemBuilder: (context, index) => Container(
          key: ValueKey(_values[index]),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: index == _values.length - 1
              ? null
              : BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
          child: Row(children: [
            ReorderableDragStartListener(
              enabled: !busy,
              index: index,
              child: const Icon(Icons.drag_indicator_rounded, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_values[index])),
          ]),
        ),
      );

  Widget _failure(String message) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(message),
      );
}
