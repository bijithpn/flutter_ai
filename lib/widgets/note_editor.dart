import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A rich text input widget for note editing with Material 3 styling
class NoteEditor extends StatefulWidget {
  final String? initialText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool enabled;
  final bool autofocus;
  final TextEditingController? controller;

  const NoteEditor({
    super.key,
    this.initialText,
    this.hintText,
    this.maxLines,
    this.minLines = 5,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.autofocus = false,
    this.controller,
  });

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _controller;
  int _characterCount = 0;
  static const int _maxCharacters = 10000;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialText);
    _characterCount = _controller.text.length;
    _controller.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_updateCharacterCount);
    }
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _controller.text.length;
    });
    widget.onChanged?.call(_controller.text);
  }

  void _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      final currentText = _controller.text;
      final selection = _controller.selection;
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        clipboardData!.text!,
      );

      if (newText.length <= _maxCharacters) {
        _controller.text = newText;
        _controller.selection = TextSelection.collapsed(
          offset: selection.start + clipboardData.text!.length,
        );
      } else {
        _showCharacterLimitSnackBar();
      }
    }
  }

  void _showCharacterLimitSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Character limit of $_maxCharacters exceeded'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Editor header with actions
        Row(
          children: [
            Icon(Icons.edit_note, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Note Editor',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: widget.enabled ? _pasteFromClipboard : null,
              icon: const Icon(Icons.content_paste),
              tooltip: 'Paste from clipboard',
              iconSize: 20,
            ),
            IconButton(
              onPressed: widget.enabled && _controller.text.isNotEmpty
                  ? () => _controller.clear()
                  : null,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear text',
              iconSize: 20,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Text input field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: _maxCharacters,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText:
                  widget.hintText ?? 'Enter your text here to summarize...',
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.all(20),
              counterText: '', // Hide default counter
            ),
            onSubmitted: (_) => widget.onSubmitted?.call(),
          ),
        ),

        // Character count and word count
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Words: ${_getWordCount(_controller.text)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '$_characterCount / $_maxCharacters',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _characterCount > _maxCharacters * 0.9
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _getWordCount(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}
