import 'package:flutter/material.dart';

/// Model class for displaying icon + text info
class InfoItem {
  final IconData icon;
  final String text;

  const InfoItem({
    required this.icon,
    required this.text,
  });
}

/// Reusable row widget for displaying info with icon
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final double iconSize;
  final double textSize;
  final FontWeight fontWeight;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.iconSize = 16,
    this.textSize = 13,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: iconSize,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: fontWeight,
              color: textColor ?? theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}
