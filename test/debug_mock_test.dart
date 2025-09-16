import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_ai_mvp/services/services.dart';

import 'providers/recipe_provider_test.mocks.dart';

void main() {
  group('Mock Debug', () {
    test('should mock AIServiceManager correctly', () async {
      // Arrange
      final mockAIServiceManager = MockAIServiceManager();
      const ingredients = ['chicken', 'rice'];
      const mockRecipeJson = '''
      {
        "title": "Test Recipe",
        "ingredients": ["chicken", "rice"],
        "steps": ["Step 1"],
        "cookingTime": 20,
        "difficulty": "Easy"
      }
      ''';

      when(
        mockAIServiceManager.generateRecipe(ingredients),
      ).thenAnswer((_) async => mockRecipeJson);

      // Act
      final result = await mockAIServiceManager.generateRecipe(ingredients);

      // Assert
      print('Mock result: $result');
      expect(result, mockRecipeJson);
      verify(mockAIServiceManager.generateRecipe(ingredients)).called(1);
    });
  });
}
