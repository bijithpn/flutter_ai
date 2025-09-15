import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing theme state and persistence
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Whether the current theme is dark
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        // This will be handled by the system, but we default to light for logic
        return false;
    }
  }
  
  /// Initialize theme from stored preferences
  Future<void> initializeTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedThemeIndex = prefs.getInt(_themeKey);
      
      if (storedThemeIndex != null) {
        _themeMode = ThemeMode.values[storedThemeIndex];
        notifyListeners();
      }
    } catch (e) {
      // If there's an error loading preferences, use system default
      _themeMode = ThemeMode.system;
    }
  }
  
  /// Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeMode.index);
    } catch (e) {
      // Handle storage error gracefully
      debugPrint('Failed to save theme preference: $e');
    }
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newTheme = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newTheme);
  }
  
  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }
  
  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  /// Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
  
  /// Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}