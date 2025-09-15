import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/widgets/ingredient_input.dart';

void main() {
  group('IngredientInput Widget Tests', () {
    testWidgets('should display empty state initially', (
      WidgetTester tester,
    ) async {
      List<String> ingredients = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IngredientInput(
              ingredients: ingredients,
              onIngredientsChanged: (newIngredients) {
                ingredients = newIngredients;
              },
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Add an ingredient...'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('should add ingredient when text is submitted', (
      WidgetTester tester,
    ) async {
      List<String> ingredients = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IngredientInput(
              ingredients: ingredients,
              onIngredientsChanged: (newIngredients) {
                ingredients = newIngredients;
              },
            ),
          ),
        ),
      );

      // Enter text and submit
      await tester.enterText(find.byType(TextField), 'tomato');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(ingredients, contains('tomato'));
    });

    testWidgets('should display ingredient chips', (WidgetTester tester) async {
      List<String> ingredients = ['tomato', 'onion'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IngredientInput(
              ingredients: ingredients,
              onIngredientsChanged: (newIngredients) {
                ingredients = newIngredients;
              },
            ),
          ),
        ),
      );

      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.text('tomato'), findsOneWidget);
      expect(find.text('onion'), findsOneWidget);
      expect(find.text('Ingredients (2)'), findsOneWidget);
    });

    testWidgets('should remove ingredient when chip is deleted', (
      WidgetTester tester,
    ) async {
      List<String> ingredients = ['tomato', 'onion'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return IngredientInput(
                  ingredients: ingredients,
                  onIngredientsChanged: (newIngredients) {
                    setState(() {
                      ingredients = newIngredients;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Find and tap the delete button on the first chip
      final deleteButton = find.descendant(
        of: find.byType(Chip).first,
        matching: find.byIcon(Icons.close),
      );

      await tester.tap(deleteButton);
      await tester.pump();

      expect(ingredients.length, equals(1));
      expect(ingredients, isNot(contains('tomato')));
    });

    testWidgets('should not add duplicate ingredients', (
      WidgetTester tester,
    ) async {
      List<String> ingredients = ['tomato'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return IngredientInput(
                  ingredients: ingredients,
                  onIngredientsChanged: (newIngredients) {
                    setState(() {
                      ingredients = newIngredients;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Try to add the same ingredient
      await tester.enterText(find.byType(TextField), 'tomato');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(ingredients.length, equals(1));
      expect(find.byType(Chip), findsOneWidget);
    });
  });
}
