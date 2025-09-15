import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/error_widgets.dart' as error_widgets;

class RecipeDetailScreen extends StatelessWidget {
  final Recipe? recipe;
  final String? recipeId;

  const RecipeDetailScreen({super.key, this.recipe, this.recipeId})
    : assert(
        recipe != null || recipeId != null,
        'Either recipe or recipeId must be provided',
      );

  @override
  Widget build(BuildContext context) {
    // For now, if only recipeId is provided, show a placeholder
    // In task 7.2, this will be connected to the recipe provider
    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recipe Details'),
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        body: const Center(
          child: error_widgets.ErrorWidget(
            title: 'Recipe Not Found',
            message: 'This recipe could not be loaded. Please try again.',
            icon: Icons.restaurant_outlined,
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with recipe image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe!.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: _buildRecipeImage(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Implement sharing functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing coming soon!')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Implement favorites functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorites coming soon!')),
                  );
                },
              ),
            ],
          ),

          // Recipe content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe metadata
                  _buildRecipeMetadata(context),

                  const SizedBox(height: 24),

                  // Ingredients section
                  _buildIngredientsSection(context),

                  const SizedBox(height: 24),

                  // Instructions section
                  _buildInstructionsSection(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage(BuildContext context) {
    final theme = Theme.of(context);

    if (recipe!.imageUrl != null) {
      return Image.network(
        recipe!.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder(theme);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImagePlaceholder(theme, isLoading: true);
        },
      );
    }

    return _buildImagePlaceholder(theme);
  }

  Widget _buildImagePlaceholder(ThemeData theme, {bool isLoading = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: isLoading
            ? CircularProgressIndicator(
                color: theme.colorScheme.onPrimaryContainer,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recipe Image',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRecipeMetadata(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetadataCard(
            context,
            Icons.access_time,
            'Cooking Time',
            '${recipe!.cookingTime} minutes',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetadataCard(
            context,
            Icons.signal_cellular_alt,
            'Difficulty',
            recipe!.difficulty,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetadataCard(
            context,
            Icons.restaurant,
            'Ingredients',
            '${recipe!.ingredients.length} items',
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...recipe!.ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(ingredient, style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...recipe!.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      step,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
