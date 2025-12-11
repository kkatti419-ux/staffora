import 'package:flutter/material.dart';

class IconActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? iconColor;
  final Color? background;
  final double size;
  final double radius;
  final String? tooltip;

  const IconActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconColor,
    this.background,
    this.size = 42,
    this.radius = 10,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final btn = SizedBox(
      height: size,
      width: size,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background ?? theme.colorScheme.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.45,
          color: iconColor ?? theme.colorScheme.primary,
        ),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}
