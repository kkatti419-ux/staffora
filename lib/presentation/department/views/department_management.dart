import 'package:flutter/material.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/data/models/firebase_model/department/department_model.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';
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
  final departemnets = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppLogger.debug('DepartmentManagementScreen initialized');
    _firebaseEmployeeService.fetchAllDepartments().then((departments) {
      AppLogger.debug('Fetched ${departments.length} departments on init');
    }).catchError((e) {
      AppLogger.error('Error fetching departments on init: $e');
    });
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
                      // Header
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

                      // Departments List
                      StreamBuilder<List<DepartmentModel>>(
                        stream: _firebaseEmployeeService.departmentsStream(),
                        builder: (context, snapshot) {
                          AppLogger.debug(
                              'Connection: ${snapshot.connectionState}');
                          AppLogger.debug('HasData: ${snapshot.hasData}');
                          AppLogger.debug('HasError: ${snapshot.hasError}');
                          AppLogger.debug('Error: ${snapshot.error}');
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final departments = snapshot.data ?? [];
                          AppLogger.debug(
                              "========== Departments Fetched ==========");
                          AppLogger.debug(departments.length.toString());
                          AppLogger.debug(
                            departments.map((e) => e.name).toList().toString(),
                          );
                          AppLogger.debug(
                              "========== Departments Fetched ==========");

                          if (departments.isEmpty) {
                            AppLogger.debug('No departments found');
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
                                children: [
                                  for (var department in departments)
                                    SizedBox(
                                      width: isSmall
                                          ? constraints.maxWidth
                                          : (constraints.maxWidth - 48) / 3,
                                      child: DepartmentCard(
                                        department: department,
                                        onEdit: () =>
                                            _openAddDialog(department),
                                        onDelete: () => _deleteDepartment(
                                            department.id!, department.name),
                                      ),
                                    ),
                                ],
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

  Future<void> _deleteDepartment(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text(
            'Are you sure you want to delete "$name"? This will not delete employees, but they will be moved to "Unassigned".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firebaseEmployeeService.deleteDepartment(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Department "$name" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        AppLogger.error('Error deleting department: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting department: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// ================= DEPARTMENT CARD =================

class DepartmentCard extends StatelessWidget {
  final DepartmentModel department;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DepartmentCard({
    super.key,
    required this.department,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getDepartmentColor(String name) {
    switch (name) {
      case 'Engineering':
        return const Color(0xFF2563EB);
      case 'Marketing':
        return const Color(0xFFEC4899);
      case 'Human Resources':
        return const Color(0xFF22C55E);
      case 'Sales':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deptColor = _getDepartmentColor(department.name);
    final deptBg = deptColor.withOpacity(0.1);

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
            // Department Name
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: deptBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    department.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: deptColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            if (department.description != null &&
                department.description!.isNotEmpty) ...[
              Text(
                department.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Admin Info
            if (department.adminName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 16,
                    color: deptColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Admin: ${department.adminName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No admin assigned',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Created Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  'Created: ${_formatDate(department.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Actions
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
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ================= DEPARTMENT DIALOG =================

class DepartmentDialog extends StatefulWidget {
  final DepartmentModel? department;
  final FirebaseEmployeeService firebaseEmployeeService;

  const DepartmentDialog({
    super.key,
    this.department,
    required this.firebaseEmployeeService,
  });

  @override
  State<DepartmentDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends State<DepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descriptionCtrl;
  String? _selectedAdminId;
  String? _selectedAdminName;
  List<EmployeeModelClass> _admins = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.department?.name ?? '');
    _descriptionCtrl =
        TextEditingController(text: widget.department?.description ?? '');
    _selectedAdminId = widget.department?.adminId;
    _selectedAdminName = widget.department?.adminName;
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    try {
      final admins = await widget.firebaseEmployeeService.fetchAllAdmins();
      setState(() {
        _admins = admins;
      });
    } catch (e) {
      AppLogger.error('Error loading admins: $e');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4C4CFF), width: 1.2),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final department = DepartmentModel(
        id: widget.department?.id,
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        adminId: _selectedAdminId,
        adminName: _selectedAdminName,
        createdAt: widget.department?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      if (widget.department?.id != null) {
        // Update
        await widget.firebaseEmployeeService
            .updateDepartment(widget.department!.id!, department);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Department updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create
        await widget.firebaseEmployeeService.createDepartment(department);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Department created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.error('Error saving department: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title + close
                Row(
                  children: [
                    Text(
                      widget.department != null
                          ? 'Edit Department'
                          : 'Add New Department',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name
                const RequiredLabel('Department Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecoration('Enter department name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: _inputDecoration('Enter description (optional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Admin Selection
                const Text(
                  'Department Admin',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedAdminId,
                  decoration: _inputDecoration('Select admin (optional)'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No admin assigned'),
                    ),
                    ..._admins.map((admin) => DropdownMenuItem<String>(
                          value: admin.id,
                          child: Text('${admin.name} (${admin.email})'),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAdminId = value;
                      if (value != null) {
                        final admin = _admins.firstWhere((a) => a.id == value);
                        _selectedAdminName = admin.name;
                      } else {
                        _selectedAdminName = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C4CFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  widget.department != null
                                      ? 'Update'
                                      : 'Create',
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= REUSABLE WIDGETS =================

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C4CFF),
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
    );
  }
}

class RequiredLabel extends StatelessWidget {
  final String text;

  const RequiredLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF111827),
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
