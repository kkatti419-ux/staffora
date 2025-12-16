import 'package:flutter/material.dart';
import 'package:staffora/core/utils/formatters.dart';
import 'package:staffora/data/firebase_services/firebase_employee_service.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';

class EmployeeDialog extends StatefulWidget {
  final bool isEdit;
  final String? employeeId;
  final EmployeeModelClass? initialEmployee;

  const EmployeeDialog({
    super.key,
    required this.isEdit,
    required this.employeeId,
    this.initialEmployee,
  });

  @override
  State<EmployeeDialog> createState() => _EmployeeDialogState();
}

class _EmployeeDialogState extends State<EmployeeDialog> {
  final _formKey = GlobalKey<FormState>();

  // ================= CONTROLLERS =================
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _positionCtrl;
  late TextEditingController _dateCtrl;

  // ================= STATE =================
  String? _selectedDept;
  late DateTime _selectedDate;

  static const List<String> _departments = [
    'Engineering',
    'Marketing',
    'Human Resources',
    'Sales',
  ];

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

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

    // 🔑 IMPORTANT: normalize department
    _selectedDept = _departments.contains(e?.department) ? e!.department : null;

    _selectedDate = e?.joined ?? DateTime.now();
    _dateCtrl =
        TextEditingController(text: Formatters.formatDate(_selectedDate));
  }

  // ================= DISPOSE =================
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

  // ================= UI HELPERS =================
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

  // ================= DATE PICKER =================
  Future<void> _pickDate() async {
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

  // ================= SUBMIT =================
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

    await FirebaseEmployeeService().addEmployee(employee);
    Navigator.of(context).pop(employee);
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== TITLE =====
              Row(
                children: [
                  Text(
                    widget.isEdit ? 'Edit Employee' : 'Add Employee',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // ===== NAME =====
              TextFormField(
                controller: _firstNameCtrl,
                decoration: _inputDecoration('First Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameCtrl,
                decoration: _inputDecoration('Last Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // ===== EMAIL =====
              TextFormField(
                controller: _emailCtrl,
                decoration: _inputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // ===== PHONE =====
              TextFormField(
                controller: _phoneCtrl,
                decoration: _inputDecoration('Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // ===== DEPARTMENT =====
              DropdownButtonFormField<String>(
                value:
                    _departments.contains(_selectedDept) ? _selectedDept : null,
                decoration: _inputDecoration('Select Department'),
                items: _departments
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(d),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedDept = v),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // ===== POSITION =====
              TextFormField(
                controller: _positionCtrl,
                decoration: _inputDecoration('Position'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              // ===== DATE =====
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: _pickDate,
                decoration: _inputDecoration('Join Date'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // ===== ACTIONS =====
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
