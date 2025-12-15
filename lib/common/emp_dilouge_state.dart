import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:staffora/core/utils/formatters.dart';
import 'package:staffora/data/firebase_services/firebase_employee_service.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';
import 'package:staffora/presentation/department/views/department_management.dart';

class EmployeeDialog extends StatefulWidget {
  final bool isEdit;
  final String? employeeId; // <-- nullable now
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

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _positionCtrl;
  late TextEditingController _dateCtrl;

  String? _selectedDept;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final e = widget.initialEmployee;
    String first = '';
    String last = '';
    if (e != null) {
      final parts = e.name.split(' ');
      if (parts.isNotEmpty) first = parts.first;
      if (parts.length > 1) {
        last = parts.sublist(1).join(' ');
      }
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 30);
    final lastDate = DateTime(now.year + 5);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = Formatters.formatDate(picked);
      });
    }
  }

  void _submit(FirebaseEmployeeService firebaseEmployeeService) async {
    // final employeeService = EmployeeService();
    if (!_formKey.currentState!.validate()) return;

    final fullName =
        '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();
    final initials =
        (_firstNameCtrl.text.isNotEmpty ? _firstNameCtrl.text[0] : '') +
            (_lastNameCtrl.text.isNotEmpty ? _lastNameCtrl.text[0] : '');

    final employee = EmployeeModelClass(
      id: widget.employeeId, // null -> add, non-null -> update
      name: fullName,
      role: _positionCtrl.text.trim(),
      department: _selectedDept ?? '',
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      joined: _selectedDate,
      initials: initials.toUpperCase(),
    );

    await firebaseEmployeeService.addEmployee(employee);

    Navigator.of(context).pop(employee);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.clamp(0.0, 900.0);
          final isNarrow = maxWidth < 600;

          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
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
                          widget.isEdit ? 'Edit ' : 'Add New ',
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

                    // First + Last name
                    isNarrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const RequiredLabel('First Name'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _firstNameCtrl,
                                decoration:
                                    _inputDecoration('Enter first name'),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              const RequiredLabel('Last Name'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _lastNameCtrl,
                                decoration: _inputDecoration('Enter last name'),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const RequiredLabel('First Name'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _firstNameCtrl,
                                      decoration:
                                          _inputDecoration('Enter first name'),
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const RequiredLabel('Last Name'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _lastNameCtrl,
                                      decoration:
                                          _inputDecoration('Enter last name'),
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),

                    // Email + Phone
                    isNarrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const RequiredLabel('Email Address'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailCtrl,
                                decoration:
                                    _inputDecoration('Enter email address'),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              const RequiredLabel('Phone Number'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _phoneCtrl,
                                decoration:
                                    _inputDecoration('Enter phone number'),
                                keyboardType: TextInputType.phone,
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const RequiredLabel('Email Address'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _emailCtrl,
                                      decoration: _inputDecoration(
                                          'Enter email address'),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const RequiredLabel('Phone Number'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _phoneCtrl,
                                      decoration: _inputDecoration(
                                          'Enter phone number'),
                                      keyboardType: TextInputType.phone,
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),

                    // Department + Position
                    isNarrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const RequiredLabel('Department'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _selectedDept,
                                decoration: _inputDecoration('Select'),
                                items: const [
                                  'Engineering',
                                  'Marketing',
                                  'Human Resources',
                                  'Sales',
                                ]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    _selectedDept = v;
                                  });
                                },
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 14),
                              const RequiredLabel('Position'),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _positionCtrl,
                                decoration: _inputDecoration('Enter position'),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const RequiredLabel('Department'),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: _selectedDept,
                                      decoration:
                                          _inputDecoration('Select Department'),
                                      items: const [
                                        'Engineering',
                                        'Marketing',
                                        'Human Resources',
                                        'Sales',
                                      ]
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) {
                                        setState(() {
                                          _selectedDept = v;
                                        });
                                      },
                                      validator: (v) => v == null || v.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const RequiredLabel('Position'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _positionCtrl,
                                      decoration:
                                          _inputDecoration('Enter position'),
                                      validator: (v) =>
                                          v == null || v.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),

                    // Join date row
                    const RequiredLabel('Join Date'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _dateCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: _inputDecoration('Select date'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Bottom buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
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
                              onPressed: () =>
                                  _submit(FirebaseEmployeeService()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C4CFF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                widget.isEdit ? 'Save Changes' : 'Add ',
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
          );
        },
      ),
    );
  }
}
