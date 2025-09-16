import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('JSON parsing test', () {
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
      final Map<String, dynamic> parsedJson = jsonDecode(mockRecipeJson);
      print('Parsed JSON: $parsedJson');

      final title = parsedJson['title'] ?? 'Generated Recipe';
      final ingredients = List<String>.from(parsedJson['ingredients'] ?? []);
      final steps = List<String>.from(parsedJson['steps'] ?? []);
      final cookingTime = parsedJson['cookingTime'] ?? 30;
      final difficulty = parsedJson['difficulty'] ?? 'Medium';

      print('Title: $title');
      print('Ingredients: $ingredients');
      print('Steps: $steps');
      print('Cooking time: $cookingTime');
      print('Difficulty: $difficulty');

      expect(title, 'Chicken Rice Bowl');
      expect(ingredients.length, 4);
      expect(steps.length, 4);
      expect(cookingTime, 25);
      expect(difficulty, 'Easy');
    } catch (e) {
      print('Error parsing JSON: $e');
      fail('JSON parsing failed: $e');
    }
  });
}
