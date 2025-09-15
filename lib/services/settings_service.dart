import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app settings and preferences using SharedPreferences
class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _offlineModeKey = 'offline_mode';
  static const String _preferredLanguageKey = 'preferred_language';
  static const String _enableHapticFeedbackKey = 'enable_haptic_feedback';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _firstLaunchKey = 'first_launch';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure SharedPreferences is initialized
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('SettingsService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Theme Settings
  
  /// Get the current theme mode
  ThemeMode getThemeMode() {
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[themeModeIndex];
  }

  /// Set the theme mode
  Future<bool> setThemeMode(ThemeMode themeMode) async {
    return await prefs.setInt(_themeModeKey, themeMode.index);
  }

  // Offline Mode Settings

  /// Get offline mode preference
  bool getOfflineMode() {
    return prefs.getBool(_offlineModeKey) ?? false;
  }

  /// Set offline mode preference
  Future<bool> setOfflineMode(bool enabled) async {
    return await prefs.setBool(_offlineModeKey, enabled);
  }

  // Language Settings

  /// Get preferred language
  String getPreferredLanguage() {
    return prefs.getString(_preferredLanguageKey) ?? 'en';
  }

  /// Set preferred language
  Future<bool> setPreferredLanguage(String languageCode) async {
    return await prefs.setString(_preferredLanguageKey, languageCode);
  }

  // Haptic Feedback Settings

  /// Get haptic feedback preference
  bool getEnableHapticFeedback() {
    return prefs.getBool(_enableHapticFeedbackKey) ?? true;
  }

  /// Set haptic feedback preference
  Future<bool> setEnableHapticFeedback(bool enabled) async {
    return await prefs.setBool(_enableHapticFeedbackKey, enabled);
  }

  // Onboarding Settings

  /// Check if onboarding has been completed
  bool isOnboardingCompleted() {
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await prefs.setBool(_onboardingCompletedKey, completed);
  }

  // First Launch Settings

  /// Check if this is the first app launch
  bool isFirstLaunch() {
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  /// Mark first launch as completed
  Future<bool> setFirstLaunchCompleted() async {
    return await prefs.setBool(_firstLaunchKey, false);
  }

  // Utility Methods

  /// Clear all settings (useful for testing or reset functionality)
  Future<bool> clearAllSettings() async {
    return await prefs.clear();
  }

  /// Remove a specific setting
  Future<bool> removeSetting(String key) async {
    return await prefs.remove(key);
  }

  /// Check if a setting exists
  bool hasSetting(String key) {
    return prefs.containsKey(key);
  }

  /// Get all setting keys
  Set<String> getAllKeys() {
    return prefs.getKeys();
  }

  /// Export all settings as a map (useful for backup/restore)
  Map<String, dynamic> exportSettings() {
    final keys = prefs.getKeys();
    final settings = <String, dynamic>{};
    
    for (final key in keys) {
      final value = prefs.get(key);
      settings[key] = value;
    }
    
    return settings;
  }

  /// Import settings from a map (useful for backup/restore)
  Future<void> importSettings(Map<String, dynamic> settings) async {
    for (final entry in settings.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    }
  }
}