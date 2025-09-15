import 'package:flutter/material.dart';

/// Custom Material 3 card with enhanced styling
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: Card(
        elevation: elevation ?? 1,
        color: backgroundColor ?? theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Custom Material 3 elevated card
class CustomElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? elevation;

  const CustomElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: Card(
        elevation: elevation ?? 3,
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Custom Material 3 outlined card
class CustomOutlinedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;

  const CustomOutlinedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: borderColor ?? theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Custom Material 3 filled card
class CustomFilledCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const CustomFilledCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}