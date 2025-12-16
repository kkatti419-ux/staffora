import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:staffora/common/app_info_card.dart';
import 'package:staffora/common/chips.dart';
import 'package:staffora/common/emp_dilouge_state.dart';
import 'package:staffora/common/info_item.dart';
import 'package:staffora/common/primary_button.dart';
import 'package:staffora/core/utils/formatters.dart';
import 'package:staffora/data/firebase_services/firebase_employee_service.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final FirebaseEmployeeService _firebaseEmployeeService =
      FirebaseEmployeeService();

  String? _currentUserRole;
  String? _currentUserId;
  bool _isLoading = true;

  /// Toggle to show assigned/unassigned (admin only)
  bool _showUnassigned = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // ================= LOAD CURRENT USER =================
  Future<void> _loadCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      _currentUserId = user.uid;

      final employee =
          await _firebaseEmployeeService.fetchEmployeeByUserId(user.uid);

      setState(() {
        _currentUserRole = employee?.role;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ================= ROLE CHECK =================
  bool get _isAdmin => _currentUserRole?.toLowerCase() == 'admin';

  // ================= STREAM DECISION (KEY PART) =================
  Stream<List<EmployeeModelClass>> _employeeStream() {
    if (_isAdmin) {
      // Admin → all employees
      return _firebaseEmployeeService.employeeStream();
    } else {
      // User → only their own employee data
      return _firebaseEmployeeService.employeeStreamByUserId(_currentUserId!);
    }
  }

  // ================= ACTIONS =================
  Future<void> _openAddDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmployeeDialog(
        isEdit: false,
        employeeId: null,
        initialEmployee: null,
      ),
    );
  }

  Future<void> _openEditDialog(EmployeeModelClass employee) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmployeeDialog(
        isEdit: true,
        employeeId: employee.id,
        initialEmployee: employee,
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER =================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Employees',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _showUnassigned
                                ? 'Showing unassigned employees'
                                : 'Showing assigned employees',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Toggle only for admin
                    if (_isAdmin)
                      Row(
                        children: [
                          Text(
                            _showUnassigned
                                ? 'Show Unassigned'
                                : 'Show Assigned',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Switch(
                            value: _showUnassigned,
                            onChanged: (v) =>
                                setState(() => _showUnassigned = v),
                          ),
                        ],
                      ),

                    const SizedBox(width: 12),
                    if (_isAdmin)
                      Row(
                        children: [
                          PrimaryButton(
                            text: 'Add Employee',
                            icon: Icons.add,
                            onPressed: _openAddDialog,
                          ),
                          const SizedBox(width: 12),
                          PrimaryButton(
                            text: 'Manage Departments',
                            icon: Icons.business,
                            onPressed: () {
                              if (context.mounted) {
                                context.go('/department/management');
                              }
                            },
                          ),
                        ],
                      )
                  ],
                ),

                const SizedBox(height: 24),

                // ================= EMPLOYEE LIST =================
                StreamBuilder<List<EmployeeModelClass>>(
                  stream: _employeeStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final employees = snapshot.data ?? [];

                    // Filter assigned / unassigned (admin only)
                    final filteredEmployees = !_isAdmin
                        ? employees
                        : employees.where((e) {
                            final hasDept = e.department.isNotEmpty &&
                                e.department != 'Unassigned';
                            return _showUnassigned ? !hasDept : hasDept;
                          }).toList();

                    if (filteredEmployees.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            'No employees found',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: filteredEmployees.map((employee) {
                        return SizedBox(
                          width: 350,
                          child: AppInfoCard(
                            title: employee.name,
                            subtitle: employee.id,
                            avatarText: employee.initials,
                            infoItems: [
                              InfoItem(
                                icon: Icons.work_outline,
                                text: employee.role,
                              ),
                              InfoItem(
                                icon: Icons.email_outlined,
                                text: employee.email,
                              ),
                              InfoItem(
                                icon: Icons.phone_in_talk_outlined,
                                text: employee.phone,
                              ),
                              InfoItem(
                                icon: Icons.calendar_today_outlined,
                                text:
                                    'Joined ${Formatters.formatDate(employee.joined)}',
                              ),
                            ],
                            chip: DepartmentChip(
                              text: employee.department.isNotEmpty
                                  ? employee.department
                                  : 'Unassigned',
                            ),
                            showActions: _isAdmin,
                            onEdit: () => _openEditDialog(employee),
                            onDelete: () async {
                              if (employee.id != null) {
                                await _firebaseEmployeeService
                                    .deleteEmployee(employee.id!);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
