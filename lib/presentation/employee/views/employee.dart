import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';

// ================= MODEL & HELPERS =================

String formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

Color departmentColor(String dept) {
  switch (dept) {
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

// ================= DASHBOARD =================

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final _employeeService = EmployeeService();

  Future<void> _openAddDialog() async {
    await showDialog<EmployeeModelClass>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmployeeDialog(
        isEdit: false,
        employeeId: null,
      ),
    );
    // No need to manually update UI – StreamBuilder rebuilds automaticallyy
  }

  Future<void> _openEditDialog(EmployeeModelClass employee) async {
    await showDialog<EmployeeModelClass>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmployeeDialog(
        isEdit: true,
        employeeId: employee.id, // Firestore doc id
        initialEmployee: employee,
      ),
    );
    // Stream updates reflected automatically
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DashboardAppBar(),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 700;

                    return StreamBuilder<List<EmployeeModelClass>>(
                      stream: _employeeService.employeesStream(),
                      builder: (context, snapshot) {
                        final employees = snapshot.data ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ==== HEADER (same UI, now using Firestore count) ====
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'All Employees',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Manage your team of ${employees.length} employees',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                PrimaryButton(
                                  text: 'Add ',
                                  icon: Icons.add,
                                  onPressed: _openAddDialog,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // ==== BODY (same Wrap UI driven by Firestore) ====
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                employees.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (employees.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Text('No Employees'),
                                ),
                              )
                            else
                              Wrap(
                                spacing: 24,
                                runSpacing: 24,
                                children: [
                                  for (int i = 0; i < employees.length; i++)
                                    SizedBox(
                                      width: isSmall
                                          ? constraints.maxWidth
                                          : (constraints.maxWidth - 48) / 3,
                                      child: EmployeeCard(
                                        employee: employees[i],
                                        onEdit: () =>
                                            _openEditDialog(employees[i]),
                                        onDelete: () async {
                                          final id = employees[i].id;
                                          if (id != null && id.isNotEmpty) {
                                            await _employeeService
                                                .deleteEmployee(id);
                                          }
                                        },
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================= APP BAR =================

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

class DepartmentChip extends StatelessWidget {
  final String text;

  const DepartmentChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final color = departmentColor(text);
    final bg = color.withOpacity(0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final EmployeeModelClass employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF7C3AED),
                  child: Text(
                    employee.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        employee.id ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            _EmployeeInfoRow(
              icon: Icons.work_outline,
              text: employee.role,
            ),
            const SizedBox(height: 8),
            DepartmentChip(text: employee.department),
            const SizedBox(height: 12),
            _EmployeeInfoRow(
              icon: Icons.email_outlined,
              text: employee.email,
            ),
            const SizedBox(height: 6),
            _EmployeeInfoRow(
              icon: Icons.phone_in_talk_outlined,
              text: employee.phone,
            ),
            const SizedBox(height: 6),
            _EmployeeInfoRow(
              icon: Icons.calendar_today_outlined,
              text: 'Joined ${formatDate(employee.joined)}',
            ),
            const SizedBox(height: 16),
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
}

class _EmployeeInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmployeeInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

// ================= LABEL FOR REQUIRED FIELDS =================

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

// ================= EMPLOYEE DIALOG =================

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
    _dateCtrl = TextEditingController(text: formatDate(_selectedDate));
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
        _dateCtrl.text = formatDate(picked);
      });
    }
  }

  void _submit() async {
    final employeeService = EmployeeService();
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

    await employeeService.saveEmployee(employee);

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
                              onPressed: _submit,
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

// ================= EMPLOYEE SERVICE =================

class EmployeeService {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'employees';

  // ADD or UPDATE employee
  Future<void> saveEmployee(EmployeeModelClass employee) async {
    final collection = _db.collection(_collection);

    if (employee.id != null && employee.id!.isNotEmpty) {
      // update existing
      await collection.doc(employee.id).set(
            employee.toMap(),
            SetOptions(merge: true),
          );
    } else {
      // add new
      final docRef = await collection.add(employee.toMap());
      await docRef.update({'id': docRef.id});
    }
  }

  // delete employee
  Future<void> deleteEmployee(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // get employees Stream
  Stream<List<EmployeeModelClass>> employeesStream() {
    return _db
        .collection(_collection)
        .orderBy('joined', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EmployeeModelClass.fromMap(
                  doc.data(),
                  documentId: doc.id,
                ),
              )
              .toList(),
        );
  }
}
