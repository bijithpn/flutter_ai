import 'package:flutter/material.dart';

/// A widget for inputting ingredients with multi-chip functionality
class IngredientInput extends StatefulWidget {
  final List<String> ingredients;
  final ValueChanged<List<String>> onIngredientsChanged;
  final String? hintText;
  final bool enabled;

  const IngredientInput({
    super.key,
    required this.ingredients,
    required this.onIngredientsChanged,
    this.hintText,
    this.enabled = true,
  });

  @override
  State<IngredientInput> createState() => _IngredientInputState();
}

class _IngredientInputState extends State<IngredientInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isNotEmpty && !widget.ingredients.contains(trimmed)) {
      final updatedIngredients = [...widget.ingredients, trimmed];
      widget.onIngredientsChanged(updatedIngredients);
      _controller.clear();
    }
  }

  void _removeIngredient(String ingredient) {
    final updatedIngredients = widget.ingredients
        .where((i) => i != ingredient)
        .toList();
    widget.onIngredientsChanged(updatedIngredients);
  }

  void _onSubmitted(String value) {
    _addIngredient(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input field
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Add an ingredient...',
            prefixIcon: const Icon(Icons.add),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _onSubmitted(_controller.text),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
          ),
          onSubmitted: _onSubmitted,
          onChanged: (value) {
            setState(() {}); // Rebuild to show/hide send button
          },
          textInputAction: TextInputAction.done,
        ),

        const SizedBox(height: 16),

        // Ingredient chips
        if (widget.ingredients.isNotEmpty) ...[
          Text(
            'Ingredients (${widget.ingredients.length})',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.ingredients.map((ingredient) {
              return IngredientChip(
                ingredient: ingredient,
                onDeleted: widget.enabled
                    ? () => _removeIngredient(ingredient)
                    : null,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Individual ingredient chip widget
class IngredientChip extends StatelessWidget {
  final String ingredient;
  final VoidCallback? onDeleted;

  const IngredientChip({super.key, required this.ingredient, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Chip(
      label: Text(
        ingredient,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      deleteIcon: onDeleted != null ? const Icon(Icons.close, size: 18) : null,
      onDeleted: onDeleted,
      backgroundColor: theme.colorScheme.secondaryContainer,
      labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer),
      deleteIconColor: theme.colorScheme.onSecondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
