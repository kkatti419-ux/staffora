import 'package:flutter/material.dart';
import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool? isAdmin;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
    this.isAdmin,
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
            // Top Section (Avatar + Name + ID)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF7C3AED),
                  child: Text(
                    employee.firstname != null && employee.firstname!.isNotEmpty
                        ? employee.firstname![0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.firstname ?? "N/A",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        employee.uniqueId ?? employee.userId,
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

            // Role
            _employeeInfoRow(
              icon: Icons.work_outline,
              text: employee.role,
            ),

            const SizedBox(height: 8),

            // Department chip
            DepartmentChip(text: employee.dept),

            const SizedBox(height: 12),

            // Email
            _employeeInfoRow(
              icon: Icons.email_outlined,
              text: employee.companyEmail ?? employee.personalEmail,
            ),

            const SizedBox(height: 6),

            // Phone
            _employeeInfoRow(
              icon: Icons.phone_in_talk_outlined,
              text: employee.phone,
            ),

            const SizedBox(height: 6),

            // Join date
            _employeeInfoRow(
              icon: Icons.calendar_today_outlined,
              text: "Joined ${formatDate(employee.joinDate)}",
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Bottom Buttons
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
        ),
      ),
    );
  }
}

Widget _employeeInfoRow({required IconData icon, required String? text}) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey.shade600),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text ?? "N/A",
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
      ),
    ],
  );
}

class DepartmentChip extends StatelessWidget {
  final String? text;

  const DepartmentChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text ?? "No Dept",
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF7C3AED),
        ),
      ),
    );
  }
}

String formatDate(DateTime? date) {
  if (date == null) return "N/A";
  return "${date.day}/${date.month}/${date.year}";
}
