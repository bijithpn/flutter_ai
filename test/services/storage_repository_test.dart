import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'package:flutter_ai_mvp/services/services.dart';

void main() {
  group('HiveStorageRepository Tests', () {
    late HiveStorageRepository<Recipe> repository;
    late Recipe testRecipe;

    setUpAll(() async {
      await setUpTestHive();
      Hive.registerAdapter(RecipeAdapter());
    });

    setUp(() async {
      repository = HiveStorageRepository<Recipe>('test_recipes');
      testRecipe = Recipe(
        id: 'test_recipe_1',
        title: 'Test Recipe',
        ingredients: ['ingredient1', 'ingredient2'],
        steps: ['step1', 'step2'],
        cookingTime: 30,
        difficulty: 'easy',
        createdAt: DateTime.now(),
      );
    });

    tearDown(() async {
      await repository.clear();
      await repository.close();
    });

    tearDownAll(() async {
      await tearDownTestHive();
    });

    test('should save and load a recipe', () async {
      // Save recipe
      await repository.save('recipe1', testRecipe);

      // Load recipe
      final loadedRecipe = await repository.load('recipe1');

      expect(loadedRecipe, isNotNull);
      expect(loadedRecipe!.id, equals(testRecipe.id));
      expect(loadedRecipe.title, equals(testRecipe.title));
      expect(loadedRecipe.ingredients, equals(testRecipe.ingredients));
    });

    test('should return null for non-existent key', () async {
      final result = await repository.load('non_existent');
      expect(result, isNull);
    });

    test('should delete a recipe', () async {
      // Save recipe
      await repository.save('recipe1', testRecipe);
      expect(await repository.exists('recipe1'), isTrue);

      // Delete recipe
      await repository.delete('recipe1');
      expect(await repository.exists('recipe1'), isFalse);
    });

    test('should load all recipes', () async {
      final recipe2 = testRecipe.copyWith(id: 'test_recipe_2', title: 'Recipe 2');
      
      await repository.save('recipe1', testRecipe);
      await repository.save('recipe2', recipe2);

      final allRecipes = await repository.loadAll();
      expect(allRecipes.length, equals(2));
      expect(allRecipes.map((r) => r.id), containsAll(['test_recipe_1', 'test_recipe_2']));
    });

    test('should clear all recipes', () async {
      await repository.save('recipe1', testRecipe);
      await repository.save('recipe2', testRecipe.copyWith(id: 'test_recipe_2'));

      expect(await repository.count(), equals(2));

      await repository.clear();
      expect(await repository.count(), equals(0));
    });

    test('should check if key exists', () async {
      expect(await repository.exists('recipe1'), isFalse);

      await repository.save('recipe1', testRecipe);
      expect(await repository.exists('recipe1'), isTrue);
    });

    test('should get all keys', () async {
      await repository.save('recipe1', testRecipe);
      await repository.save('recipe2', testRecipe.copyWith(id: 'test_recipe_2'));

      final keys = await repository.getAllKeys();
      expect(keys, containsAll(['recipe1', 'recipe2']));
    });

    test('should save multiple items at once', () async {
      final recipe2 = testRecipe.copyWith(id: 'test_recipe_2', title: 'Recipe 2');
      final items = {
        'recipe1': testRecipe,
        'recipe2': recipe2,
      };

      await repository.saveAll(items);

      expect(await repository.count(), equals(2));
      expect(await repository.exists('recipe1'), isTrue);
      expect(await repository.exists('recipe2'), isTrue);
    });

    test('should load multiple items by keys', () async {
      final recipe2 = testRecipe.copyWith(id: 'test_recipe_2', title: 'Recipe 2');
      
      await repository.save('recipe1', testRecipe);
      await repository.save('recipe2', recipe2);

      final results = await repository.loadMultiple(['recipe1', 'recipe2', 'non_existent']);

      expect(results['recipe1'], isNotNull);
      expect(results['recipe2'], isNotNull);
      expect(results['non_existent'], isNull);
    });

    test('should delete multiple items by keys', () async {
      await repository.save('recipe1', testRecipe);
      await repository.save('recipe2', testRecipe.copyWith(id: 'test_recipe_2'));
      await repository.save('recipe3', testRecipe.copyWith(id: 'test_recipe_3'));

      await repository.deleteMultiple(['recipe1', 'recipe2']);

      expect(await repository.exists('recipe1'), isFalse);
      expect(await repository.exists('recipe2'), isFalse);
      expect(await repository.exists('recipe3'), isTrue);
    });
  });
}