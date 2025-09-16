import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'package:flutter_ai_mvp/services/services.dart';
import 'package:flutter_ai_mvp/providers/providers.dart';

import '../providers/recipe_provider_test.mocks.dart';

@GenerateMocks([AIServiceManager])
void main() {
  group('Recipe Generation Integration Tests', () {
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
      recipeRepository = HiveStorageRepository<Recipe>(
        'integration_test_recipes',
      );

      recipeProvider = RecipeProvider(
        aiServiceManager: mockAIServiceManager,
        recipeRepository: recipeRepository,
      );
    });

    tearDown(() async {
      await tearDownTestHive();
    });

    group('End-to-End Recipe Generation Workflow', () {
      testWidgets('Complete recipe generation workflow', (
        WidgetTester tester,
      ) async {
        // Arrange
        const ingredients = ['chicken', 'broccoli', 'rice'];
        const mockRecipeJson = '''
        {
          "title": "Chicken Broccoli Rice Bowl",
          "ingredients": ["1 lb chicken breast", "2 cups broccoli florets", "1 cup jasmine rice", "2 tbsp soy sauce", "1 tbsp olive oil"],
          "steps": [
            "Cook rice according to package instructions",
            "Heat olive oil in a large pan over medium-high heat",
            "Season chicken with salt and pepper, cook for 6-7 minutes per side",
            "Steam broccoli for 4-5 minutes until tender-crisp",
            "Slice chicken and serve over rice with broccoli",
            "Drizzle with soy sauce before serving"
          ],
          "cookingTime": 25,
          "difficulty": "Easy"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => mockRecipeJson);

        // Act - Simulate complete user workflow
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.recipes.isEmpty, true);

        // Step 1: User enters ingredients and generates recipe
        final generateFuture = recipeProvider.generateRecipes(ingredients);

        // Verify loading state
        expect(recipeProvider.isLoading, true);
        expect(recipeProvider.error, null);

        await generateFuture;

        // Step 2: Verify recipe generation completed successfully
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, null);
        expect(recipeProvider.recipes.length, 1);

        final generatedRecipe = recipeProvider.recipes.first;
        expect(generatedRecipe.title, 'Chicken Broccoli Rice Bowl');
        expect(generatedRecipe.ingredients.length, 5);
        expect(generatedRecipe.steps.length, 6);
        expect(generatedRecipe.cookingTime, 25);
        expect(generatedRecipe.difficulty, 'Easy');
        expect(generatedRecipe.imageUrl, isNotNull);
        expect(
          generatedRecipe.imageUrl,
          startsWith('https://picsum.photos/400/300?random='),
        );

        // Step 3: Verify recipe is cached locally
        final cachedRecipe = await recipeProvider.getRecipeById(
          generatedRecipe.id,
        );
        expect(cachedRecipe, isNotNull);
        expect(cachedRecipe!.title, generatedRecipe.title);

        // Step 4: Test cache retrieval (second generation with same ingredients)
        recipeProvider.clearRecipes();
        await recipeProvider.generateRecipes(ingredients);

        // Should use cached version, not call AI service again
        verify(mockAIServiceManager.generateRecipe(ingredients)).called(1);
        expect(recipeProvider.recipes.length, 1);
        expect(
          recipeProvider.recipes.first.title,
          'Chicken Broccoli Rice Bowl',
        );
      });

      testWidgets('Recipe generation with error recovery', (
        WidgetTester tester,
      ) async {
        // Arrange
        const ingredients = ['pasta', 'tomatoes'];

        // First attempt fails
        when(mockAIServiceManager.generateRecipe(ingredients)).thenThrow(
          const AIServiceException('Rate limit exceeded', isRetryable: true),
        );

        // Act - First attempt (should fail)
        await recipeProvider.generateRecipes(ingredients);

        // Assert - Error state
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, 'Rate limit exceeded');
        expect(recipeProvider.recipes.isEmpty, true);

        // Arrange - Second attempt succeeds
        const mockRecipeJson = '''
        {
          "title": "Pasta with Tomatoes",
          "ingredients": ["pasta", "tomatoes", "garlic", "olive oil"],
          "steps": ["Boil pasta", "Sauté tomatoes", "Combine and serve"],
          "cookingTime": 20,
          "difficulty": "Easy"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => mockRecipeJson);

        // Act - Retry (should succeed)
        await recipeProvider.generateRecipes(ingredients);

        // Assert - Success state
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, null);
        expect(recipeProvider.recipes.length, 1);
        expect(recipeProvider.recipes.first.title, 'Pasta with Tomatoes');
      });

      testWidgets('Multiple recipe generation and management', (
        WidgetTester tester,
      ) async {
        // Arrange - Generate multiple recipes
        const ingredients1 = ['beef', 'potatoes'];
        const ingredients2 = ['fish', 'vegetables'];

        const mockRecipeJson1 = '''
        {
          "title": "Beef and Potato Stew",
          "ingredients": ["beef", "potatoes", "onions"],
          "steps": ["Brown beef", "Add potatoes", "Simmer"],
          "cookingTime": 60,
          "difficulty": "Medium"
        }
        ''';

        const mockRecipeJson2 = '''
        {
          "title": "Grilled Fish with Vegetables",
          "ingredients": ["fish", "vegetables", "lemon"],
          "steps": ["Season fish", "Grill fish", "Steam vegetables"],
          "cookingTime": 30,
          "difficulty": "Easy"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients1),
        ).thenAnswer((_) async => mockRecipeJson1);
        when(
          mockAIServiceManager.generateRecipe(ingredients2),
        ).thenAnswer((_) async => mockRecipeJson2);

        // Act - Generate first recipe
        await recipeProvider.generateRecipes(ingredients1);
        final recipe1Id = recipeProvider.recipes.first.id;

        // Generate second recipe
        await recipeProvider.generateRecipes(ingredients2);
        final recipe2Id = recipeProvider.recipes.first.id;

        // Assert - Both recipes exist in storage
        final storedRecipe1 = await recipeProvider.getRecipeById(recipe1Id);
        final storedRecipe2 = await recipeProvider.getRecipeById(recipe2Id);

        expect(storedRecipe1, isNotNull);
        expect(storedRecipe2, isNotNull);
        expect(storedRecipe1!.title, 'Beef and Potato Stew');
        expect(storedRecipe2!.title, 'Grilled Fish with Vegetables');

        // Test search functionality
        final searchResults = recipeProvider.searchCachedRecipes('beef');
        expect(searchResults.length, 1);
        expect(searchResults.first.title, 'Beef and Potato Stew');

        // Test filtering by difficulty
        final easyRecipes = recipeProvider.getRecipesByDifficulty('Easy');
        expect(easyRecipes.length, 1);
        expect(easyRecipes.first.title, 'Grilled Fish with Vegetables');

        // Test filtering by cooking time
        final quickRecipes = recipeProvider.getRecipesByCookingTime(20, 40);
        expect(quickRecipes.length, 1);
        expect(quickRecipes.first.cookingTime, 30);

        // Test recipe deletion
        await recipeProvider.deleteRecipe(recipe1Id);
        final deletedRecipe = await recipeProvider.getRecipeById(recipe1Id);
        expect(deletedRecipe, null);
      });

      testWidgets('Recipe generation with malformed AI response', (
        WidgetTester tester,
      ) async {
        // Arrange
        const ingredients = ['eggs', 'bread'];
        const malformedJson = 'This is not valid JSON';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => malformedJson);

        // Act
        await recipeProvider.generateRecipes(ingredients);

        // Assert
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, isNotNull);
        expect(recipeProvider.error, contains('Failed to parse recipe data'));
        expect(recipeProvider.recipes.isEmpty, true);
      });

      testWidgets('Recipe generation with partial AI response', (
        WidgetTester tester,
      ) async {
        // Arrange
        const ingredients = ['salmon'];
        const partialJson = '''
        {
          "title": "Grilled Salmon"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => partialJson);

        // Act
        await recipeProvider.generateRecipes(ingredients);

        // Assert - Should handle missing fields gracefully
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, null);
        expect(recipeProvider.recipes.length, 1);

        final recipe = recipeProvider.recipes.first;
        expect(recipe.title, 'Grilled Salmon');
        expect(
          recipe.ingredients,
          ingredients,
        ); // Should fallback to input ingredients
        expect(recipe.steps.isEmpty, true); // Should be empty array
        expect(recipe.cookingTime, 30); // Should use default
        expect(recipe.difficulty, 'Medium'); // Should use default
      });

      testWidgets('Cache key generation consistency', (
        WidgetTester tester,
      ) async {
        // Arrange - Same ingredients in different order
        const ingredients1 = ['chicken', 'rice', 'vegetables'];
        const ingredients2 = ['rice', 'chicken', 'vegetables'];
        const ingredients3 = ['vegetables', 'chicken', 'rice'];

        const mockRecipeJson = '''
        {
          "title": "Chicken Rice Bowl",
          "ingredients": ["chicken", "rice", "vegetables"],
          "steps": ["Cook rice", "Prepare chicken", "Add vegetables"],
          "cookingTime": 25,
          "difficulty": "Easy"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(any),
        ).thenAnswer((_) async => mockRecipeJson);

        // Act - Generate with first ingredient order
        await recipeProvider.generateRecipes(ingredients1);

        // Clear current recipes but keep cache
        recipeProvider.clearRecipes();

        // Generate with different ingredient order
        await recipeProvider.generateRecipes(ingredients2);

        // Assert - Should use cache (only one AI service call)
        verify(mockAIServiceManager.generateRecipe(any)).called(1);
        expect(recipeProvider.recipes.length, 1);

        // Test third order
        recipeProvider.clearRecipes();
        await recipeProvider.generateRecipes(ingredients3);

        // Should still use cache
        verify(mockAIServiceManager.generateRecipe(any)).called(1);
      });

      testWidgets('Recipe refresh functionality', (WidgetTester tester) async {
        // Arrange
        const ingredients = ['chicken', 'pasta'];
        const originalRecipeJson = '''
        {
          "title": "Original Chicken Pasta",
          "ingredients": ["chicken", "pasta"],
          "steps": ["Cook pasta", "Prepare chicken"],
          "cookingTime": 20,
          "difficulty": "Easy"
        }
        ''';

        const refreshedRecipeJson = '''
        {
          "title": "Refreshed Chicken Pasta",
          "ingredients": ["chicken", "pasta", "herbs"],
          "steps": ["Cook pasta", "Season chicken", "Add herbs"],
          "cookingTime": 25,
          "difficulty": "Medium"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => originalRecipeJson);

        // Act - Initial generation
        await recipeProvider.generateRecipes(ingredients);
        expect(recipeProvider.recipes.first.title, 'Original Chicken Pasta');

        // Change mock response for refresh
        when(
          mockAIServiceManager.generateRecipe(ingredients),
        ).thenAnswer((_) async => refreshedRecipeJson);

        // Refresh recipes
        await recipeProvider.refreshRecipes();

        // Assert
        expect(recipeProvider.recipes.first.title, 'Refreshed Chicken Pasta');
        expect(recipeProvider.recipes.first.cookingTime, 25);
        verify(mockAIServiceManager.generateRecipe(ingredients)).called(2);
      });
    });

    group('Performance and Edge Cases', () {
      testWidgets('Large ingredient list handling', (
        WidgetTester tester,
      ) async {
        // Arrange
        final largeIngredientList = List.generate(
          20,
          (index) => 'ingredient$index',
        );
        const mockRecipeJson = '''
        {
          "title": "Complex Multi-Ingredient Recipe",
          "ingredients": ["ingredient0", "ingredient1", "ingredient2"],
          "steps": ["Step 1", "Step 2", "Step 3"],
          "cookingTime": 45,
          "difficulty": "Hard"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(largeIngredientList),
        ).thenAnswer((_) async => mockRecipeJson);

        // Act
        await recipeProvider.generateRecipes(largeIngredientList);

        // Assert
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, null);
        expect(recipeProvider.recipes.length, 1);
        expect(recipeProvider.currentIngredients, largeIngredientList);
      });

      testWidgets('Special characters in ingredients', (
        WidgetTester tester,
      ) async {
        // Arrange
        const specialIngredients = [
          'jalapeño peppers',
          'crème fraîche',
          'café au lait',
        ];
        const mockRecipeJson = '''
        {
          "title": "International Fusion Dish",
          "ingredients": ["jalapeño peppers", "crème fraîche", "café au lait"],
          "steps": ["Prepare ingredients", "Combine carefully"],
          "cookingTime": 30,
          "difficulty": "Medium"
        }
        ''';

        when(
          mockAIServiceManager.generateRecipe(specialIngredients),
        ).thenAnswer((_) async => mockRecipeJson);

        // Act
        await recipeProvider.generateRecipes(specialIngredients);

        // Assert
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, null);
        expect(recipeProvider.recipes.length, 1);
        expect(recipeProvider.recipes.first.title, 'International Fusion Dish');
      });

      testWidgets('Concurrent recipe generation requests', (
        WidgetTester tester,
      ) async {
        // Arrange
        const ingredients1 = ['beef'];
        const ingredients2 = ['chicken'];

        when(mockAIServiceManager.generateRecipe(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return '''
              {
                "title": "Test Recipe",
                "ingredients": ["test"],
                "steps": ["Step 1"],
                "cookingTime": 20,
                "difficulty": "Easy"
              }
              ''';
        });

        // Act - Start concurrent requests
        final future1 = recipeProvider.generateRecipes(ingredients1);
        final future2 = recipeProvider.generateRecipes(ingredients2);

        await Future.wait([future1, future2]);

        // Assert - Should handle concurrent requests gracefully
        expect(recipeProvider.isLoading, false);
        expect(recipeProvider.error, null);
        expect(recipeProvider.recipes.length, 1);
      });
    });
  });
}
