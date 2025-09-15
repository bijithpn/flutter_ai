import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_ai_mvp/main.dart';
import 'package:flutter_ai_mvp/providers/theme_provider.dart';
import 'package:flutter_ai_mvp/theme/app_theme.dart';
import 'package:flutter_ai_mvp/widgets/theme_toggle.dart';

void main() {
  group('Theme System Tests', () {
    setUp(() {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App should start with system theme mode', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterAIMVPApp());
      await tester.pumpAndSettle();

      // App should render without errors
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('ThemeToggle should display correctly', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: themeProvider,
            child: const Scaffold(
              body: ThemeToggle(),
            ),
          ),
        ),
      );

      // Should find the switch widget
      expect(find.byType(Switch), findsOneWidget);
      
      // Should find the dark mode text
      expect(find.text('Dark Mode'), findsOneWidget);
      
      // Should find the light mode icon initially
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('ThemeToggle should toggle theme when tapped', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      await themeProvider.setLightTheme(); // Start with light theme
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: themeProvider,
            child: const Scaffold(
              body: ThemeToggle(),
            ),
          ),
        ),
      );

      // Initially should be light mode
      expect(themeProvider.themeMode, ThemeMode.light);
      
      // Tap the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Should now be dark mode
      expect(themeProvider.themeMode, ThemeMode.dark);
      
      // Should show dark mode icon
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('ThemeSelector should display all theme options', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: themeProvider,
            child: const Scaffold(
              body: ThemeSelector(),
            ),
          ),
        ),
      );

      // Should find all three theme options
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      
      // Should find the theme icons
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      expect(find.byIcon(Icons.settings_system_daydream), findsOneWidget);
    });

    testWidgets('ThemeSelector should select light theme when tapped', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: themeProvider,
            child: const Scaffold(
              body: ThemeSelector(),
            ),
          ),
        ),
      );

      // Tap on light theme option
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      // Should be light mode
      expect(themeProvider.themeMode, ThemeMode.light);
    });

    testWidgets('ThemeSelector should select dark theme when tapped', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: themeProvider,
            child: const Scaffold(
              body: ThemeSelector(),
            ),
          ),
        ),
      );

      // Tap on dark theme option
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Should be dark mode
      expect(themeProvider.themeMode, ThemeMode.dark);
    });

    testWidgets('App should use correct theme data', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterAIMVPApp());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Should use Material 3
      expect(materialApp.theme?.useMaterial3, true);
      expect(materialApp.darkTheme?.useMaterial3, true);
    });

    testWidgets('Navigation bar should use Material 3 icons', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterAIMVPApp());
      await tester.pumpAndSettle();

      // Should find navigation bar with destinations
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Recipes'), findsOneWidget);
      expect(find.text('Trainer'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Settings screen should contain theme selector', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterAIMVPApp());
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Should find theme selector
      expect(find.byType(ThemeSelector), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });
  });

  group('ThemeProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeProvider should initialize with system theme', () {
      final provider = ThemeProvider();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('ThemeProvider should toggle between light and dark', () async {
      final provider = ThemeProvider();
      
      // Set to light first
      await provider.setLightTheme();
      expect(provider.themeMode, ThemeMode.light);
      
      // Toggle should go to dark
      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.dark);
      
      // Toggle again should go to light
      await provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
    });

    test('ThemeProvider should set specific theme modes', () async {
      final provider = ThemeProvider();
      
      await provider.setDarkTheme();
      expect(provider.themeMode, ThemeMode.dark);
      
      await provider.setLightTheme();
      expect(provider.themeMode, ThemeMode.light);
      
      await provider.setSystemTheme();
      expect(provider.themeMode, ThemeMode.system);
    });

    test('ThemeProvider should provide correct display names', () {
      final provider = ThemeProvider();
      
      provider.setLightTheme();
      expect(provider.themeModeDisplayName, 'Light');
      
      provider.setDarkTheme();
      expect(provider.themeModeDisplayName, 'Dark');
      
      provider.setSystemTheme();
      expect(provider.themeModeDisplayName, 'System');
    });

    test('isDarkMode should return correct values', () async {
      final provider = ThemeProvider();
      
      await provider.setLightTheme();
      expect(provider.isDarkMode, false);
      
      await provider.setDarkTheme();
      expect(provider.isDarkMode, true);
      
      await provider.setSystemTheme();
      expect(provider.isDarkMode, false); // Default for system in tests
    });
  });

  group('AppTheme Tests', () {
    test('AppTheme should provide Material 3 themes', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;
      
      // Should use Material 3
      expect(lightTheme.useMaterial3, true);
      expect(darkTheme.useMaterial3, true);
      
      // Should have different brightness
      expect(lightTheme.colorScheme.brightness, Brightness.light);
      expect(darkTheme.colorScheme.brightness, Brightness.dark);
    });

    test('AppTheme should have consistent component themes', () {
      final lightTheme = AppTheme.lightTheme;
      
      // Should have custom app bar theme
      expect(lightTheme.appBarTheme.centerTitle, true);
      expect(lightTheme.appBarTheme.elevation, 0);
      
      // Should have custom card theme
      expect(lightTheme.cardTheme.elevation, 1);
      
      // Should have custom button themes
      expect(lightTheme.elevatedButtonTheme.style, isNotNull);
      expect(lightTheme.filledButtonTheme.style, isNotNull);
      expect(lightTheme.outlinedButtonTheme.style, isNotNull);
    });
  });
}