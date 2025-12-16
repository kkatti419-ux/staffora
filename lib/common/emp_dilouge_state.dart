import 'package:flutter/material.dart';
import 'package:staffora/core/utils/formatters.dart';
import 'package:staffora/data/firebase_services/firebase_employee_service.dart';
import 'package:staffora/data/models/firebase_model/department/department_model.dart';
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

  // static const List<String> _departments = [
  //   'Engineering',
  //   'Marketing',
  //   'Human Resources',
  //   'Sales',
  // ];

  List<DepartmentModel> _departments = [];
  bool _loadingDepartments = true;

  bool get _isReadOnly => widget.isEdit;
  Future<void> _loadDepartments() async {
    try {
      final list = await FirebaseEmployeeService().fetchAllDepartments();

      setState(() {
        _departments = list;
        _loadingDepartments = false;

        // Preselect department on edit
        if (widget.initialEmployee != null) {
          _selectedDept = list
                  .map((e) => e.name)
                  .contains(widget.initialEmployee!.department)
              ? widget.initialEmployee!.department
              : null;
        }
      });
    } catch (e) {
      _loadingDepartments = false;
    }
  }

  // ================= INIT =================
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

    _selectedDept = _departments.contains(e?.department) ? e?.department : null;

    _selectedDate = e?.joined ?? DateTime.now();
    _dateCtrl =
        TextEditingController(text: Formatters.formatDate(_selectedDate));
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

  // ================= UI HELPERS =================
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
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
  Future<void> _submitOrEdit() async {
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

    if (widget.isEdit) {
      await service.updateEmployee(widget.employeeId!, employee);
    } else {
      await service.addEmployee(employee);
    }

    Navigator.pop(context, employee);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
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

              /// FIRST NAME
              const RequiredLabel('First Name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _firstNameCtrl,
                readOnly: _isReadOnly,
                decoration: _inputDecoration('First Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              /// LAST NAME
              const RequiredLabel('Last Name'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _lastNameCtrl,
                readOnly: _isReadOnly,
                decoration: _inputDecoration('Last Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              /// EMAIL
              const RequiredLabel('Email'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                readOnly: _isReadOnly,
                decoration: _inputDecoration('Email'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              /// PHONE
              const RequiredLabel('Phone'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                readOnly: _isReadOnly,
                decoration: _inputDecoration('Phone'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              /// DEPARTMENT (ONLY EDITABLE FIELD)
              /// DEPARTMENT (ONLY EDITABLE FIELD)
              const RequiredLabel('Department'),
              const SizedBox(height: 6),

              _loadingDepartments
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedDept,
                      decoration: _inputDecoration('Select Department'),
                      items: _departments
                          .map(
                            (d) => DropdownMenuItem(
                              value: d.name,
                              child: Text(d.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDept = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),

              const SizedBox(height: 12),

              /// POSITION
              const RequiredLabel('Position'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _positionCtrl,
                readOnly: _isReadOnly,
                decoration: _inputDecoration('Position'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              /// JOIN DATE
              const RequiredLabel('Join Date'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: _isReadOnly ? null : _pickDate,
                decoration: _inputDecoration('Join Date'),
              ),
              const SizedBox(height: 24),

              /// ACTIONS
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
                      onPressed: _submitOrEdit,
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

/// REQUIRED LABEL
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
