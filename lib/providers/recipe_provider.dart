import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Provider for managing recipe generation and caching
class RecipeProvider extends ChangeNotifier {
  final AIServiceManager _aiServiceManager;
  final HiveStorageRepository<Recipe> _recipeRepository;

  List<Recipe> _recipes = [];
  List<Recipe> _cachedRecipes = [];
  bool _isLoading = false;
  String? _error;
  List<String> _currentIngredients = [];

  RecipeProvider({
    required AIServiceManager aiServiceManager,
    required HiveStorageRepository<Recipe> recipeRepository,
  }) : _aiServiceManager = aiServiceManager,
       _recipeRepository = recipeRepository {
    _loadCachedRecipes();
  }

  // Getters
  List<Recipe> get recipes => _recipes;
  List<Recipe> get cachedRecipes => _cachedRecipes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get currentIngredients => _currentIngredients;
  bool get hasRecipes => _recipes.isNotEmpty;

  /// Generate recipes based on ingredients
  Future<void> generateRecipes(List<String> ingredients) async {
    if (ingredients.isEmpty) {
      _setError('Please add at least one ingredient');
      return;
    }

    _setLoading(true);
    _clearError();
    _currentIngredients = List.from(ingredients);

    try {
      // Check if we have cached recipes for these ingredients
      final cachedRecipe = await _getCachedRecipe(ingredients);
      if (cachedRecipe != null) {
        _recipes = [cachedRecipe];
        _setLoading(false);
        return;
      }

      // Generate new recipe using AI service
      final recipeJson = await _aiServiceManager.generateRecipe(ingredients);
      final recipe = await _parseAndSaveRecipe(recipeJson, ingredients);

      _recipes = [recipe];
      await _cacheRecipe(recipe, ingredients);
    } catch (e, stackTrace) {
      debugPrint('Error in generateRecipes: $e');
      debugPrint('Stack trace: $stackTrace');
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Parse recipe JSON and create Recipe object
  Future<Recipe> _parseAndSaveRecipe(
    String recipeJson,
    List<String> ingredients,
  ) async {
    try {
      final Map<String, dynamic> parsedJson = jsonDecode(recipeJson);

      final recipe = Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: parsedJson['title'] ?? 'Generated Recipe',
        ingredients: List<String>.from(
          parsedJson['ingredients'] ?? ingredients,
        ),
        steps: List<String>.from(parsedJson['steps'] ?? []),
        imageUrl: _getPlaceholderImageUrl(parsedJson['title'] ?? 'recipe'),
        cookingTime: parsedJson['cookingTime'] ?? 30,
        difficulty: parsedJson['difficulty'] ?? 'Medium',
        createdAt: DateTime.now(),
      );

      // Save to local storage
      await _recipeRepository.save(recipe.id, recipe);

      // Reload cached recipes to include the new recipe
      await _loadCachedRecipes();

      return recipe;
    } catch (e) {
      throw Exception('Failed to parse recipe data: $e');
    }
  }

  /// Get placeholder image URL for recipe
  String _getPlaceholderImageUrl(String recipeName) {
    // Generate a consistent placeholder image based on recipe name
    final hash = recipeName.hashCode.abs();
    final imageId = (hash % 1000) + 1; // Use numbers 1-1000
    return 'https://picsum.photos/400/300?random=$imageId';
  }

  /// Cache recipe with ingredients as key
  Future<void> _cacheRecipe(Recipe recipe, List<String> ingredients) async {
    final cacheKey = _generateCacheKey(ingredients);
    // Create a copy of the recipe for caching to avoid Hive key conflicts
    final cachedRecipe = Recipe(
      id: 'cache_${recipe.id}',
      title: recipe.title,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      imageUrl: recipe.imageUrl,
      cookingTime: recipe.cookingTime,
      difficulty: recipe.difficulty,
      createdAt: recipe.createdAt,
    );
    await _recipeRepository.save('cache_$cacheKey', cachedRecipe);
  }

  /// Get cached recipe for ingredients
  Future<Recipe?> _getCachedRecipe(List<String> ingredients) async {
    final cacheKey = _generateCacheKey(ingredients);
    return await _recipeRepository.load('cache_$cacheKey');
  }

  /// Generate cache key from ingredients
  String _generateCacheKey(List<String> ingredients) {
    final sortedIngredients =
        ingredients.map((e) => e.toLowerCase().trim()).toList()..sort();
    return sortedIngredients.join('_').replaceAll(RegExp(r'[^a-z0-9_]'), '');
  }

  /// Load all cached recipes
  Future<void> _loadCachedRecipes() async {
    try {
      final allKeys = await _recipeRepository.getAllKeys();
      final regularRecipeKeys = allKeys.where(
        (key) => !key.startsWith('cache_'),
      );

      _cachedRecipes = [];
      for (final key in regularRecipeKeys) {
        final recipe = await _recipeRepository.load(key);
        if (recipe != null) {
          _cachedRecipes.add(recipe);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load cached recipes: $e');
    }
  }

  /// Get recipe by ID
  Future<Recipe?> getRecipeById(String id) async {
    try {
      return await _recipeRepository.load(id);
    } catch (e) {
      debugPrint('Failed to load recipe $id: $e');
      return null;
    }
  }

  /// Delete recipe
  Future<void> deleteRecipe(String id) async {
    try {
      await _recipeRepository.delete(id);
      _cachedRecipes.removeWhere((recipe) => recipe.id == id);
      _recipes.removeWhere((recipe) => recipe.id == id);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete recipe: $e');
    }
  }

  /// Clear all recipes
  void clearRecipes() {
    _recipes.clear();
    _currentIngredients.clear();
    _clearError();
    notifyListeners();
  }

  /// Clear cached recipes
  Future<void> clearCachedRecipes() async {
    try {
      await _recipeRepository.clear();
      _cachedRecipes.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear cached recipes: $e');
    }
  }

  /// Reload cached recipes from storage
  Future<void> reloadCachedRecipes() async {
    await _loadCachedRecipes();
  }

  /// Refresh recipes with current ingredients
  Future<void> refreshRecipes() async {
    if (_currentIngredients.isNotEmpty) {
      // Clear cache for current ingredients to force fresh generation
      final cacheKey = _generateCacheKey(_currentIngredients);
      await _recipeRepository.delete('cache_$cacheKey');

      await generateRecipes(_currentIngredients);
    }
  }

  /// Search cached recipes
  List<Recipe> searchCachedRecipes(String query) {
    if (query.isEmpty) return _cachedRecipes;

    final lowercaseQuery = query.toLowerCase();
    return _cachedRecipes.where((recipe) {
      return recipe.title.toLowerCase().contains(lowercaseQuery) ||
          recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(lowercaseQuery),
          ) ||
          recipe.difficulty.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get recipes by difficulty
  List<Recipe> getRecipesByDifficulty(String difficulty) {
    return _cachedRecipes
        .where(
          (recipe) =>
              recipe.difficulty.toLowerCase() == difficulty.toLowerCase(),
        )
        .toList();
  }

  /// Get recipes by cooking time range
  List<Recipe> getRecipesByCookingTime(int minTime, int maxTime) {
    return _cachedRecipes
        .where(
          (recipe) =>
              recipe.cookingTime >= minTime && recipe.cookingTime <= maxTime,
        )
        .toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is AIServiceException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  @override
  void dispose() {
    _recipeRepository.close();
    super.dispose();
  }
}
