import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'repositories.dart';
import 'settings_service.dart';
import 'storage_service.dart';

/// Central storage manager that provides access to all repositories and services
class StorageManager {
  static StorageManager? _instance;
  static StorageManager get instance => _instance ??= StorageManager._();

  StorageManager._();

  // Private constructor for testing
  StorageManager.forTesting();

  // Repositories
  late final RecipeRepository _recipeRepository;
  late final PoseDataRepository _poseDataRepository;
  late final NoteSummaryRepository _noteSummaryRepository;
  late final WorkoutSessionRepository _workoutSessionRepository;
  late final AppSettingsRepository _appSettingsRepository;

  // Services
  late final SettingsService _settingsService;

  bool _isInitialized = false;

  // Expose private fields for testing
  @visibleForTesting
  set settingsService(SettingsService service) => _settingsService = service;

  @visibleForTesting
  set recipeRepository(RecipeRepository repo) => _recipeRepository = repo;

  @visibleForTesting
  set poseDataRepository(PoseDataRepository repo) => _poseDataRepository = repo;

  @visibleForTesting
  set noteSummaryRepository(NoteSummaryRepository repo) =>
      _noteSummaryRepository = repo;

  @visibleForTesting
  set workoutSessionRepository(WorkoutSessionRepository repo) =>
      _workoutSessionRepository = repo;

  @visibleForTesting
  set appSettingsRepository(AppSettingsRepository repo) =>
      _appSettingsRepository = repo;

  @visibleForTesting
  set isInitializedForTesting(bool value) => _isInitialized = value;

  /// Initialize all storage components
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive storage
    await StorageService.init();

    // Initialize repositories
    _recipeRepository = RecipeRepository();
    _poseDataRepository = PoseDataRepository();
    _noteSummaryRepository = NoteSummaryRepository();
    _workoutSessionRepository = WorkoutSessionRepository();
    _appSettingsRepository = AppSettingsRepository();

    // Initialize settings service
    _settingsService = SettingsService();
    await _settingsService.init();

    _isInitialized = true;
  }

  /// Ensure storage is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('StorageManager not initialized. Call init() first.');
    }
  }

  // Repository getters
  RecipeRepository get recipes {
    _ensureInitialized();
    return _recipeRepository;
  }

  PoseDataRepository get poseData {
    _ensureInitialized();
    return _poseDataRepository;
  }

  NoteSummaryRepository get noteSummaries {
    _ensureInitialized();
    return _noteSummaryRepository;
  }

  WorkoutSessionRepository get workoutSessions {
    _ensureInitialized();
    return _workoutSessionRepository;
  }

  AppSettingsRepository get appSettings {
    _ensureInitialized();
    return _appSettingsRepository;
  }

  SettingsService get settings {
    _ensureInitialized();
    return _settingsService;
  }

  /// Check if storage is initialized
  bool get isInitialized => _isInitialized;

  /// Clear all data (useful for testing or reset)
  Future<void> clearAllData() async {
    _ensureInitialized();

    await Future.wait([
      _recipeRepository.clear(),
      _poseDataRepository.clear(),
      _noteSummaryRepository.clear(),
      _workoutSessionRepository.clear(),
      _appSettingsRepository.clear(),
      _settingsService.clearAllSettings(),
    ]);
  }

  /// Close all storage connections
  Future<void> close() async {
    if (!_isInitialized) return;

    await Future.wait([
      _recipeRepository.close(),
      _poseDataRepository.close(),
      _noteSummaryRepository.close(),
      _workoutSessionRepository.close(),
      _appSettingsRepository.close(),
    ]);

    await StorageService.closeAll();
    _isInitialized = false;
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    _ensureInitialized();

    final stats = await Future.wait([
      _recipeRepository.count(),
      _poseDataRepository.count(),
      _noteSummaryRepository.count(),
      _workoutSessionRepository.count(),
      _appSettingsRepository.count(),
    ]);

    return {
      'recipes': stats[0],
      'poseData': stats[1],
      'noteSummaries': stats[2],
      'workoutSessions': stats[3],
      'appSettings': stats[4],
      'totalItems': stats.reduce((a, b) => a + b),
    };
  }

  /// Export all data for backup
  Future<Map<String, dynamic>> exportAllData() async {
    _ensureInitialized();

    final data = await Future.wait([
      _recipeRepository.loadAll(),
      _poseDataRepository.loadAll(),
      _noteSummaryRepository.loadAll(),
      _workoutSessionRepository.loadAll(),
      _appSettingsRepository.loadAll(),
    ]);

    return {
      'recipes': (data[0] as List<Recipe>).map((e) => e.toJson()).toList(),
      'poseData': (data[1] as List<PoseData>).map((e) => e.toJson()).toList(),
      'noteSummaries': (data[2] as List<NoteSummary>)
          .map((e) => e.toJson())
          .toList(),
      'workoutSessions': (data[3] as List<WorkoutSession>)
          .map((e) => e.toJson())
          .toList(),
      'appSettings': (data[4] as List<AppSettings>)
          .map((e) => e.toJson())
          .toList(),
      'preferences': _settingsService.exportSettings(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Import data from backup
  Future<void> importAllData(Map<String, dynamic> backupData) async {
    _ensureInitialized();

    // Clear existing data
    await clearAllData();

    // Import recipes
    if (backupData['recipes'] != null) {
      final recipes = (backupData['recipes'] as List)
          .map((json) => Recipe.fromJson(json))
          .toList();
      final recipeMap = <String, Recipe>{};
      for (final recipe in recipes) {
        recipeMap[recipe.id] = recipe;
      }
      await _recipeRepository.saveAll(recipeMap);
    }

    // Import pose data
    if (backupData['poseData'] != null) {
      final poseDataList = (backupData['poseData'] as List)
          .map((json) => PoseData.fromJson(json))
          .toList();
      final poseDataMap = <String, PoseData>{};
      for (int i = 0; i < poseDataList.length; i++) {
        poseDataMap['pose_$i'] = poseDataList[i];
      }
      await _poseDataRepository.saveAll(poseDataMap);
    }

    // Import note summaries
    if (backupData['noteSummaries'] != null) {
      final summaries = (backupData['noteSummaries'] as List)
          .map((json) => NoteSummary.fromJson(json))
          .toList();
      final summaryMap = <String, NoteSummary>{};
      for (final summary in summaries) {
        summaryMap[summary.id] = summary;
      }
      await _noteSummaryRepository.saveAll(summaryMap);
    }

    // Import workout sessions
    if (backupData['workoutSessions'] != null) {
      final sessions = (backupData['workoutSessions'] as List)
          .map((json) => WorkoutSession.fromJson(json))
          .toList();
      final sessionMap = <String, WorkoutSession>{};
      for (final session in sessions) {
        sessionMap[session.id] = session;
      }
      await _workoutSessionRepository.saveAll(sessionMap);
    }

    // Import app settings
    if (backupData['appSettings'] != null) {
      final settingsList = (backupData['appSettings'] as List)
          .map((json) => AppSettings.fromJson(json))
          .toList();
      if (settingsList.isNotEmpty) {
        await _appSettingsRepository.saveCurrentSettings(settingsList.first);
      }
    }

    // Import preferences
    if (backupData['preferences'] != null) {
      await _settingsService.importSettings(
        Map<String, dynamic>.from(backupData['preferences']),
      );
    }
  }
}
