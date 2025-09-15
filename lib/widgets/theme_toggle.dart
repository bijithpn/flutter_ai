import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Widget for toggling between light and dark themes
class ThemeToggle extends StatelessWidget {
  final bool showLabel;
  final MainAxisAlignment alignment;

  const ThemeToggle({
    super.key,
    this.showLabel = true,
    this.alignment = MainAxisAlignment.spaceBetween,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Row(
          mainAxisAlignment: alignment,
          children: [
            if (showLabel) ...[
              Icon(
                themeProvider.isDarkMode 
                    ? Icons.dark_mode 
                    : Icons.light_mode,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Text(
                'Dark Mode',
                style: theme.textTheme.bodyLarge,
              ),
            ],
            Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ],
        );
      },
    );
  }
}

/// Advanced theme selector with system option
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              title: 'Light',
              subtitle: 'Always use light theme',
              icon: Icons.light_mode,
              isSelected: themeProvider.themeMode == ThemeMode.light,
              onTap: () => themeProvider.setLightTheme(),
            ),
            _ThemeOption(
              title: 'Dark',
              subtitle: 'Always use dark theme',
              icon: Icons.dark_mode,
              isSelected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () => themeProvider.setDarkTheme(),
            ),
            _ThemeOption(
              title: 'System',
              subtitle: 'Follow system setting',
              icon: Icons.settings_system_daydream,
              isSelected: themeProvider.themeMode == ThemeMode.system,
              onTap: () => themeProvider.setSystemTheme(),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: isSelected 
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}