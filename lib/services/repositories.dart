import 'package:flutter/material.dart';
import '../models/models.dart';
import 'storage_repository.dart';
import 'storage_service.dart';

/// Repository for Recipe data
class RecipeRepository extends HiveStorageRepository<Recipe> {
  RecipeRepository() : super(BoxNames.recipes);

  /// Get recipes by difficulty level
  Future<List<Recipe>> getRecipesByDifficulty(String difficulty) async {
    final allRecipes = await loadAll();
    return allRecipes.where((recipe) => recipe.difficulty == difficulty).toList();
  }

  /// Get recipes by cooking time range
  Future<List<Recipe>> getRecipesByCookingTime(int minTime, int maxTime) async {
    final allRecipes = await loadAll();
    return allRecipes
        .where((recipe) => recipe.cookingTime >= minTime && recipe.cookingTime <= maxTime)
        .toList();
  }

  /// Search recipes by ingredient
  Future<List<Recipe>> searchByIngredient(String ingredient) async {
    final allRecipes = await loadAll();
    return allRecipes
        .where((recipe) => recipe.ingredients
            .any((ing) => ing.toLowerCase().contains(ingredient.toLowerCase())))
        .toList();
  }

  /// Get recent recipes (sorted by creation date)
  Future<List<Recipe>> getRecentRecipes({int limit = 10}) async {
    final allRecipes = await loadAll();
    allRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allRecipes.take(limit).toList();
  }
}

/// Repository for PoseData
class PoseDataRepository extends HiveStorageRepository<PoseData> {
  PoseDataRepository() : super(BoxNames.poseData);

  /// Get pose data within a time range
  Future<List<PoseData>> getPoseDataInRange(DateTime start, DateTime end) async {
    final allPoseData = await loadAll();
    return allPoseData
        .where((pose) => pose.timestamp.isAfter(start) && pose.timestamp.isBefore(end))
        .toList();
  }

  /// Get pose data with minimum confidence
  Future<List<PoseData>> getPoseDataByConfidence(double minConfidence) async {
    final allPoseData = await loadAll();
    return allPoseData.where((pose) => pose.confidence >= minConfidence).toList();
  }
}

/// Repository for NoteSummary data
class NoteSummaryRepository extends HiveStorageRepository<NoteSummary> {
  NoteSummaryRepository() : super(BoxNames.noteSummaries);

  /// Search summaries by keyword
  Future<List<NoteSummary>> searchSummaries(String keyword) async {
    final allSummaries = await loadAll();
    final lowerKeyword = keyword.toLowerCase();
    return allSummaries
        .where((summary) =>
            summary.summary.toLowerCase().contains(lowerKeyword) ||
            summary.originalText.toLowerCase().contains(lowerKeyword) ||
            summary.keyPoints.any((point) => point.toLowerCase().contains(lowerKeyword)))
        .toList();
  }

  /// Get recent summaries (sorted by creation date)
  Future<List<NoteSummary>> getRecentSummaries({int limit = 20}) async {
    final allSummaries = await loadAll();
    allSummaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allSummaries.take(limit).toList();
  }

  /// Get summaries by date range
  Future<List<NoteSummary>> getSummariesInRange(DateTime start, DateTime end) async {
    final allSummaries = await loadAll();
    return allSummaries
        .where((summary) => 
            summary.createdAt.isAfter(start) && summary.createdAt.isBefore(end))
        .toList();
  }
}

/// Repository for WorkoutSession data
class WorkoutSessionRepository extends HiveStorageRepository<WorkoutSession> {
  WorkoutSessionRepository() : super(BoxNames.workoutSessions);

  /// Get sessions by exercise type
  Future<List<WorkoutSession>> getSessionsByExerciseType(String exerciseType) async {
    final allSessions = await loadAll();
    return allSessions.where((session) => session.exerciseType == exerciseType).toList();
  }

  /// Get sessions within a date range
  Future<List<WorkoutSession>> getSessionsInRange(DateTime start, DateTime end) async {
    final allSessions = await loadAll();
    return allSessions
        .where((session) => 
            session.startTime.isAfter(start) && session.startTime.isBefore(end))
        .toList();
  }

  /// Get recent sessions (sorted by start time)
  Future<List<WorkoutSession>> getRecentSessions({int limit = 10}) async {
    final allSessions = await loadAll();
    allSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return allSessions.take(limit).toList();
  }

  /// Calculate total workout time for a date range
  Future<Duration> getTotalWorkoutTime(DateTime start, DateTime end) async {
    final sessions = await getSessionsInRange(start, end);
    return sessions.fold<Duration>(Duration.zero, (total, session) => total + session.duration);
  }

  /// Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStats() async {
    final allSessions = await loadAll();
    
    if (allSessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalDuration': Duration.zero,
        'averageDuration': Duration.zero,
        'exerciseTypes': <String>[],
        'totalCorrectPostures': 0,
      };
    }

    final totalDuration = allSessions.fold<Duration>(
      Duration.zero, 
      (total, session) => total + session.duration,
    );
    
    final averageDuration = Duration(
      milliseconds: totalDuration.inMilliseconds ~/ allSessions.length,
    );
    
    final exerciseTypes = allSessions
        .map((session) => session.exerciseType)
        .toSet()
        .toList();
    
    final totalCorrectPostures = allSessions.fold(
      0, 
      (total, session) => total + session.correctPostureCount,
    );

    return {
      'totalSessions': allSessions.length,
      'totalDuration': totalDuration,
      'averageDuration': averageDuration,
      'exerciseTypes': exerciseTypes,
      'totalCorrectPostures': totalCorrectPostures,
    };
  }
}

/// Repository for AppSettings data
class AppSettingsRepository extends HiveStorageRepository<AppSettings> {
  AppSettingsRepository() : super(BoxNames.appSettings);

  static const String _defaultSettingsKey = 'default_settings';

  /// Get the current app settings
  Future<AppSettings?> getCurrentSettings() async {
    return await load(_defaultSettingsKey);
  }

  /// Save the current app settings
  Future<void> saveCurrentSettings(AppSettings settings) async {
    await save(_defaultSettingsKey, settings);
  }

  /// Update specific setting fields
  Future<void> updateSettings({
    ThemeMode? themeMode,
    bool? offlineMode,
    String? preferredLanguage,
    bool? enableHapticFeedback,
  }) async {
    final currentSettings = await getCurrentSettings();
    
    if (currentSettings != null) {
      final updatedSettings = currentSettings.copyWith(
        themeMode: themeMode,
        offlineMode: offlineMode,
        preferredLanguage: preferredLanguage,
        enableHapticFeedback: enableHapticFeedback,
      );
      await saveCurrentSettings(updatedSettings);
    }
  }
}