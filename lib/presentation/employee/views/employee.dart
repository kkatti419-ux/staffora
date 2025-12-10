import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staffora/common/primary_button.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/data/firebase_services/firebase_employee_service.dart';
import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';
import 'package:staffora/presentation/employee/views/addor_edit_employee.dart';
import 'package:staffora/presentation/employee/views/employee_card.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final FirebaseEmployeeService _employeeService = FirebaseEmployeeService();

  String? _currentUserId;
  bool _isAdmin = false;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // Load logged in user & role
  Future<void> _loadUserRole() async {
    try {
      _currentUserId = FirebaseAuth.instance.currentUser?.uid;

      if (_currentUserId == null) {
        setState(() => _loadingRole = false);
        return;
      }

      final employee =
          await _employeeService.fetchEmployeeByUserId(_currentUserId!);

      _isAdmin = (employee?.role?.toLowerCase() == "admin");

      AppLogger.debug("Logged user role: ${employee?.role}");

      setState(() => _loadingRole = false);
    } catch (e, st) {
      AppLogger.error("Failed loading role", error: e, stackTrace: st);
      setState(() => _loadingRole = false);
    }
  }

  Future<void> _openEditDialog(Employee employee) async {
    await showDialog(
      context: context,
      builder: (_) => EmployeeDialog(
        isEdit: true,
        employeeId: employee.userId, // OR employee.id based on your DB
        initialEmployee: employee, // Prefill form
      ),
    );
    setState(() {}); // Refresh UI after save
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingRole) {
      return const Center(child: CircularProgressIndicator());
    }

    // decide which future to call
    final Future<List<Employee>> future = _isAdmin
        ? _employeeService.fetchAllEmployees()
        : _employeeService.fetchEmployeesBasedOnRole(_currentUserId!);

    return FutureBuilder<List<Employee>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final employees = snapshot.data ?? [];

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isAdmin ? "All Employees" : "My Profile",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isAdmin)
                    PrimaryButton(
                      text: "Add",
                      icon: Icons.add,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const EmployeeDialog(
                            isEdit: false,
                            employeeId: null,
                          ),
                        );
                      },
                    )
                ],
              ),

              const SizedBox(height: 20),

              // EMPLOYEE LIST
              employees.isEmpty
                  ? const Center(child: Text("No employees found"))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: employees.length,
                        itemBuilder: (context, i) {
                          Employee employee = employees[i];
                          return EmployeeCard(
                            employee: employee,
                            isAdmin: _isAdmin,
                            onEdit: () => _openEditDialog(employee),
                            onDelete: () {},
                          );
                        },
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
