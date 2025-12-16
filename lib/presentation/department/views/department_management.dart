import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:staffora/common/app_info_card.dart';
import 'package:staffora/common/confirm_dilouge.dart';
import 'package:staffora/common/department_dilouge.dart';
import 'package:staffora/common/info_item.dart';
import 'package:staffora/common/primary_button.dart';
import 'package:staffora/core/utils/formatters.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/data/models/firebase_model/department/department_model.dart';
import 'package:staffora/data/firebase_services/firebase_employee_service.dart';

class DepartmentManagementScreen extends StatefulWidget {
  const DepartmentManagementScreen({super.key});

  @override
  State<DepartmentManagementScreen> createState() =>
      _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState
    extends State<DepartmentManagementScreen> {
  final _firebaseEmployeeService = FirebaseEmployeeService();

  @override
  void initState() {
    super.initState();
    AppLogger.debug('DepartmentManagementScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Department Management',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StreamBuilder<List<DepartmentModel>>(
                                  stream: _firebaseEmployeeService
                                      .departmentsStream(),
                                  builder: (context, snapshot) {
                                    final count = snapshot.data?.length ?? 0;
                                    return Text(
                                      'Manage $count departments',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          PrimaryButton(
                            text: 'Add Department',
                            icon: Icons.add,
                            onPressed: () => _openAddDialog(null),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// DEPARTMENTS LIST
                      StreamBuilder<List<DepartmentModel>>(
                        stream: _firebaseEmployeeService.departmentsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error loading departments',
                                style: TextStyle(color: Colors.red.shade400),
                              ),
                            );
                          }

                          final departments = snapshot.data ?? [];

                          if (departments.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Text(
                                  'No departments found. Create your first department!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmall = constraints.maxWidth < 700;

                              return Wrap(
                                spacing: 24,
                                runSpacing: 24,
                                children: departments.map((department) {
                                  return SizedBox(
                                    width: isSmall
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 48) / 3,
                                    child: AppInfoCard(
                                      title: department.name,
                                      subtitle: department.adminName != null
                                          ? 'Admin: ${department.adminName}'
                                          : 'No admin assigned',
                                      avatarText: department
                                          .name.characters.first
                                          .toUpperCase(),
                                      avatarColor: const Color(0xFF2563EB),
                                      infoItems: [
                                        if (department.description != null)
                                          InfoItem(
                                            icon: Icons.description_outlined,
                                            text: department.description!,
                                          ),
                                        InfoItem(
                                          icon: Icons.calendar_today_outlined,
                                          text:
                                              'Created ${Formatters.formatDate(department.createdAt)}',
                                        ),
                                      ],
                                      showActions: true,
                                      onEdit: () => _openAddDialog(department),
                                      onDelete: () =>
                                          _showDeleteDialog(department),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ADD / EDIT
  Future<void> _openAddDialog(DepartmentModel? department) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DepartmentDialog(
        department: department,
        firebaseEmployeeService: _firebaseEmployeeService,
      ),
    );
  }

  /// DELETE CONFIRM
  void _showDeleteDialog(DepartmentModel department) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: "Delete Department",
        message:
            'Are you sure you want to delete "${department.name}"?\nEmployees will be moved to "Unassigned".',
        confirmText: "Delete",
        cancelText: "Cancel",
        confirmColor: Colors.red,
        cancelColor: Colors.grey,
        onConfirm: () async {
          // Delay the delete until after Navigator finishes popping

          await _deleteDepartment(department.id, department.name);
        },
      ),
    );
  }

  /// DELETE ACTION
  Future<void> _deleteDepartment(
    String departmentId,
    String departmentName,
  ) async {
    log(departmentId);
    log(departmentName);

    try {
      await _firebaseEmployeeService.deleteDepartment(departmentId);
      AppLogger.debug('Department deleted: $departmentName');
    } catch (e, stack) {
      AppLogger.error('Error deleting department', e, stackTrace: stack);
    }
  }
}
