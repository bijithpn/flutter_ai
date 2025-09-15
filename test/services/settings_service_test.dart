import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ai_mvp/services/services.dart';

void main() {
  group('SettingsService Tests', () {
    late SettingsService settingsService;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      settingsService = SettingsService();
      await settingsService.init();
    });

    test('should initialize successfully', () async {
      expect(settingsService.prefs, isNotNull);
    });

    test('should throw error when not initialized', () {
      final uninitializedService = SettingsService();
      expect(() => uninitializedService.prefs, throwsStateError);
    });

    group('Theme Settings', () {
      test('should get default theme mode as system', () {
        final themeMode = settingsService.getThemeMode();
        expect(themeMode, equals(ThemeMode.system));
      });

      test('should set and get theme mode', () async {
        await settingsService.setThemeMode(ThemeMode.dark);
        final themeMode = settingsService.getThemeMode();
        expect(themeMode, equals(ThemeMode.dark));
      });

      test('should persist theme mode across service instances', () async {
        await settingsService.setThemeMode(ThemeMode.light);
        
        // Create new service instance
        final newService = SettingsService();
        await newService.init();
        
        expect(newService.getThemeMode(), equals(ThemeMode.light));
      });
    });

    group('Offline Mode Settings', () {
      test('should get default offline mode as false', () {
        expect(settingsService.getOfflineMode(), isFalse);
      });

      test('should set and get offline mode', () async {
        await settingsService.setOfflineMode(true);
        expect(settingsService.getOfflineMode(), isTrue);
      });
    });

    group('Language Settings', () {
      test('should get default language as en', () {
        expect(settingsService.getPreferredLanguage(), equals('en'));
      });

      test('should set and get preferred language', () async {
        await settingsService.setPreferredLanguage('es');
        expect(settingsService.getPreferredLanguage(), equals('es'));
      });
    });

    group('Haptic Feedback Settings', () {
      test('should get default haptic feedback as true', () {
        expect(settingsService.getEnableHapticFeedback(), isTrue);
      });

      test('should set and get haptic feedback preference', () async {
        await settingsService.setEnableHapticFeedback(false);
        expect(settingsService.getEnableHapticFeedback(), isFalse);
      });
    });

    group('Onboarding Settings', () {
      test('should get default onboarding completed as false', () {
        expect(settingsService.isOnboardingCompleted(), isFalse);
      });

      test('should set and get onboarding completion', () async {
        await settingsService.setOnboardingCompleted(true);
        expect(settingsService.isOnboardingCompleted(), isTrue);
      });
    });

    group('First Launch Settings', () {
      test('should get default first launch as true', () {
        expect(settingsService.isFirstLaunch(), isTrue);
      });

      test('should mark first launch as completed', () async {
        await settingsService.setFirstLaunchCompleted();
        expect(settingsService.isFirstLaunch(), isFalse);
      });
    });

    group('Utility Methods', () {
      test('should clear all settings', () async {
        await settingsService.setThemeMode(ThemeMode.dark);
        await settingsService.setOfflineMode(true);
        
        await settingsService.clearAllSettings();
        
        expect(settingsService.getThemeMode(), equals(ThemeMode.system));
        expect(settingsService.getOfflineMode(), isFalse);
      });

      test('should check if setting exists', () async {
        expect(settingsService.hasSetting('theme_mode'), isFalse);
        
        await settingsService.setThemeMode(ThemeMode.dark);
        expect(settingsService.hasSetting('theme_mode'), isTrue);
      });

      test('should export and import settings', () async {
        // Set some settings
        await settingsService.setThemeMode(ThemeMode.dark);
        await settingsService.setOfflineMode(true);
        await settingsService.setPreferredLanguage('es');
        
        // Export settings
        final exported = settingsService.exportSettings();
        expect(exported, isNotEmpty);
        
        // Clear settings
        await settingsService.clearAllSettings();
        
        // Import settings
        await settingsService.importSettings(exported);
        
        // Verify imported settings
        expect(settingsService.getThemeMode(), equals(ThemeMode.dark));
        expect(settingsService.getOfflineMode(), isTrue);
        expect(settingsService.getPreferredLanguage(), equals('es'));
      });

      test('should get all keys', () async {
        await settingsService.setThemeMode(ThemeMode.dark);
        await settingsService.setOfflineMode(true);
        
        final keys = settingsService.getAllKeys();
        expect(keys, contains('theme_mode'));
        expect(keys, contains('offline_mode'));
      });

      test('should remove specific setting', () async {
        await settingsService.setThemeMode(ThemeMode.dark);
        expect(settingsService.hasSetting('theme_mode'), isTrue);
        
        await settingsService.removeSetting('theme_mode');
        expect(settingsService.hasSetting('theme_mode'), isFalse);
      });
    });
  });
}