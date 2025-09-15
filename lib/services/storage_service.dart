import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'hive_adapters.dart';

/// Service for initializing and managing Hive storage
class StorageService {
  static bool _isInitialized = false;

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register all Hive adapters
    _registerAdapters();

    _isInitialized = true;
  }

  /// Register all Hive type adapters
  static void _registerAdapters() {
    // Register adapters only if they haven't been registered yet
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PoseDataAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(KeyPointAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(NoteSummaryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(WorkoutSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(DurationAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(ThemeModeHiveAdapter());
    }
  }

  /// Check if Hive is initialized
  static bool get isInitialized => _isInitialized;

  /// Close all Hive boxes (call this when app is disposed)
  static Future<void> closeAll() async {
    await Hive.close();
    _isInitialized = false;
  }

  /// Delete all data (useful for testing or reset functionality)
  static Future<void> deleteAllData() async {
    await Hive.deleteFromDisk();
    _isInitialized = false;
  }
}

/// Box names for all data types
class BoxNames {
  static const String recipes = 'recipes';
  static const String poseData = 'pose_data';
  static const String noteSummaries = 'note_summaries';
  static const String workoutSessions = 'workout_sessions';
  static const String appSettings = 'app_settings';
}
