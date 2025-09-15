import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/models/models.dart';

void main() {
  group('Models Integration Tests', () {
    test('should create complete workout session with pose data', () {
      final keyPoints = [
        KeyPoint(name: 'nose', x: 100.0, y: 200.0, confidence: 0.9),
        KeyPoint(name: 'left_shoulder', x: 80.0, y: 250.0, confidence: 0.85),
        KeyPoint(name: 'right_shoulder', x: 120.0, y: 250.0, confidence: 0.8),
      ];

      final poseData = PoseData(
        keyPoints: keyPoints,
        confidence: 0.85,
        timestamp: DateTime.now(),
      );

      final workoutSession = WorkoutSession(
        id: 'workout_integration_test',
        exerciseType: 'pushup',
        duration: const Duration(minutes: 3),
        poseHistory: [poseData],
        correctPostureCount: 1,
        startTime: DateTime.now().subtract(const Duration(minutes: 3)),
      );

      expect(workoutSession.poseHistory, hasLength(1));
      expect(workoutSession.poseHistory.first.keyPoints, hasLength(3));
      expect(workoutSession.accuracyPercentage, equals(100.0));
      expect(workoutSession.isSuccessful, isTrue);
    });

    test('should serialize and deserialize complete data structures', () {
      final recipe = Recipe(
        id: 'integration_recipe',
        title: 'Integration Test Recipe',
        ingredients: ['ingredient1', 'ingredient2'],
        steps: ['step1', 'step2'],
        cookingTime: 30,
        difficulty: 'Medium',
        createdAt: DateTime(2024, 1, 15),
      );

      final noteSummary = NoteSummary(
        id: 'integration_note',
        originalText: 'This is a long text that needs summarization for testing purposes.',
        summary: 'Long text needs summarization for testing.',
        keyPoints: ['Long text', 'Summarization', 'Testing'],
        createdAt: DateTime(2024, 1, 15),
      );

      final appSettings = AppSettings(
        themeMode: ThemeMode.dark,
        offlineMode: true,
        preferredLanguage: 'en',
        enableHapticFeedback: true,
        aiConfidenceThreshold: 0.8,
      );

      // Test JSON round-trip for all models
      final recipeJson = recipe.toJson();
      final deserializedRecipe = Recipe.fromJson(recipeJson);
      expect(deserializedRecipe, equals(recipe));

      final noteJson = noteSummary.toJson();
      final deserializedNote = NoteSummary.fromJson(noteJson);
      expect(deserializedNote, equals(noteSummary));

      final settingsJson = appSettings.toJson();
      final deserializedSettings = AppSettings.fromJson(settingsJson);
      expect(deserializedSettings, equals(appSettings));
    });

    test('should validate model relationships and constraints', () {
      // Test that pose data with low confidence affects workout session success
      final lowConfidencePose = PoseData(
        keyPoints: [
          KeyPoint(name: 'nose', x: 100.0, y: 200.0, confidence: 0.3),
        ],
        confidence: 0.4,
        timestamp: DateTime.now(),
      );

      final workoutWithLowConfidence = WorkoutSession(
        id: 'low_confidence_workout',
        exerciseType: 'pushup',
        duration: const Duration(minutes: 2),
        poseHistory: [lowConfidencePose],
        correctPostureCount: 0,
        startTime: DateTime.now().subtract(const Duration(minutes: 2)),
      );

      expect(workoutWithLowConfidence.isSuccessful, isFalse);
      expect(workoutWithLowConfidence.goodFormPoses, isEmpty);
      expect(workoutWithLowConfidence.averageConfidence, equals(0.4));
    });

    test('should handle edge cases across all models', () {
      // Test empty collections
      final emptyRecipe = Recipe(
        id: 'empty',
        title: 'Empty Recipe',
        ingredients: [],
        steps: [],
        cookingTime: 0,
        difficulty: 'Easy',
        createdAt: DateTime.now(),
      );

      final emptyPoseData = PoseData(
        keyPoints: [],
        confidence: 0.0,
        timestamp: DateTime.now(),
      );

      final emptyWorkout = WorkoutSession(
        id: 'empty',
        exerciseType: 'none',
        duration: Duration.zero,
        poseHistory: [],
        correctPostureCount: 0,
        startTime: DateTime.now(),
      );

      expect(emptyRecipe.ingredients, isEmpty);
      expect(emptyRecipe.steps, isEmpty);
      expect(emptyPoseData.getValidKeyPoints(), isEmpty);
      expect(emptyWorkout.accuracyPercentage, equals(0.0));
      expect(emptyWorkout.averageConfidence, equals(0.0));
    });

    test('should validate app settings constraints', () {
      final validSettings = AppSettings(
        aiConfidenceThreshold: 0.75,
        maxRecipeHistory: 100,
        maxWorkoutHistory: 200,
        preferredLanguage: 'en',
      );

      final invalidSettings = AppSettings(
        aiConfidenceThreshold: 1.5, // Invalid - above 1.0
        maxRecipeHistory: -10, // Invalid - negative
        maxWorkoutHistory: 2000, // Invalid - too high
        preferredLanguage: '', // Invalid - empty
      );

      expect(validSettings.isValid, isTrue);
      expect(invalidSettings.isValid, isFalse);
      expect(invalidSettings.isValidConfidenceThreshold, isFalse);
      expect(invalidSettings.isValidHistoryLimits, isFalse);
    });

    test('should demonstrate model utility methods', () {
      final keyPoint = KeyPoint(
        name: 'test_point',
        x: 150.0,
        y: 300.0,
        confidence: 0.75,
      );

      final poseData = PoseData(
        keyPoints: [keyPoint],
        confidence: 0.8,
        timestamp: DateTime.now(),
      );

      final noteSummary = NoteSummary(
        id: 'utility_test',
        originalText: 'This is a test text with exactly ten words in it.',
        summary: 'Test text with ten words.',
        keyPoints: ['Test', 'Words'],
        createdAt: DateTime.now(),
      );

      // Test utility methods
      expect(keyPoint.isValid(), isTrue);
      expect(keyPoint.isValid(threshold: 0.8), isFalse);
      expect(poseData.isReliable(), isTrue);
      expect(poseData.getKeyPoint('test_point'), equals(keyPoint));
      expect(noteSummary.originalWordCount, equals(11)); // "This is a test text with exactly ten words in it" = 11 words
      expect(noteSummary.summaryWordCount, equals(5));
      expect(noteSummary.compressionRatio, closeTo(0.45, 0.01)); // 5/11 ≈ 0.45
      expect(noteSummary.isEffectiveSummary, isFalse); // Too short summary
    });
  });
}