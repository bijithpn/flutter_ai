import 'package:flutter/material.dart';

/// AppTheme class that provides Material 3 light and dark themes
class AppTheme {
  // Primary seed color for Material 3 color scheme generation
  static const Color _seedColor = Color(0xFF6750A4); // Material 3 default purple
  
  // Generate color schemes from seed color
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  );
  
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  );

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _lightColorScheme.surface,
        foregroundColor: _lightColorScheme.onSurface,
        surfaceTintColor: _lightColorScheme.surfaceTint,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: _lightColorScheme.surfaceContainerLow,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _lightColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _lightColorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _lightColorScheme.error,
            width: 2,
          ),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _lightColorScheme.surface,
        selectedItemColor: _lightColorScheme.primary,
        unselectedItemColor: _lightColorScheme.onSurfaceVariant,
        elevation: 3,
      ),
      
      // Navigation Bar Theme (Material 3 style)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightColorScheme.surface,
        indicatorColor: _lightColorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: _lightColorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
          }
          return TextStyle(
            color: _lightColorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          );
        }),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _lightColorScheme.surfaceContainerLow,
        selectedColor: _lightColorScheme.secondaryContainer,
        deleteIconColor: _lightColorScheme.onSurfaceVariant,
        labelStyle: TextStyle(color: _lightColorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _darkColorScheme.surface,
        foregroundColor: _darkColorScheme.onSurface,
        surfaceTintColor: _darkColorScheme.surfaceTint,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: _darkColorScheme.surfaceContainerLow,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _darkColorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _darkColorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _darkColorScheme.error,
            width: 2,
          ),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _darkColorScheme.surface,
        selectedItemColor: _darkColorScheme.primary,
        unselectedItemColor: _darkColorScheme.onSurfaceVariant,
        elevation: 3,
      ),
      
      // Navigation Bar Theme (Material 3 style)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkColorScheme.surface,
        indicatorColor: _darkColorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: _darkColorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
          }
          return TextStyle(
            color: _darkColorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          );
        }),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _darkColorScheme.surfaceContainerLow,
        selectedColor: _darkColorScheme.secondaryContainer,
        deleteIconColor: _darkColorScheme.onSurfaceVariant,
        labelStyle: TextStyle(color: _darkColorScheme.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}