import 'package:flutter/material.dart';
import 'package:staffora/common/cencel.dart';
import 'package:staffora/common/date_picker.dart';
import 'package:staffora/common/dropdown.dart';
import 'package:staffora/common/submit.dart';

class ApplyLeaveForm extends StatefulWidget {
  @override
  State<ApplyLeaveForm> createState() => _ApplyLeaveFormState();
}

class _ApplyLeaveFormState extends State<ApplyLeaveForm> {
  String? selectedLeaveType;
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(
          width: 700,
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white,
            boxShadow: [
              const BoxShadow(
                  color: Colors.black12, blurRadius: 10, spreadRadius: 2)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Apply for Leave",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(
                      "Fill in the details to submit your leave request",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // ---------------- FORM BODY ----------------
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leave Type
                    const Text("Leave Type *",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    CustomDropdown(
                      items: const [
                        "Casual Leave",
                        "Sick Leave",
                        "Earned Leave",
                        "Comp Off"
                      ],
                      value: selectedLeaveType,
                      hint: "Select leave type",
                      onChanged: (v) {
                        setState(() => selectedLeaveType = v);
                      },
                    ),

                    const SizedBox(height: 18),

                    // Dates Row
                    Row(
                      children: [
                        Expanded(
                            child: DatePickerField(
                          label: "From Date",
                          selectedDate: fromDate,
                          onDateSelected: (date) {
                            setState(() => fromDate = date);
                          },
                        )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: DatePickerField(
                          label: "To Date",
                          selectedDate: toDate,
                          onDateSelected: (date) {
                            setState(() => toDate = date);
                          },
                        )),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Reason
                    const Text("Reason for Leave *",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 4,
                      decoration: inputDecoration(
                        "Please provide a brief reason for your leave request...",
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Upload Section
                    const Text("Upload Attachment (Optional)",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 10),
                    uploadBox(),

                    const SizedBox(height: 25),

                    // Buttons
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CancelButton(),
                        SubmitButton(),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- DROPDOWN ----------------

  // ---------------- DATE PICKER FIELD ----------------

  // ---------------- UPLOAD BOX ----------------
  Widget uploadBox() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.3),
        color: Colors.grey.shade50,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 30, color: Colors.grey.shade600),
            const SizedBox(height: 6),
            Text("Click to upload medical certificate",
                style: TextStyle(color: Colors.grey.shade600)),
            Text("PDF, JPG, PNG up to 10MB",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ---------------- BUTTONS ----------------

  // ---------------- DECORATION HELPERS ----------------
  BoxDecoration fieldDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
