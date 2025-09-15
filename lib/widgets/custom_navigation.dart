import 'package:flutter/material.dart';

/// Custom Material 3 navigation bar
class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;
  final double? height;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: height ?? 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: height ?? 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

/// Custom Material 3 navigation destination
class CustomNavigationDestination extends NavigationDestination {
  const CustomNavigationDestination({
    super.key,
    required super.icon,
    required super.label,
    super.selectedIcon,
    super.tooltip,
  });

  /// Factory constructor for common navigation items
  factory CustomNavigationDestination.recipes({
    bool selected = false,
  }) {
    return CustomNavigationDestination(
      icon: const Icon(Icons.restaurant_menu_outlined),
      selectedIcon: const Icon(Icons.restaurant_menu),
      label: 'Recipes',
      tooltip: 'AI Recipe Generator',
    );
  }

  factory CustomNavigationDestination.trainer({
    bool selected = false,
  }) {
    return CustomNavigationDestination(
      icon: const Icon(Icons.fitness_center_outlined),
      selectedIcon: const Icon(Icons.fitness_center),
      label: 'Trainer',
      tooltip: 'AI Personal Trainer',
    );
  }

  factory CustomNavigationDestination.notes({
    bool selected = false,
  }) {
    return CustomNavigationDestination(
      icon: const Icon(Icons.note_outlined),
      selectedIcon: const Icon(Icons.note),
      label: 'Notes',
      tooltip: 'AI Note Summarizer',
    );
  }

  factory CustomNavigationDestination.settings({
    bool selected = false,
  }) {
    return CustomNavigationDestination(
      icon: const Icon(Icons.settings_outlined),
      selectedIcon: const Icon(Icons.settings),
      label: 'Settings',
      tooltip: 'App Settings',
    );
  }
}

/// Custom Material 3 app bar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 1,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      actions: actions,
      leading: leading,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

/// Custom Material 3 drawer
class CustomDrawer extends StatelessWidget {
  final Widget? header;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const CustomDrawer({
    super.key,
    this.header,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView(
              padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Material 3 drawer header
class CustomDrawerHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const CustomDrawerHeader({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DrawerHeader(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primaryContainer,
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}