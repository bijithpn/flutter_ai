import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/widgets.dart';
import '../navigation/app_router.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<String> _ingredients = [];
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recipe Generator'),
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        loadingText: 'Generating recipes...',
        child: _buildBody(),
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: _showRecipeInputBottomSheet,
        icon: Icons.add,
        isExtended: true,
        label: 'New Recipe',
        tooltip: 'Generate new recipe',
      ),
    );
  }

  Widget _buildBody() {
    if (_recipes.isEmpty && _ingredients.isEmpty && _errorMessage == null) {
      return const EmptyRecipesWidget();
    }

    return CustomScrollView(
      slivers: [
        // Ingredient input section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_ingredients.isNotEmpty) ...[
                  Text(
                    'Current Ingredients',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  IngredientInput(
                    ingredients: _ingredients,
                    onIngredientsChanged: _onIngredientsChanged,
                    hintText: 'Add more ingredients...',
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomElevatedButton(
                          text: 'Generate Recipes',
                          icon: Icons.auto_awesome,
                          onPressed: _ingredients.isNotEmpty && !_isLoading
                              ? _generateRecipes
                              : null,
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomOutlinedButton(
                        text: 'Clear',
                        icon: Icons.clear,
                        onPressed: _ingredients.isNotEmpty && !_isLoading
                            ? _clearIngredients
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Error message
                if (_errorMessage != null) ...[
                  InlineErrorWidget(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),

        // Recipes section
        if (_recipes.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Generated Recipes (${_recipes.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final recipe = _recipes[index];
              return RecipeCard(
                recipe: recipe,
                onTap: () => _navigateToRecipeDetail(recipe),
              );
            }, childCount: _recipes.length),
          ),
        ] else if (_isLoading) ...[
          // Loading shimmer
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const RecipeCardShimmer(),
              childCount: 3,
            ),
          ),
        ],

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _onIngredientsChanged(List<String> ingredients) {
    setState(() {
      _ingredients = ingredients;
      _errorMessage = null;
    });
  }

  void _generateRecipes() {
    if (_ingredients.isEmpty) {
      setState(() {
        _errorMessage =
            'Please add at least one ingredient to generate recipes.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // TODO: This will be implemented in task 7.2 with actual AI service
    // For now, simulate loading and show placeholder recipes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _recipes = _generateMockRecipes();
        });
      }
    });
  }

  void _clearIngredients() {
    setState(() {
      _ingredients.clear();
      _recipes.clear();
      _errorMessage = null;
    });
  }

  void _showRecipeInputBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecipeInputBottomSheet(
        initialIngredients: _ingredients,
        onIngredientsSubmitted: (ingredients) {
          setState(() {
            _ingredients = ingredients;
          });
          if (ingredients.isNotEmpty) {
            _generateRecipes();
          }
        },
      ),
    );
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    Navigator.of(
      context,
    ).pushNamed(AppRouter.recipeDetail, arguments: {'recipe': recipe});
  }

  // Mock recipe generation for UI testing
  List<Recipe> _generateMockRecipes() {
    return [
      Recipe(
        id: '1',
        title: 'Delicious ${_ingredients.first} Stir Fry',
        ingredients: [
          ..._ingredients,
          'Soy sauce',
          'Garlic',
          'Ginger',
          'Vegetable oil',
        ],
        steps: [
          'Heat oil in a large pan or wok over medium-high heat.',
          'Add garlic and ginger, stir-fry for 30 seconds until fragrant.',
          'Add ${_ingredients.join(', ')} and cook for 3-4 minutes.',
          'Add soy sauce and stir to combine.',
          'Cook for another 2-3 minutes until everything is heated through.',
          'Serve hot over rice or noodles.',
        ],
        cookingTime: 15,
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: '2',
        title: '${_ingredients.first} Soup',
        ingredients: [
          ..._ingredients,
          'Vegetable broth',
          'Onion',
          'Salt and pepper',
          'Herbs',
        ],
        steps: [
          'Chop all vegetables into bite-sized pieces.',
          'Heat a large pot over medium heat.',
          'Add onion and cook until softened.',
          'Add ${_ingredients.join(', ')} and cook for 5 minutes.',
          'Pour in vegetable broth and bring to a boil.',
          'Reduce heat and simmer for 20 minutes.',
          'Season with salt, pepper, and herbs to taste.',
        ],
        cookingTime: 30,
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      ),
    ];
  }
}

class _RecipeInputBottomSheet extends StatefulWidget {
  final List<String> initialIngredients;
  final ValueChanged<List<String>> onIngredientsSubmitted;

  const _RecipeInputBottomSheet({
    required this.initialIngredients,
    required this.onIngredientsSubmitted,
  });

  @override
  State<_RecipeInputBottomSheet> createState() =>
      _RecipeInputBottomSheetState();
}

class _RecipeInputBottomSheetState extends State<_RecipeInputBottomSheet> {
  late List<String> _ingredients;

  @override
  void initState() {
    super.initState();
    _ingredients = List.from(widget.initialIngredients);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: mediaQuery.viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            'Add Ingredients',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Ingredient input
          IngredientInput(
            ingredients: _ingredients,
            onIngredientsChanged: (ingredients) {
              setState(() {
                _ingredients = ingredients;
              });
            },
            hintText: 'Enter an ingredient...',
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: CustomOutlinedButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomElevatedButton(
                  text: 'Generate Recipes',
                  icon: Icons.auto_awesome,
                  onPressed: _ingredients.isNotEmpty
                      ? () {
                          widget.onIngredientsSubmitted(_ingredients);
                          Navigator.of(context).pop();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
