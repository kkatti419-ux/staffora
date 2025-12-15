import 'package:flutter/material.dart';
import 'package:staffora/common/chip_group.dart';
import 'package:staffora/common/icon_action_button.dart';
import 'package:staffora/common/initial_avatar.dart';
import 'package:staffora/common/submit_or_cancel.dart';
import 'package:staffora/core/utils/formatters.dart';
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
    final theme = Theme.of(context);

    return Material(
      // elevation: 5,
      borderRadius: BorderRadius.circular(18),
      // color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          // padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(18),
            // border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.05),
            //     blurRadius: 14,
            //     offset: const Offset(0, 6),
            //   ),
            // ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧑‍💼 Top Section (Avatar + Name + ID)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InitialAvatar(
                    name: employee.firstname,
                    radius: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.firstname ?? "N/A",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.uniqueId,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 🏢 Role
              _employeeInfoRow(
                icon: Icons.work_outline_rounded,
                text: employee.role,
                theme: theme,
              ),

              const SizedBox(height: 8),

              // 🟣 Department
              // 🟣 Department
              ChipGroup(
                items: employee.dept != null ? [employee.dept!] : ["N/A"],
                textColor: theme.colorScheme.primary,
              ),

              const SizedBox(height: 12),

              // ✉ Email
              _employeeInfoRow(
                icon: Icons.email_outlined,
                text: employee.companyEmail ?? employee.personalEmail,
                theme: theme,
              ),

              const SizedBox(height: 8),

              // 📞 Phone
              _employeeInfoRow(
                icon: Icons.phone_outlined,
                text: employee.phone,
                theme: theme,
              ),

              const SizedBox(height: 8),

              // 📅 Joined
              _employeeInfoRow(
                icon: Icons.calendar_today_outlined,
                text: "Joined ${Formatters.formatDate(employee.joinDate)}",
                theme: theme,
              ),

              const SizedBox(height: 16),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 12),

              // 🟦 Bottom Buttons
              Row(
                children: [
                  Expanded(
                      child: SubmitButton(
                    label: "Edit",
                    onSubmit: onEdit,
                  )),
                  const SizedBox(width: 10),
                  IconActionButton(
                    icon: Icons.delete_outline,
                    onPressed: onDelete,
                    iconColor: Colors.red,
                    background: const Color(0xFFFFF1F2),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _employeeInfoRow({
  required IconData icon,
  required String? text,
  required ThemeData theme,
}) {
  return Row(
    children: [
      Icon(icon, size: 18, color: theme.colorScheme.primary.withOpacity(0.7)),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text ?? "N/A",
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
      ),
    ],
  );
}
