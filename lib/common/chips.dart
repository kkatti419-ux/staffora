import 'package:flutter/material.dart';
import 'package:staffora/core/utils/department_color.dart';

class DepartmentChip extends StatelessWidget {
  final String text;

  const DepartmentChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final color = DepartmentColor.fromName(text);
    final bg = color.withOpacity(0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
