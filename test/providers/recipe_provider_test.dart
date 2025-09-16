import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'package:flutter_ai_mvp/services/services.dart';
import 'package:flutter_ai_mvp/providers/providers.dart';

import 'recipe_provider_test.mocks.dart';

@GenerateMocks([AIServiceManager])
void main() {
  group('RecipeProvider Tests', () {
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
      recipeRepository = HiveStorageRepository<Recipe>('test_recipes');

      recipeProvider = RecipeProvider(
        aiServiceManager: mockAIServiceManager,
        recipeRepository: recipeRepository,
      );
    });

    tearDown(() async {
      await tearDownTestHive();
    });

    group('Recipe Generation', () {
      test('should generate recipe successfully', () async {
        // Arrange
        const ingredients = ['chicken', 'rice', 'vegetables'];
        const mockRecipeJson = '''
        {
          "title": "Chicken Rice Bowl",
          "ingredients": ["chicken", "rice", "vegetables", "soy sauce"],
          "steps": ["Cook rice", "Prepare chicken", "Mix vegetables", "Combine all"],
          "cookingTime": 25,
          "difficulty": "Easy"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => mockRecipeJson);

        // Act
        await recipeProvider.generateRecipes(ingredients);

        // Assert
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, null);
        expect(recipeProvider.recipes.length, 1);
        expect(recipeProvider.recipes.first.title, 'Chicken Rice Bowl');
        expect(recipeProvider.recipes.first.cookingTime, 25);
        expect(recipeProvider.recipes.first.difficulty, 'Easy');
        expect(recipeProvider.currentIngredients, ingredients);
      });

      test('should handle empty ingredients list', () async {
        // Act
        await recipeProvider.generateRecipes([]);

        // Assert
        expect(recipeProvider.error, 'Please add at least one ingredient');
        expect(recipeProvider.recipes.isEmpty, true);
        verifyNever(mockAIServiceManager.generateRecipe(any));
      });

      test('should handle AI service errors', () async {
        // Arrange
        const ingredients = ['chicken', 'rice'];
        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenThrow(const AIServiceException('API error'));

        // Act
        await recipeProvider.generateRecipes(ingredients);

        // Assert
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, 'API error');
        expect(recipeProvider.recipes.isEmpty, true);
      });

      test('should use cached recipe when available', () async {
        // Arrange
        const ingredients = ['chicken', 'rice'];
        const mockRecipeJson = '''
        {
          "title": "Cached Recipe",
          "ingredients": ["chicken", "rice"],
          "steps": ["Step 1", "Step 2"],
          "cookingTime": 20,
          "difficulty": "Easy"
        }
        ''';

        // First call to generate and cache
        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => mockRecipeJson);

        await recipeProvider.generateRecipes(ingredients);

        // Clear recipes to test caching
        recipeProvider.clearRecipes();

        // Act - Second call should use cache
        await recipeProvider.generateRecipes(ingredients);

        // Assert - Should only call AI service once (first time)
        verify(mockAIServiceManager.generateRecipe(ingredients)).called(1);
        expect(recipeProvider.recipes.length, 1);
        expect(recipeProvider.recipes.first.title, 'Cached Recipe');
      });

      test('should handle malformed JSON response', () async {
        // Arrange
        const ingredients = ['chicken'];
        const malformedJson = 'invalid json';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => malformedJson);

        // Act
        await recipeProvider.generateRecipes(ingredients);

        // Assert
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, isNotNull);
        expect(recipeProvider.recipes.isEmpty, true);
      });
    });

    group('Recipe Management', () {
      test('should delete recipe successfully', () async {
        // Arrange - First create a recipe
        const ingredients = ['test'];
        const mockRecipeJson = '''
        {
          "title": "Test Recipe",
          "ingredients": ["test"],
          "steps": ["Step 1"],
          "cookingTime": 10,
          "difficulty": "Easy"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => mockRecipeJson);

        await recipeProvider.generateRecipes(ingredients);
        final recipeId = recipeProvider.recipes.first.id;

        // Act
        await recipeProvider.deleteRecipe(recipeId);

        // Assert
        expect(recipeProvider.recipes.isEmpty, true);
        expect(recipeProvider.cachedRecipes.isEmpty, true);
      });

      test('should search cached recipes', () async {
        // Arrange - Create multiple recipes
        final recipe1 = Recipe(
          id: '1',
          title: 'Chicken Curry',
          ingredients: ['chicken', 'curry'],
          steps: ['Step 1'],
          cookingTime: 30,
          difficulty: 'Medium',
          createdAt: DateTime.now(),
        );

        final recipe2 = Recipe(
          id: '2',
          title: 'Beef Stew',
          ingredients: ['beef', 'vegetables'],
          steps: ['Step 1'],
          cookingTime: 45,
          difficulty: 'Hard',
          createdAt: DateTime.now(),
        );

        await recipeRepository.save('1', recipe1);
        await recipeRepository.save('2', recipe2);

        // Reload cached recipes
        await recipeProvider.reloadCachedRecipes();

        // Act
        final searchResults = recipeProvider.searchCachedRecipes('chicken');

        // Assert
        expect(searchResults.length, 1);
        expect(searchResults.first.title, 'Chicken Curry');
      });

      test('should filter recipes by difficulty', () async {
        // Arrange - Create recipes with different difficulties
        final easyRecipe = Recipe(
          id: '1',
          title: 'Easy Recipe',
          ingredients: ['ingredient'],
          steps: ['Step 1'],
          cookingTime: 15,
          difficulty: 'Easy',
          createdAt: DateTime.now(),
        );

        final hardRecipe = Recipe(
          id: '2',
          title: 'Hard Recipe',
          ingredients: ['ingredient'],
          steps: ['Step 1'],
          cookingTime: 60,
          difficulty: 'Hard',
          createdAt: DateTime.now(),
        );

        await recipeRepository.save('1', easyRecipe);
        await recipeRepository.save('2', hardRecipe);

        // Reload cached recipes
        await recipeProvider.reloadCachedRecipes();

        // Act
        final easyRecipes = recipeProvider.getRecipesByDifficulty('Easy');

        // Assert
        expect(easyRecipes.length, 1);
        expect(easyRecipes.first.difficulty, 'Easy');
      });

      test('should filter recipes by cooking time', () async {
        // Arrange - Create recipes with different cooking times
        final quickRecipe = Recipe(
          id: '1',
          title: 'Quick Recipe',
          ingredients: ['ingredient'],
          steps: ['Step 1'],
          cookingTime: 15,
          difficulty: 'Easy',
          createdAt: DateTime.now(),
        );

        final slowRecipe = Recipe(
          id: '2',
          title: 'Slow Recipe',
          ingredients: ['ingredient'],
          steps: ['Step 1'],
          cookingTime: 120,
          difficulty: 'Hard',
          createdAt: DateTime.now(),
        );

        await recipeRepository.save('1', quickRecipe);
        await recipeRepository.save('2', slowRecipe);

        // Reload cached recipes
        await recipeProvider.reloadCachedRecipes();

        // Act
        final quickRecipes = recipeProvider.getRecipesByCookingTime(10, 30);

        // Assert
        expect(quickRecipes.length, 1);
        expect(quickRecipes.first.cookingTime, 15);
      });

      test('should refresh recipes with current ingredients', () async {
        // Arrange
        const ingredients = ['chicken'];
        const mockRecipeJson = '''
        {
          "title": "Refreshed Recipe",
          "ingredients": ["chicken"],
          "steps": ["Step 1"],
          "cookingTime": 25,
          "difficulty": "Medium"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => mockRecipeJson);

        await recipeProvider.generateRecipes(ingredients);

        // Act
        await recipeProvider.refreshRecipes();

        // Assert
        verify(mockAIServiceManager.generateRecipe(ingredients)).called(2);
        expect(recipeProvider.recipes.first.title, 'Refreshed Recipe');
      });
    });

    group('Image Placeholder Handling', () {
      test('should generate consistent placeholder URLs', () async {
        // Arrange
        const ingredients = ['test'];
        const mockRecipeJson = '''
        {
          "title": "Test Recipe",
          "ingredients": ["test"],
          "steps": ["Step 1"],
          "cookingTime": 10,
          "difficulty": "Easy"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => mockRecipeJson);

        // Act
        await recipeProvider.generateRecipes(ingredients);

        // Assert
        final recipe = recipeProvider.recipes.first;
        expect(recipe.imageUrl, isNotNull);
        expect(
          recipe.imageUrl,
          startsWith('https://picsum.photos/400/300?random='),
        );
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // Arrange
        const ingredients = ['chicken'];
        when(mockAIServiceManager.generateRecipe(ingredients)).thenThrow(
          const AIServiceException(
            'Network connection failed',
            isRetryable: true,
          ),
        );

        // Act
        await recipeProvider.generateRecipes(ingredients);

        // Assert
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, 'Network connection failed');
        expect(recipeProvider.recipes.isEmpty, true);
      });

      test('should clear error when generating new recipes', () async {
        // Arrange - First create an error
        const ingredients = ['chicken'];
        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenThrow(const AIServiceException('First error'));

        await recipeProvider.generateRecipes(ingredients);
        expect(recipeProvider.error, 'First error');

        // Act - Generate successful recipe
        const mockRecipeJson = '''
        {
          "title": "Success Recipe",
          "ingredients": ["chicken"],
          "steps": ["Step 1"],
          "cookingTime": 20,
          "difficulty": "Easy"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => mockRecipeJson);

        await recipeProvider.generateRecipes(ingredients);

        // Assert
        expect(recipeProvider.error, null);
        expect(recipeProvider.recipes.length, 1);
      });
    });
  });
}
