import 'package:flutter/material.dart';
import 'package:staffora/data/firebase_services/firebase_employee_service.dart';
import 'package:staffora/data/models/firebase_model/department/department_model.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';

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

  List<EmployeeModelClass> _employees = [];
  bool _loadingEmployees = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.department?.name ?? '');
    _descriptionCtrl =
        TextEditingController(text: widget.department?.description ?? '');
    _selectedAdminId = widget.department?.adminId;
    _selectedAdminName = widget.department?.adminName;
    _loadAdmins();
    _loadEmployees(); // 👈 NEW
  }

  Future<void> _loadEmployees() async {
    try {
      final list = await widget.firebaseEmployeeService.fetchAllEmployees();

      setState(() {
        _employees = list;
        _loadingEmployees = false;

        // 🔑 Reset if admin no longer exists
        if (_selectedAdminId != null &&
            !_employees.any((e) => e.id == _selectedAdminId)) {
          _selectedAdminId = null;
          _selectedAdminName = null;
        }
      });
    } catch (e) {
      _loadingEmployees = false;
    }
  }

  Future<void> _loadAdmins() async {
    try {
      final admins = await widget.firebaseEmployeeService.fetchAllAdmins();

      setState(() {
        _admins = admins;

        // 🔑 FIX: reset value if it doesn't exist
        if (_selectedAdminId != null &&
            !_admins.any((a) => a.id == _selectedAdminId)) {
          _selectedAdminId = null;
          _selectedAdminName = null;
        }
      });
    } catch (e) {
      // AppLogger.error('Error loading admins: $e');
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
        id: widget.department?.id ?? '',
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
      // AppLogger.error('Error saving department: $e');
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
                // const RequiredLabel('Department Name'),
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

                _loadingEmployees
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedAdminId,
                        decoration: _inputDecoration('Select admin (optional)'),
                        hint: const Text('No admin assigned'),
                        items: _employees.map((emp) {
                          return DropdownMenuItem<String>(
                            value: emp.id,
                            child: Text(
                              emp.name.isNotEmpty
                                  ? emp.name
                                  : 'Unnamed Employee',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAdminId = value;

                            if (value != null) {
                              final emp =
                                  _employees.firstWhere((e) => e.id == value);
                              _selectedAdminName = emp.name;
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
