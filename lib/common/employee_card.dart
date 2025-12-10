import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';
import 'package:staffora/presentation/employee/views/employee.dart';

class EmployeeCard extends StatelessWidget {
  final EmployeeModelClass employee;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.isAdmin,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF7C3AED),
                  child: Text(
                    employee.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        employee.id ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            _EmployeeInfoRow(
              icon: Icons.work_outline,
              text: employee.role,
            ),
            const SizedBox(height: 8),
            DepartmentChip(text: employee.department),
            const SizedBox(height: 12),
            _EmployeeInfoRow(
              icon: Icons.email_outlined,
              text: employee.email,
            ),
            const SizedBox(height: 6),
            _EmployeeInfoRow(
              icon: Icons.phone_in_talk_outlined,
              text: employee.phone,
            ),
            const SizedBox(height: 6),
            _EmployeeInfoRow(
              icon: Icons.calendar_today_outlined,
              text: 'Joined ${formatDate(employee.joined)}',
            ),
            if (isAdmin) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4C4CFF),
                          backgroundColor: const Color(0xFFF5F3FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 40,
                    width: 44,
                    child: TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF1F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmployeeInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmployeeInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

class DepartmentChip extends StatelessWidget {
  final String text;

  const DepartmentChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final color = departmentColor(text);
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
