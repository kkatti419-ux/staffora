import 'package:flutter/material.dart';
import 'package:staffora/data/firebase_services/firebase_employee_service.dart';
import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';

class EmployeeDialog extends StatefulWidget {
  final bool isEdit;
  final String? employeeId;
  final Employee? initialEmployee;

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

  late TextEditingController _firstnameCtrl;
  late TextEditingController _lastnameCtrl;
  late TextEditingController _companyEmailCtrl;
  late TextEditingController _personalEmailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _noLeaveCtrl;

  String? _selectedDept;
  String? _selectedBloodGroup;
  late DateTime _joinDate;
  late TextEditingController _joinDateCtrl;
  final FirebaseEmployeeService _employeeService = FirebaseEmployeeService();

  String formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";

  @override
  void initState() {
    super.initState();

    final e = widget.initialEmployee;

    _firstnameCtrl = TextEditingController(text: e?.firstname ?? "");
    _lastnameCtrl = TextEditingController(text: e?.lastname ?? "");
    _companyEmailCtrl = TextEditingController(text: e?.companyEmail ?? "");
    _personalEmailCtrl = TextEditingController(text: e?.personalEmail ?? "");
    _phoneCtrl = TextEditingController(text: e?.phone ?? "");
    _roleCtrl = TextEditingController(text: e?.role ?? "");
    _addressCtrl = TextEditingController(text: e?.address ?? "");
    _noLeaveCtrl = TextEditingController(text: "${e?.noOfLeaves ?? 12}");

    _selectedDept = e?.dept ?? null;
    _selectedBloodGroup = e?.bloodGroup ?? null;

    _joinDate = e?.joinDate ?? DateTime.now();
    _joinDateCtrl = TextEditingController(text: formatDate(_joinDate));
  }

  @override
  void dispose() {
    _firstnameCtrl.dispose();
    _lastnameCtrl.dispose();
    _companyEmailCtrl.dispose();
    _personalEmailCtrl.dispose();
    _phoneCtrl.dispose();
    _roleCtrl.dispose();
    _addressCtrl.dispose();
    _noLeaveCtrl.dispose();
    _joinDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(1980),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        _joinDate = picked;
        _joinDateCtrl.text = formatDate(picked);
      });
    }
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      labelText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final Employee updated = Employee(
      userId: widget.employeeId ?? "",
      uniqueId: widget.initialEmployee?.uniqueId ?? "",
      firstname: _firstnameCtrl.text.trim(),
      lastname: _lastnameCtrl.text.trim(),
      companyEmail: _companyEmailCtrl.text.trim(),
      personalEmail: _personalEmailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _roleCtrl.text.trim(),
      dept: _selectedDept,
      bloodGroup: _selectedBloodGroup,
      joinDate: _joinDate,
      address: _addressCtrl.text.trim(),
      noOfLeaves: int.tryParse(_noLeaveCtrl.text) ?? 12,
      profileImageUrl: widget.initialEmployee?.profileImageUrl,
    );
    _employeeService.updateEmployee(widget.employeeId ?? "", updated.toJson());

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Text(
                    widget.isEdit ? "Edit Employee" : "Add Employee",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // First & last name
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstnameCtrl,
                      decoration: _input("First Name"),
                      validator: (v) => v!.isEmpty ? "Enter first name" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastnameCtrl,
                      decoration: _input("Last Name"),
                      validator: (v) => v!.isEmpty ? "Enter last name" : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Emails
              TextFormField(
                controller: _companyEmailCtrl,
                decoration: _input("Company Email"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _personalEmailCtrl,
                decoration: _input("Personal Email (Optional)"),
              ),

              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneCtrl,
                decoration: _input("Phone"),
              ),

              const SizedBox(height: 16),

              // Department & role
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDept,
                      decoration: _input("Department"),
                      items: const [
                        "Engineering",
                        "Marketing",
                        "Human Resources",
                        "Sales",
                      ]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedDept = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _roleCtrl,
                      decoration: _input("Position / Role"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Blood group
              DropdownButtonFormField<String>(
                value: _selectedBloodGroup,
                decoration: _input("Blood Group"),
                items: const ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"]
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
              ),

              const SizedBox(height: 16),

              // Leaves
              TextFormField(
                controller: _noLeaveCtrl,
                decoration: _input("No. of Leaves"),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Join date
              TextFormField(
                controller: _joinDateCtrl,
                readOnly: true,
                decoration: _input("Join Date"),
                onTap: _pickJoinDate,
              ),

              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressCtrl,
                decoration: _input("Address"),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: _submit,
                      child: Text(widget.isEdit ? "Save Changes" : "Add"),
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
