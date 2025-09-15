import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 5)
class AppSettings extends HiveObject {
  @HiveField(0)
  final ThemeMode themeMode;

  @HiveField(1)
  final bool offlineMode;

  @HiveField(2)
  final String preferredLanguage;

  @HiveField(3)
  final bool enableHapticFeedback;

  @HiveField(4)
  final bool enableNotifications;

  @HiveField(5)
  final double aiConfidenceThreshold;

  @HiveField(6)
  final int maxRecipeHistory;

  @HiveField(7)
  final int maxWorkoutHistory;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.offlineMode = false,
    this.preferredLanguage = 'en',
    this.enableHapticFeedback = true,
    this.enableNotifications = true,
    this.aiConfidenceThreshold = 0.7,
    this.maxRecipeHistory = 50,
    this.maxWorkoutHistory = 100,
  });

  // JSON serialization
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      offlineMode: json['offlineMode'] as bool? ?? false,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      aiConfidenceThreshold: (json['aiConfidenceThreshold'] as num?)?.toDouble() ?? 0.7,
      maxRecipeHistory: json['maxRecipeHistory'] as int? ?? 50,
      maxWorkoutHistory: json['maxWorkoutHistory'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'offlineMode': offlineMode,
      'preferredLanguage': preferredLanguage,
      'enableHapticFeedback': enableHapticFeedback,
      'enableNotifications': enableNotifications,
      'aiConfidenceThreshold': aiConfidenceThreshold,
      'maxRecipeHistory': maxRecipeHistory,
      'maxWorkoutHistory': maxWorkoutHistory,
    };
  }

  // Default settings factory
  factory AppSettings.defaultSettings() {
    return AppSettings();
  }

  // Utility methods
  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? offlineMode,
    String? preferredLanguage,
    bool? enableHapticFeedback,
    bool? enableNotifications,
    double? aiConfidenceThreshold,
    int? maxRecipeHistory,
    int? maxWorkoutHistory,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      offlineMode: offlineMode ?? this.offlineMode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      aiConfidenceThreshold: aiConfidenceThreshold ?? this.aiConfidenceThreshold,
      maxRecipeHistory: maxRecipeHistory ?? this.maxRecipeHistory,
      maxWorkoutHistory: maxWorkoutHistory ?? this.maxWorkoutHistory,
    );
  }

  // Validation methods
  bool get isValidConfidenceThreshold {
    return aiConfidenceThreshold >= 0.0 && aiConfidenceThreshold <= 1.0;
  }

  bool get isValidHistoryLimits {
    return maxRecipeHistory > 0 && 
           maxWorkoutHistory > 0 && 
           maxRecipeHistory <= 1000 && 
           maxWorkoutHistory <= 1000;
  }

  bool get isValid {
    return isValidConfidenceThreshold && 
           isValidHistoryLimits && 
           preferredLanguage.isNotEmpty;
  }

  // Theme helpers
  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
  bool get isSystemMode => themeMode == ThemeMode.system;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.offlineMode == offlineMode &&
        other.preferredLanguage == preferredLanguage &&
        other.enableHapticFeedback == enableHapticFeedback &&
        other.enableNotifications == enableNotifications &&
        other.aiConfidenceThreshold == aiConfidenceThreshold &&
        other.maxRecipeHistory == maxRecipeHistory &&
        other.maxWorkoutHistory == maxWorkoutHistory;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeMode,
      offlineMode,
      preferredLanguage,
      enableHapticFeedback,
      enableNotifications,
      aiConfidenceThreshold,
      maxRecipeHistory,
      maxWorkoutHistory,
    );
  }

  @override
  String toString() {
    return 'AppSettings(theme: $themeMode, offline: $offlineMode, language: $preferredLanguage)';
  }
}

// Hive adapter for ThemeMode enum
@HiveType(typeId: 6)
enum ThemeModeAdapter {
  @HiveField(0)
  system,
  @HiveField(1)
  light,
  @HiveField(2)
  dark,
}