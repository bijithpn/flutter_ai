import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'package:flutter_ai_mvp/services/services.dart';

void main() {
  group('Recipe Creation Debug', () {
    setUp(() async {
      await setUpTestHive();

      // Register Recipe adapter for testing
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(RecipeAdapter());
      }
    });

    tearDown(() async {
      await tearDownTestHive();
    });

    test('should create recipe from JSON', () async {
      // Arrange
      const mockRecipeJson = '''
      {
        "title": "Chicken Rice Bowl",
        "ingredients": ["chicken", "rice", "vegetables", "soy sauce"],
        "steps": ["Cook rice", "Prepare chicken", "Mix vegetables", "Combine all"],
        "cookingTime": 25,
        "difficulty": "Easy"
      }
      ''';

      try {
        // Parse JSON
        final Map<String, dynamic> parsedJson = jsonDecode(mockRecipeJson);
        print('Parsed JSON: $parsedJson');

        // Create Recipe object
        final recipe = Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: parsedJson['title'] ?? 'Generated Recipe',
          ingredients: List<String>.from(
            parsedJson['ingredients'] ?? ['chicken', 'rice'],
          ),
          steps: List<String>.from(parsedJson['steps'] ?? []),
          imageUrl: 'https://picsum.photos/400/300?random=123',
          cookingTime: parsedJson['cookingTime'] ?? 30,
          difficulty: parsedJson['difficulty'] ?? 'Medium',
          createdAt: DateTime.now(),
        );

        print('Created recipe: ${recipe.title}');
        print('Recipe ingredients: ${recipe.ingredients}');
        print('Recipe steps: ${recipe.steps}');

        // Test storage
        final repository = HiveStorageRepository<Recipe>('debug_recipes');
        await repository.save(recipe.id, recipe);
        print('Saved recipe to repository');

        final loadedRecipe = await repository.load(recipe.id);
        print('Loaded recipe: ${loadedRecipe?.title}');

        expect(loadedRecipe, isNotNull);
        expect(loadedRecipe!.title, 'Chicken Rice Bowl');
        expect(loadedRecipe.ingredients.length, 4);
        expect(loadedRecipe.steps.length, 4);
        expect(loadedRecipe.cookingTime, 25);
        expect(loadedRecipe.difficulty, 'Easy');

        await repository.close();
      } catch (e, stackTrace) {
        print('Error: $e');
        print('Stack trace: $stackTrace');
        fail('Recipe creation failed: $e');
      }
    });
  });
}
