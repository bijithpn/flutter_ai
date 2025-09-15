import 'package:flutter/material.dart';

/// Custom Material 3 elevated button with enhanced styling
class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.padding,
    this.minimumSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: minimumSize ?? const Size(120, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 2,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Custom Material 3 filled button
class CustomFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;

  const CustomFilledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(120, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Custom Material 3 outlined button
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(120, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Custom floating action button with Material 3 styling
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;

  const CustomFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        elevation: 3,
        icon: Icon(icon),
        label: Text(
          label!,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.onPrimaryContainer,
      elevation: 3,
      child: Icon(icon),
    );
  }
}