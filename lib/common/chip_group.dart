import 'package:flutter/material.dart';

class ChipGroup extends StatelessWidget {
  final List<String> items;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const ChipGroup({
    super.key,
    required this.items,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((text) {
        return _BeautifulChip(
          text: text,
          background: backgroundColor ?? theme.colorScheme.surfaceVariant,
          color: textColor ?? theme.colorScheme.primary,
          padding: padding,
        );
      }).toList(),
    );
  }
}

class _BeautifulChip extends StatelessWidget {
  final String text;
  final Color background;
  final Color color;
  final EdgeInsetsGeometry? padding;

  const _BeautifulChip({
    required this.text,
    required this.background,
    required this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: background.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: background.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
