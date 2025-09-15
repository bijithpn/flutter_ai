import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/models/recipe.dart';

void main() {
  group('Recipe Model Tests', () {
    late Recipe testRecipe;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 12, 0, 0);
      testRecipe = Recipe(
        id: 'recipe_1',
        title: 'Spaghetti Carbonara',
        ingredients: ['pasta', 'eggs', 'bacon', 'cheese'],
        steps: ['Boil pasta', 'Cook bacon', 'Mix eggs and cheese', 'Combine all'],
        imageUrl: 'https://example.com/image.jpg',
        cookingTime: 30,
        difficulty: 'Medium',
        createdAt: testDate,
      );
    });

    test('should create Recipe with all required fields', () {
      expect(testRecipe.id, equals('recipe_1'));
      expect(testRecipe.title, equals('Spaghetti Carbonara'));
      expect(testRecipe.ingredients, hasLength(4));
      expect(testRecipe.steps, hasLength(4));
      expect(testRecipe.imageUrl, equals('https://example.com/image.jpg'));
      expect(testRecipe.cookingTime, equals(30));
      expect(testRecipe.difficulty, equals('Medium'));
      expect(testRecipe.createdAt, equals(testDate));
    });

    test('should create Recipe without optional imageUrl', () {
      final recipe = Recipe(
        id: 'recipe_2',
        title: 'Simple Pasta',
        ingredients: ['pasta'],
        steps: ['Boil pasta'],
        cookingTime: 15,
        difficulty: 'Easy',
        createdAt: testDate,
      );

      expect(recipe.imageUrl, isNull);
    });

    test('should serialize to JSON correctly', () {
      final json = testRecipe.toJson();

      expect(json['id'], equals('recipe_1'));
      expect(json['title'], equals('Spaghetti Carbonara'));
      expect(json['ingredients'], equals(['pasta', 'eggs', 'bacon', 'cheese']));
      expect(json['steps'], equals(['Boil pasta', 'Cook bacon', 'Mix eggs and cheese', 'Combine all']));
      expect(json['imageUrl'], equals('https://example.com/image.jpg'));
      expect(json['cookingTime'], equals(30));
      expect(json['difficulty'], equals('Medium'));
      expect(json['createdAt'], equals(testDate.toIso8601String()));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'recipe_1',
        'title': 'Spaghetti Carbonara',
        'ingredients': ['pasta', 'eggs', 'bacon', 'cheese'],
        'steps': ['Boil pasta', 'Cook bacon', 'Mix eggs and cheese', 'Combine all'],
        'imageUrl': 'https://example.com/image.jpg',
        'cookingTime': 30,
        'difficulty': 'Medium',
        'createdAt': testDate.toIso8601String(),
      };

      final recipe = Recipe.fromJson(json);

      expect(recipe.id, equals('recipe_1'));
      expect(recipe.title, equals('Spaghetti Carbonara'));
      expect(recipe.ingredients, equals(['pasta', 'eggs', 'bacon', 'cheese']));
      expect(recipe.steps, equals(['Boil pasta', 'Cook bacon', 'Mix eggs and cheese', 'Combine all']));
      expect(recipe.imageUrl, equals('https://example.com/image.jpg'));
      expect(recipe.cookingTime, equals(30));
      expect(recipe.difficulty, equals('Medium'));
      expect(recipe.createdAt, equals(testDate));
    });

    test('should handle null imageUrl in JSON serialization', () {
      final recipeWithoutImage = Recipe(
        id: 'recipe_2',
        title: 'Simple Recipe',
        ingredients: ['ingredient1'],
        steps: ['step1'],
        cookingTime: 15,
        difficulty: 'Easy',
        createdAt: testDate,
      );
      final json = recipeWithoutImage.toJson();
      final deserializedRecipe = Recipe.fromJson(json);

      expect(deserializedRecipe.imageUrl, isNull);
    });

    test('should create copy with modified fields', () {
      final modifiedRecipe = testRecipe.copyWith(
        title: 'Modified Carbonara',
        cookingTime: 45,
      );

      expect(modifiedRecipe.id, equals(testRecipe.id));
      expect(modifiedRecipe.title, equals('Modified Carbonara'));
      expect(modifiedRecipe.cookingTime, equals(45));
      expect(modifiedRecipe.ingredients, equals(testRecipe.ingredients));
    });

    test('should implement equality correctly', () {
      final recipe1 = Recipe(
        id: 'recipe_1',
        title: 'Test Recipe',
        ingredients: ['ingredient1'],
        steps: ['step1'],
        cookingTime: 30,
        difficulty: 'Easy',
        createdAt: testDate,
      );

      final recipe2 = Recipe(
        id: 'recipe_1',
        title: 'Test Recipe',
        ingredients: ['ingredient1'],
        steps: ['step1'],
        cookingTime: 30,
        difficulty: 'Easy',
        createdAt: testDate,
      );

      final recipe3 = recipe1.copyWith(title: 'Different Recipe');

      expect(recipe1, equals(recipe2));
      expect(recipe1, isNot(equals(recipe3)));
    });

    test('should have proper toString implementation', () {
      final string = testRecipe.toString();
      expect(string, contains('recipe_1'));
      expect(string, contains('Spaghetti Carbonara'));
      expect(string, contains('30'));
      expect(string, contains('Medium'));
    });

    test('should validate JSON round-trip', () {
      final json = testRecipe.toJson();
      final deserializedRecipe = Recipe.fromJson(json);
      final reserializedJson = deserializedRecipe.toJson();

      expect(json, equals(reserializedJson));
      expect(testRecipe, equals(deserializedRecipe));
    });
  });
}