import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:flutter_ai_mvp/models/models.dart';
import 'package:flutter_ai_mvp/services/services.dart';

void main() {
  group('Repository Tests', () {
    setUpAll(() async {
      await setUpTestHive();
      // Register all adapters
      Hive.registerAdapter(RecipeAdapter());
      Hive.registerAdapter(NoteSummaryAdapter());
      Hive.registerAdapter(WorkoutSessionAdapter());
      Hive.registerAdapter(PoseDataAdapter());
      Hive.registerAdapter(KeyPointAdapter());
      Hive.registerAdapter(AppSettingsAdapter());
      Hive.registerAdapter(DurationAdapter());
      Hive.registerAdapter(ThemeModeHiveAdapter());
    });

    tearDownAll(() async {
      await tearDownTestHive();
    });

    group('RecipeRepository Tests', () {
      late RecipeRepository repository;
      late List<Recipe> testRecipes;

      setUp(() async {
        repository = RecipeRepository();
        testRecipes = [
          Recipe(
            id: 'recipe1',
            title: 'Easy Pasta',
            ingredients: ['pasta', 'tomato sauce'],
            steps: ['boil pasta', 'add sauce'],
            cookingTime: 15,
            difficulty: 'easy',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Recipe(
            id: 'recipe2',
            title: 'Hard Steak',
            ingredients: ['steak', 'salt', 'pepper'],
            steps: ['season steak', 'grill steak'],
            cookingTime: 45,
            difficulty: 'hard',
            createdAt: DateTime.now(),
          ),
        ];
      });

      tearDown(() async {
        await repository.clear();
        await repository.close();
      });

      test('should filter recipes by difficulty', () async {
        for (int i = 0; i < testRecipes.length; i++) {
          await repository.save('recipe$i', testRecipes[i]);
        }

        final easyRecipes = await repository.getRecipesByDifficulty('easy');
        expect(easyRecipes.length, equals(1));
        expect(easyRecipes.first.difficulty, equals('easy'));
      });

      test('should filter recipes by cooking time range', () async {
        for (int i = 0; i < testRecipes.length; i++) {
          await repository.save('recipe$i', testRecipes[i]);
        }

        final quickRecipes = await repository.getRecipesByCookingTime(10, 20);
        expect(quickRecipes.length, equals(1));
        expect(quickRecipes.first.cookingTime, equals(15));
      });

      test('should search recipes by ingredient', () async {
        for (int i = 0; i < testRecipes.length; i++) {
          await repository.save('recipe$i', testRecipes[i]);
        }

        final pastaRecipes = await repository.searchByIngredient('pasta');
        expect(pastaRecipes.length, equals(1));
        expect(pastaRecipes.first.title, equals('Easy Pasta'));
      });

      test('should get recent recipes sorted by creation date', () async {
        for (int i = 0; i < testRecipes.length; i++) {
          await repository.save('recipe$i', testRecipes[i]);
        }

        final recentRecipes = await repository.getRecentRecipes(limit: 5);
        expect(recentRecipes.length, equals(2));
        expect(recentRecipes.first.title, equals('Hard Steak')); // Most recent
      });
    });

    group('NoteSummaryRepository Tests', () {
      late NoteSummaryRepository repository;
      late List<NoteSummary> testSummaries;

      setUp(() async {
        repository = NoteSummaryRepository();
        testSummaries = [
          NoteSummary(
            id: 'summary1',
            originalText: 'This is a long text about machine learning',
            summary: 'Text about ML',
            keyPoints: ['machine learning', 'AI'],
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          NoteSummary(
            id: 'summary2',
            originalText: 'Flutter development guide',
            summary: 'Flutter guide',
            keyPoints: ['Flutter', 'development'],
            createdAt: DateTime.now(),
          ),
        ];
      });

      tearDown(() async {
        await repository.clear();
        await repository.close();
      });

      test('should search summaries by keyword', () async {
        for (int i = 0; i < testSummaries.length; i++) {
          await repository.save('summary$i', testSummaries[i]);
        }

        final mlSummaries = await repository.searchSummaries('machine');
        expect(mlSummaries.length, equals(1));
        expect(mlSummaries.first.id, equals('summary1'));
      });

      test('should get recent summaries', () async {
        for (int i = 0; i < testSummaries.length; i++) {
          await repository.save('summary$i', testSummaries[i]);
        }

        final recentSummaries = await repository.getRecentSummaries(limit: 5);
        expect(recentSummaries.length, equals(2));
        expect(recentSummaries.first.id, equals('summary2')); // Most recent
      });

      test('should get summaries in date range', () async {
        for (int i = 0; i < testSummaries.length; i++) {
          await repository.save('summary$i', testSummaries[i]);
        }

        final now = DateTime.now();
        final summariesInRange = await repository.getSummariesInRange(
          now.subtract(const Duration(minutes: 30)),
          now.add(const Duration(minutes: 30)),
        );

        expect(summariesInRange.length, equals(1));
        expect(summariesInRange.first.id, equals('summary2'));
      });
    });

    group('WorkoutSessionRepository Tests', () {
      late WorkoutSessionRepository repository;
      late List<WorkoutSession> testSessions;

      setUp(() async {
        repository = WorkoutSessionRepository();
        testSessions = [
          WorkoutSession(
            id: 'session1',
            exerciseType: 'push-ups',
            duration: const Duration(minutes: 10),
            poseHistory: [],
            correctPostureCount: 15,
            startTime: DateTime.now().subtract(const Duration(days: 1)),
          ),
          WorkoutSession(
            id: 'session2',
            exerciseType: 'squats',
            duration: const Duration(minutes: 15),
            poseHistory: [],
            correctPostureCount: 20,
            startTime: DateTime.now(),
          ),
        ];
      });

      tearDown(() async {
        await repository.clear();
        await repository.close();
      });

      test('should filter sessions by exercise type', () async {
        for (int i = 0; i < testSessions.length; i++) {
          await repository.save('session$i', testSessions[i]);
        }

        final pushUpSessions = await repository.getSessionsByExerciseType(
          'push-ups',
        );
        expect(pushUpSessions.length, equals(1));
        expect(pushUpSessions.first.exerciseType, equals('push-ups'));
      });

      test('should get recent sessions', () async {
        for (int i = 0; i < testSessions.length; i++) {
          await repository.save('session$i', testSessions[i]);
        }

        final recentSessions = await repository.getRecentSessions(limit: 5);
        expect(recentSessions.length, equals(2));
        expect(
          recentSessions.first.exerciseType,
          equals('squats'),
        ); // Most recent
      });

      test('should calculate total workout time', () async {
        for (int i = 0; i < testSessions.length; i++) {
          await repository.save('session$i', testSessions[i]);
        }

        final now = DateTime.now();
        final totalTime = await repository.getTotalWorkoutTime(
          now.subtract(const Duration(days: 2)),
          now.add(const Duration(hours: 1)),
        );

        expect(totalTime, equals(const Duration(minutes: 25)));
      });

      test('should get workout statistics', () async {
        for (int i = 0; i < testSessions.length; i++) {
          await repository.save('session$i', testSessions[i]);
        }

        final stats = await repository.getWorkoutStats();

        expect(stats['totalSessions'], equals(2));
        expect(stats['totalDuration'], equals(const Duration(minutes: 25)));
        expect(stats['exerciseTypes'], containsAll(['push-ups', 'squats']));
        expect(stats['totalCorrectPostures'], equals(35));
      });

      test('should return empty stats for no sessions', () async {
        final stats = await repository.getWorkoutStats();

        expect(stats['totalSessions'], equals(0));
        expect(stats['totalDuration'], equals(Duration.zero));
        expect(stats['exerciseTypes'], isEmpty);
        expect(stats['totalCorrectPostures'], equals(0));
      });
    });

    group('AppSettingsRepository Tests', () {
      late AppSettingsRepository repository;
      late AppSettings testSettings;

      setUp(() async {
        repository = AppSettingsRepository();
        testSettings = AppSettings(
          themeMode: ThemeMode.dark,
          offlineMode: true,
          preferredLanguage: 'es',
          enableHapticFeedback: false,
        );
      });

      tearDown(() async {
        await repository.clear();
        await repository.close();
      });

      test('should save and get current settings', () async {
        await repository.saveCurrentSettings(testSettings);

        final loadedSettings = await repository.getCurrentSettings();
        expect(loadedSettings, isNotNull);
        expect(loadedSettings!.themeMode, equals(ThemeMode.dark));
        expect(loadedSettings.offlineMode, isTrue);
      });

      test('should return null when no settings exist', () async {
        final settings = await repository.getCurrentSettings();
        expect(settings, isNull);
      });

      test('should update specific settings', () async {
        await repository.saveCurrentSettings(testSettings);

        await repository.updateSettings(
          themeMode: ThemeMode.light,
          offlineMode: false,
        );

        final updatedSettings = await repository.getCurrentSettings();
        expect(updatedSettings!.themeMode, equals(ThemeMode.light));
        expect(updatedSettings.offlineMode, isFalse);
        expect(updatedSettings.preferredLanguage, equals('es')); // Unchanged
      });
    });
  });
}
