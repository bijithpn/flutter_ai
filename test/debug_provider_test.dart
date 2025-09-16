import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'package:flutter_ai_mvp/services/services.dart';
import 'package:flutter_ai_mvp/providers/providers.dart';

import 'providers/recipe_provider_test.mocks.dart';

void main() {
  group('RecipeProvider Debug', () {
    late RecipeProvider recipeProvider;
    late MockAIServiceManager mockAIServiceManager;
    late HiveStorageRepository<Recipe> recipeRepository;

    setUp(() async {
      await setUpTestHive();

      // Register Recipe adapter for testing
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(RecipeAdapter());
      }

      mockAIServiceManager = MockAIServiceManager();
      recipeRepository = HiveStorageRepository<Recipe>('debug_test_recipes');

      recipeProvider = RecipeProvider(
        aiServiceManager: mockAIServiceManager,
        recipeRepository: recipeRepository,
      );
    });

    tearDown(() async {
      await tearDownTestHive();
    });

    test('debug recipe generation step by step', () async {
      try {
        // Arrange
        const ingredients = ['chicken', 'rice'];
        const mockRecipeJson = '''
        {
          "title": "Debug Recipe",
          "ingredients": ["chicken", "rice"],
          "steps": ["Step 1", "Step 2"],
          "cookingTime": 20,
          "difficulty": "Easy"
        }
        ''';

        print('Setting up mock...');
        when(mockAIServiceManager.generateRecipe(ingredients)).thenAnswer((
          _,
        ) async {
          print('Mock generateRecipe called with: $ingredients');
          return mockRecipeJson;
        });

        print('Initial state:');
        print('  isLoading: ${recipeProvider.isLoading}');
        print('  error: ${recipeProvider.error}');
        print('  recipes count: ${recipeProvider.recipes.length}');

        // Act
        print('Calling generateRecipes...');
        await recipeProvider.generateRecipes(ingredients);

        print('Final state:');
        print('  isLoading: ${recipeProvider.isLoading}');
        print('  error: ${recipeProvider.error}');
        print('  recipes count: ${recipeProvider.recipes.length}');

        if (recipeProvider.recipes.isNotEmpty) {
          final recipe = recipeProvider.recipes.first;
          print('  recipe title: ${recipe.title}');
          print('  recipe ingredients: ${recipe.ingredients}');
          print('  recipe steps: ${recipe.steps}');
        }

        // Assert
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, null);
        expect(recipeProvider.recipes.length, 1);

        if (recipeProvider.recipes.isNotEmpty) {
          expect(recipeProvider.recipes.first.title, 'Debug Recipe');
        }
      } catch (e, stackTrace) {
        print('Error in test: $e');
        print('Stack trace: $stackTrace');
        rethrow;
      }
    });
  });
}
