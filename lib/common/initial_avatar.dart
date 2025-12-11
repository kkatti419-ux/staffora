import 'package:flutter/material.dart';

class InitialAvatar extends StatelessWidget {
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final FontWeight fontWeight;
  final double? fontSize;

  const InitialAvatar({
    super.key,
    required this.name,
    this.radius = 26,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontWeight = FontWeight.w700,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Extract first letter or show ?
    final initial = (name != null && name!.isNotEmpty)
        ? name!.trim()[0].toUpperCase()
        : "?";

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? theme.colorScheme.primary.withOpacity(0.9),
      child: Text(
        initial,
        style: TextStyle(
          color: textColor,
          fontWeight: fontWeight,
          fontSize: fontSize ?? (radius * 0.8),
        ),
      ),
    );
  }
}
