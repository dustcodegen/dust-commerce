part of 'admin_product_media_editor.dart';

extension on _AdminProductMediaEditorState {
  Widget _editorBody(AdminProductDetailState state, bool busy) => LayoutBuilder(
        builder: (context, constraints) => constraints.maxWidth >= 820
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _gallery(busy)),
                  SizedBox(width: 560, child: _uploadPanel(state, busy)),
                ],
              )
            : ListView(
                children: [
                  SizedBox(height: 300, child: _gallery(busy)),
                  _uploadPanel(state, busy),
                ],
              ),
      );

  Widget _gallery(bool busy) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _media.isEmpty
              ? Center(
                  child: Text(
                    'No media',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) => GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth >= 640 ? 4 : 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                    ),
                    itemCount: _media.length,
                    itemBuilder: (context, index) => _mediaTile(index, busy),
                  ),
                ),
        ),
      );

  Widget _uploadPanel(AdminProductDetailState state, bool busy) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            left: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Media', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              'Add up to 10 images, reorder them, and choose a thumbnail.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: busy || _media.length == 10 ? null : _pickMedia,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                height: 132,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.isSaving)
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.file_upload_outlined, size: 19),
                    const SizedBox(height: 8),
                    Text(
                      state.isSaving ? 'Working…' : 'Upload images',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'JPEG, PNG, GIF, or WebP. 5 MB max.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
