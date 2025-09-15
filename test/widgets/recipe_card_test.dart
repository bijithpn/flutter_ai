import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/widgets/recipe_card.dart';
import 'package:flutter_ai_mvp/models/recipe.dart';

void main() {
  group('RecipeCard Widget Tests', () {
    late Recipe testRecipe;

    setUp(() {
      testRecipe = Recipe(
        id: '1',
        title: 'Test Recipe',
        ingredients: ['ingredient1', 'ingredient2', 'ingredient3'],
        steps: ['step1', 'step2'],
        cookingTime: 30,
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      );
    });

    testWidgets('should display recipe information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: testRecipe)),
        ),
      );

      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('3 ingredients'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeCard(
              recipe: testRecipe,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RecipeCard));
      expect(wasTapped, isTrue);
    });

    testWidgets(
      'should show ingredients preview when showFullDetails is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecipeCard(recipe: testRecipe, showFullDetails: true),
            ),
          ),
        );

        expect(find.text('Ingredients'), findsOneWidget);
        expect(
          find.text('ingredient1, ingredient2, ingredient3'),
          findsOneWidget,
        );
      },
    );

    testWidgets('should display image placeholder when no imageUrl', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: testRecipe)),
        ),
      );

      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
      expect(find.text('Recipe Image'), findsOneWidget);
    });
  });

  group('CompactRecipeCard Widget Tests', () {
    late Recipe testRecipe;

    setUp(() {
      testRecipe = Recipe(
        id: '1',
        title: 'Compact Test Recipe',
        ingredients: ['ingredient1', 'ingredient2'],
        steps: ['step1'],
        cookingTime: 15,
        difficulty: 'Medium',
        createdAt: DateTime.now(),
      );
    });

    testWidgets('should display compact recipe information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CompactRecipeCard(recipe: testRecipe)),
        ),
      );

      expect(find.text('Compact Test Recipe'), findsOneWidget);
      expect(find.text('15 min • Medium • 2 ingredients'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactRecipeCard(
              recipe: testRecipe,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CompactRecipeCard));
      expect(wasTapped, isTrue);
    });
  });
}
