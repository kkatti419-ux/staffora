import 'package:flutter/material.dart';

class DepartmentColor {
  DepartmentColor._(); // prevents instantiation

  static const Map<String, Color> _colors = {
    'Engineering': Color(0xFF2563EB),
    'Marketing': Color(0xFFEC4899),
    'Human Resources': Color(0xFF22C55E),
    'Sales': Color(0xFFF97316),
  };

  static Color fromName(String? department) {
    if (department == null || department.isEmpty) {
      return const Color(0xFF6B7280);
    }

    return _colors[department] ?? const Color(0xFF6B7280);
  }
}
