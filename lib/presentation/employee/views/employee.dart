import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staffora/common/employee_card.dart';
import 'package:staffora/common/primary_button.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';
import 'package:staffora/data/firebase_services/firebase_profile_services.dart';

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
  final _profileService = FirebaseProfileServices();
  String? _currentUserRole;
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserRole();
  }

  Future<void> _loadCurrentUserRole() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      AppLogger.debug('Current User ID: $userId');

      _currentUserId = userId;

      // Fetch user role from profiles collection using profile service
      final role = await _profileService.getUserRole();
      AppLogger.debug('User Role from profile: $role');

      setState(() {
        _currentUserRole = role;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.error('Error loading user role',
          error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool get _isAdmin => _currentUserRole?.toLowerCase() == 'admin';

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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
                      stream: _isAdmin
                          ? _profileService.getAllEmployeesStream()
                          : _profileService
                              .getEmployeeStreamByUserId(_currentUserId!),
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
                                      Text(
                                        _isAdmin
                                            ? 'All Employees'
                                            : 'My Profile',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isAdmin
                                            ? 'Manage your team of ${employees.length} employees'
                                            : 'View your employee details',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (_isAdmin)
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
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Text(
                                    _isAdmin
                                        ? 'No Employees'
                                        : 'No employee record found for your account',
                                  ),
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
                                        isAdmin: _isAdmin,
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

    // Get current user ID for new employees
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final employee = EmployeeModelClass(
      id: widget.employeeId, // null -> add, non-null -> update
      userId: widget.isEdit
          ? widget.initialEmployee?.userId ?? currentUserId
          : currentUserId, // Set userId for new employees or preserve for edits
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

    // Convert to map and ensure joined is Timestamp
    final data = employee.toMap();
    data['joined'] = Timestamp.fromDate(employee.joined);

    if (employee.id != null && employee.id!.isNotEmpty) {
      // update existing
      await collection.doc(employee.id).set(
            data,
            SetOptions(merge: true),
          );
    } else {
      // add new - ensure userId is set if not provided
      if (data['userId'] == null) {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        data['userId'] = currentUserId;
      }
      final docRef = await collection.add(data);
      await docRef.update({'id': docRef.id});
    }
  }

  // delete employee
  Future<void> deleteEmployee(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  // get employees Stream (all employees - for admin)
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

  // get employee stream by userId (for regular users)
  Stream<List<EmployeeModelClass>> employeeStreamByUserId(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
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
