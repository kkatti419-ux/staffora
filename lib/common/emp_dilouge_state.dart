import 'package:flutter/material.dart';
import 'package:staffora/core/utils/formatters.dart';
import 'package:staffora/data/firebase_services/firebase_employee_service.dart';
import 'package:staffora/data/models/firebase_model/department/department_model.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';

/// 🔐 USER ROLE
enum UserRole { admin, employee }

class EmployeeDialog extends StatefulWidget {
  final bool isEdit;
  final String? employeeId;
  final EmployeeModelClass? initialEmployee;
  final UserRole currentUserRole;

  const EmployeeDialog({
    super.key,
    required this.isEdit,
    required this.employeeId,
    required this.currentUserRole,
    this.initialEmployee,
  });

  @override
  State<EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<EmployeeDialog> {
  final _formKey = GlobalKey<FormState>();

  // ---------------- CONTROLLERS ----------------
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _positionCtrl;
  late TextEditingController _dateCtrl;

  // ---------------- STATE ----------------
  DateTime _selectedDate = DateTime.now();
  String? _selectedDept;

  List<DepartmentModel> _departments = [];
  bool _loadingDepartments = true;

  // ---------------- ROLE HELPERS ----------------
  bool get isAdmin => widget.currentUserRole == UserRole.admin;

  /// Admin + Employee → personal info
  bool get canEditPersonal => true;

  /// Only Admin → department & position
  bool get canEditOrg => isAdmin;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _loadDepartments();

    final e = widget.initialEmployee;

    String first = '';
    String last = '';
    if (e != null) {
      final parts = e.name.split(' ');
      if (parts.isNotEmpty) first = parts.first;
      if (parts.length > 1) last = parts.sublist(1).join(' ');
    }

    _firstNameCtrl = TextEditingController(text: first);
    _lastNameCtrl = TextEditingController(text: last);
    _emailCtrl = TextEditingController(text: e?.email ?? '');
    _phoneCtrl = TextEditingController(text: e?.phone ?? '');
    _positionCtrl = TextEditingController(text: e?.role ?? '');
    _selectedDept = e?.department;
    _selectedDate = e?.joined ?? DateTime.now();
    _dateCtrl =
        TextEditingController(text: Formatters.formatDate(_selectedDate));
  }

  Future<void> _loadDepartments() async {
    try {
      final list = await FirebaseEmployeeService().fetchAllDepartments();
      if (!mounted) return;

      setState(() {
        _departments = list;
        _loadingDepartments = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDepartments = false);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _positionCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  // ---------------- UI HELPERS ----------------
  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // ---------------- DATE PICKER ----------------
  Future<void> _pickDate() async {
    if (!canEditPersonal) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 30),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = Formatters.formatDate(picked);
      });
    }
  }

  // ---------------- SUBMIT ----------------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName =
        '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();

    final initials =
        (_firstNameCtrl.text.isNotEmpty ? _firstNameCtrl.text[0] : '') +
            (_lastNameCtrl.text.isNotEmpty ? _lastNameCtrl.text[0] : '');

    final employee = EmployeeModelClass(
      id: widget.employeeId,
      name: fullName,
      role: _positionCtrl.text.trim(),
      department: _selectedDept ?? '',
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      joined: _selectedDate,
      initials: initials.toUpperCase(),
    );

    final service = FirebaseEmployeeService();

    widget.isEdit
        ? await service.updateEmployee(widget.employeeId!, employee)
        : await service.addEmployee(employee);

    if (mounted) Navigator.pop(context, employee);
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Row(
                children: [
                  Text(
                    widget.isEdit ? 'Edit Employee' : 'Add Employee',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _field(
                'First Name',
                TextFormField(
                  controller: _firstNameCtrl,
                  readOnly: !canEditPersonal,
                  decoration: _decoration('First Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),

              _field(
                'Last Name',
                TextFormField(
                  controller: _lastNameCtrl,
                  readOnly: !canEditPersonal,
                  decoration: _decoration('Last Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),

              _field(
                'Email',
                TextFormField(
                  controller: _emailCtrl,
                  readOnly: !canEditPersonal,
                  decoration: _decoration('Email'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),

              _field(
                'Phone',
                TextFormField(
                  controller: _phoneCtrl,
                  readOnly: !canEditPersonal,
                  decoration: _decoration('Phone'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),

              const RequiredLabel('Department'),
              const SizedBox(height: 6),

              _loadingDepartments
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : DropdownButtonFormField<String>(
                      value: _departments.any((d) => d.name == _selectedDept)
                          ? _selectedDept
                          : null,
                      decoration: _decoration('Select Department'),
                      items: _departments
                          .map(
                            (d) => DropdownMenuItem(
                              value: d.name,
                              child: Text(
                                d.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: canEditOrg
                          ? (v) => setState(() => _selectedDept = v)
                          : null,
                      validator: (v) => v == null ? 'Required' : null,
                    ),

              const SizedBox(height: 12),

              _field(
                'Position',
                TextFormField(
                  controller: _positionCtrl,
                  readOnly: !canEditOrg,
                  decoration: _decoration('Position'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),

              _field(
                'Join Date',
                TextFormField(
                  controller: _dateCtrl,
                  readOnly: true,
                  onTap: canEditPersonal ? _pickDate : null,
                  decoration: _decoration('Join Date'),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(widget.isEdit ? 'Save' : 'Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequiredLabel(label),
        const SizedBox(height: 6),
        field,
        const SizedBox(height: 12),
      ],
    );
  }
}

/// ---------------- REQUIRED LABEL ----------------
class RequiredLabel extends StatelessWidget {
  final String text;
  const RequiredLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF111827),
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
