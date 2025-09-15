import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_mvp/models/app_settings.dart';

void main() {
  group('AppSettings Model Tests', () {
    late AppSettings testAppSettings;

    setUp(() {
      testAppSettings = AppSettings(
        themeMode: ThemeMode.dark,
        offlineMode: true,
        preferredLanguage: 'es',
        enableHapticFeedback: false,
        enableNotifications: false,
        aiConfidenceThreshold: 0.8,
        maxRecipeHistory: 75,
        maxWorkoutHistory: 150,
      );
    });

    test('should create AppSettings with default values', () {
      final defaultSettings = AppSettings();

      expect(defaultSettings.themeMode, equals(ThemeMode.system));
      expect(defaultSettings.offlineMode, isFalse);
      expect(defaultSettings.preferredLanguage, equals('en'));
      expect(defaultSettings.enableHapticFeedback, isTrue);
      expect(defaultSettings.enableNotifications, isTrue);
      expect(defaultSettings.aiConfidenceThreshold, equals(0.7));
      expect(defaultSettings.maxRecipeHistory, equals(50));
      expect(defaultSettings.maxWorkoutHistory, equals(100));
    });

    test('should create AppSettings with custom values', () {
      expect(testAppSettings.themeMode, equals(ThemeMode.dark));
      expect(testAppSettings.offlineMode, isTrue);
      expect(testAppSettings.preferredLanguage, equals('es'));
      expect(testAppSettings.enableHapticFeedback, isFalse);
      expect(testAppSettings.enableNotifications, isFalse);
      expect(testAppSettings.aiConfidenceThreshold, equals(0.8));
      expect(testAppSettings.maxRecipeHistory, equals(75));
      expect(testAppSettings.maxWorkoutHistory, equals(150));
    });

    test('should create default settings using factory', () {
      final defaultSettings = AppSettings.defaultSettings();

      expect(defaultSettings.themeMode, equals(ThemeMode.system));
      expect(defaultSettings.offlineMode, isFalse);
      expect(defaultSettings.preferredLanguage, equals('en'));
    });

    test('should serialize to JSON correctly', () {
      final json = testAppSettings.toJson();

      expect(json['themeMode'], equals('dark'));
      expect(json['offlineMode'], isTrue);
      expect(json['preferredLanguage'], equals('es'));
      expect(json['enableHapticFeedback'], isFalse);
      expect(json['enableNotifications'], isFalse);
      expect(json['aiConfidenceThreshold'], equals(0.8));
      expect(json['maxRecipeHistory'], equals(75));
      expect(json['maxWorkoutHistory'], equals(150));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'themeMode': 'light',
        'offlineMode': true,
        'preferredLanguage': 'fr',
        'enableHapticFeedback': false,
        'enableNotifications': true,
        'aiConfidenceThreshold': 0.9,
        'maxRecipeHistory': 25,
        'maxWorkoutHistory': 200,
      };

      final appSettings = AppSettings.fromJson(json);

      expect(appSettings.themeMode, equals(ThemeMode.light));
      expect(appSettings.offlineMode, isTrue);
      expect(appSettings.preferredLanguage, equals('fr'));
      expect(appSettings.enableHapticFeedback, isFalse);
      expect(appSettings.enableNotifications, isTrue);
      expect(appSettings.aiConfidenceThreshold, equals(0.9));
      expect(appSettings.maxRecipeHistory, equals(25));
      expect(appSettings.maxWorkoutHistory, equals(200));
    });

    test('should handle missing JSON fields with defaults', () {
      final json = {
        'themeMode': 'dark',
        // Missing other fields
      };

      final appSettings = AppSettings.fromJson(json);

      expect(appSettings.themeMode, equals(ThemeMode.dark));
      expect(appSettings.offlineMode, isFalse); // Default
      expect(appSettings.preferredLanguage, equals('en')); // Default
      expect(appSettings.enableHapticFeedback, isTrue); // Default
    });

    test('should handle invalid theme mode in JSON', () {
      final json = {
        'themeMode': 'invalid_mode',
      };

      final appSettings = AppSettings.fromJson(json);

      expect(appSettings.themeMode, equals(ThemeMode.system)); // Fallback to default
    });

    test('should create copy with modified fields', () {
      final modifiedSettings = testAppSettings.copyWith(
        themeMode: ThemeMode.light,
        preferredLanguage: 'en',
        aiConfidenceThreshold: 0.6,
      );

      expect(modifiedSettings.themeMode, equals(ThemeMode.light));
      expect(modifiedSettings.offlineMode, equals(testAppSettings.offlineMode));
      expect(modifiedSettings.preferredLanguage, equals('en'));
      expect(modifiedSettings.enableHapticFeedback, equals(testAppSettings.enableHapticFeedback));
      expect(modifiedSettings.aiConfidenceThreshold, equals(0.6));
    });

    test('should validate confidence threshold correctly', () {
      final validSettings1 = testAppSettings.copyWith(aiConfidenceThreshold: 0.0);
      final validSettings2 = testAppSettings.copyWith(aiConfidenceThreshold: 1.0);
      final validSettings3 = testAppSettings.copyWith(aiConfidenceThreshold: 0.5);
      final invalidSettings1 = testAppSettings.copyWith(aiConfidenceThreshold: -0.1);
      final invalidSettings2 = testAppSettings.copyWith(aiConfidenceThreshold: 1.1);

      expect(validSettings1.isValidConfidenceThreshold, isTrue);
      expect(validSettings2.isValidConfidenceThreshold, isTrue);
      expect(validSettings3.isValidConfidenceThreshold, isTrue);
      expect(invalidSettings1.isValidConfidenceThreshold, isFalse);
      expect(invalidSettings2.isValidConfidenceThreshold, isFalse);
    });

    test('should validate history limits correctly', () {
      final validSettings = testAppSettings.copyWith(
        maxRecipeHistory: 50,
        maxWorkoutHistory: 100,
      );
      final invalidSettings1 = testAppSettings.copyWith(maxRecipeHistory: 0);
      final invalidSettings2 = testAppSettings.copyWith(maxWorkoutHistory: -1);
      final invalidSettings3 = testAppSettings.copyWith(maxRecipeHistory: 1001);

      expect(validSettings.isValidHistoryLimits, isTrue);
      expect(invalidSettings1.isValidHistoryLimits, isFalse);
      expect(invalidSettings2.isValidHistoryLimits, isFalse);
      expect(invalidSettings3.isValidHistoryLimits, isFalse);
    });

    test('should validate overall settings correctly', () {
      final validSettings = AppSettings(
        aiConfidenceThreshold: 0.7,
        maxRecipeHistory: 50,
        maxWorkoutHistory: 100,
        preferredLanguage: 'en',
      );

      final invalidSettings = AppSettings(
        aiConfidenceThreshold: 1.5, // Invalid
        maxRecipeHistory: 50,
        maxWorkoutHistory: 100,
        preferredLanguage: 'en',
      );

      final emptyLanguageSettings = AppSettings(
        preferredLanguage: '', // Invalid
      );

      expect(validSettings.isValid, isTrue);
      expect(invalidSettings.isValid, isFalse);
      expect(emptyLanguageSettings.isValid, isFalse);
    });

    test('should provide theme mode helpers', () {
      final darkSettings = testAppSettings.copyWith(themeMode: ThemeMode.dark);
      final lightSettings = testAppSettings.copyWith(themeMode: ThemeMode.light);
      final systemSettings = testAppSettings.copyWith(themeMode: ThemeMode.system);

      expect(darkSettings.isDarkMode, isTrue);
      expect(darkSettings.isLightMode, isFalse);
      expect(darkSettings.isSystemMode, isFalse);

      expect(lightSettings.isDarkMode, isFalse);
      expect(lightSettings.isLightMode, isTrue);
      expect(lightSettings.isSystemMode, isFalse);

      expect(systemSettings.isDarkMode, isFalse);
      expect(systemSettings.isLightMode, isFalse);
      expect(systemSettings.isSystemMode, isTrue);
    });

    test('should implement equality correctly', () {
      final settings1 = AppSettings(
        themeMode: ThemeMode.dark,
        offlineMode: true,
        preferredLanguage: 'en',
      );

      final settings2 = AppSettings(
        themeMode: ThemeMode.dark,
        offlineMode: true,
        preferredLanguage: 'en',
      );

      final settings3 = settings1.copyWith(themeMode: ThemeMode.light);

      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('should have proper toString implementation', () {
      final string = testAppSettings.toString();
      expect(string, contains('dark'));
      expect(string, contains('true')); // offline mode
      expect(string, contains('es'));
    });

    test('should validate JSON round-trip', () {
      final json = testAppSettings.toJson();
      final deserializedSettings = AppSettings.fromJson(json);
      final reserializedJson = deserializedSettings.toJson();

      expect(json, equals(reserializedJson));
      expect(testAppSettings, equals(deserializedSettings));
    });
  });
}