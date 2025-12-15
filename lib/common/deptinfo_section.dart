import 'package:flutter/material.dart';
import 'package:staffora/common/app_info_card.dart';
import 'package:staffora/common/chips.dart';
import 'package:staffora/common/info_item.dart';
import 'package:staffora/core/utils/department_color.dart';
import 'package:staffora/core/utils/formatters.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';

class DepartmentSection extends StatelessWidget {
  final String department;
  final EmployeeModelClass? admin;
  final List<EmployeeModelClass> employees;
  final bool isAdmin;
  final bool isSmall;
  final double maxWidth;
  final Function(EmployeeModelClass) onEditEmployee;
  final Function(String?) onDeleteEmployee;

  const DepartmentSection({
    super.key,
    required this.department,
    required this.admin,
    required this.employees,
    required this.isAdmin,
    required this.isSmall,
    required this.maxWidth,
    required this.onEditEmployee,
    required this.onDeleteEmployee,
  });

  @override
  Widget build(BuildContext context) {
    final deptColor = DepartmentColor.fromName(department);
    final deptBg = deptColor.withOpacity(0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Department Header with Admin
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: deptBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: deptColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: deptColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      department,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${employees.length} ${employees.length == 1 ? 'employee' : 'employees'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (admin != null) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: deptColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Department Admin:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: deptColor,
                            child: Text(
                              admin!.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  admin!.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  admin!.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No admin assigned to this department',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Employees Grid
        if (employees.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No employees in this department',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              for (int i = 0; i < employees.length; i++)
                SizedBox(
                  width: isSmall ? maxWidth : (maxWidth - 48) / 3,
                  child: AppInfoCard(
                      title: employees[i].name,
                      subtitle: employees[i].id,
                      avatarText: employees[i].initials,
                      infoItems: [
                        InfoItem(
                            icon: Icons.work_outline, text: employees[i].role),
                        InfoItem(
                            icon: Icons.email_outlined,
                            text: employees[i].email),
                        InfoItem(
                            icon: Icons.phone_in_talk_outlined,
                            text: employees[i].phone),
                        InfoItem(
                          icon: Icons.calendar_today_outlined,
                          text:
                              'Joined ${Formatters.formatDate(employees[i].joined)}',
                        ),
                      ],
                      chip: DepartmentChip(text: employees[i].department),
                      showActions: isAdmin,
                      onEdit: () => onEditEmployee(employees[i]),
                      onDelete: () => onDeleteEmployee(
                            employees[i].id,
                          )

                      // EmployeeCard(
                      //   employee: employees[i],
                      //   isAdmin: isAdmin,
                      //   onEdit: () => onEditEmployee(employees[i]),
                      //   onDelete: () => onDeleteEmployee(employees[i].id),
                      ),
                ),
            ],
          ),
      ],
    );
  }
}

// Color departmentColor(String dept) {
//   switch (dept) {
//     case 'Engineering':
//       return const Color(0xFF2563EB);
//     case 'Marketing':
//       return const Color(0xFFEC4899);
//     case 'Human Resources':
//       return const Color(0xFF22C55E);
//     case 'Sales':
//       return const Color(0xFFF97316);
//     default:
//       return const Color(0xFF6B7280);
//   }
// }
