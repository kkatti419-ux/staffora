import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:staffora/common/date_picker.dart';
import 'package:staffora/common/dropdown.dart';
import 'package:staffora/common/primary_button.dart';

class ApplyLeaveForm extends StatefulWidget {
  @override
  State<ApplyLeaveForm> createState() => _ApplyLeaveFormState();
}

class _ApplyLeaveFormState extends State<ApplyLeaveForm> {
  String? selectedLeaveType;
  DateTime? fromDate;
  DateTime? toDate;
  String? dateError;

  TextEditingController reasonController = TextEditingController();

  bool isLoading = true;

  /// User total leave policy
  Map<String, int> totalLeaves = {
    "Casual Leave": 8,
    "Sick Leave": 10,
    "Earned Leave": 15,
    "Comp Off": 3,
  };

  /// Leaves already used (based on approved leaves)
  Map<String, int> usedLeaves = {
    "Casual Leave": 0,
    "Sick Leave": 0,
    "Earned Leave": 0,
    "Comp Off": 0,
  };

  @override
  void initState() {
    super.initState();
    loadUsedLeaves();
  }

  // ---------------- FETCH USED LEAVES FROM FIRESTORE ----------------
  Future<void> loadUsedLeaves() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("leave_requests")
        .where("userId", isEqualTo: "EMP004") // logged in user
        .where("status", isEqualTo: "approved")
        .get();

    Map<String, int> temp = {
      "Casual Leave": 0,
      "Sick Leave": 0,
      "Earned Leave": 0,
      "Comp Off": 0,
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final from = (data["fromDate"] as Timestamp).toDate();
      final to = (data["toDate"] as Timestamp).toDate();
      int days = to.difference(from).inDays + 1;

      temp[data["leaveType"]] = temp[data["leaveType"]]! + days;
    }

    setState(() {
      usedLeaves = temp;
      isLoading = false;
    });
  }

  // ---------------- CALCULATE AVAILABLE DAYS ----------------
  int availableDaysFor(String type) {
    return totalLeaves[type]! - usedLeaves[type]!;
  }

  // ---------------- VALIDATE DATE SELECTION ----------------
  void validateDateSelection() {
    if (selectedLeaveType == null || fromDate == null || toDate == null) return;

    int selectedDays = toDate!.difference(fromDate!).inDays + 1;
    int available = availableDaysFor(selectedLeaveType!);

    if (selectedDays > available) {
      setState(() {
        dateError =
            "You selected $selectedDays days but only $available days are available.";
      });
    } else {
      setState(() {
        dateError = null;
      });
    }
  }

  // ---------------- SUBMIT LEAVE ----------------
  Future<void> submitLeave() async {
    if (selectedLeaveType == null || fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (dateError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(dateError!)));
      return;
    }

    final leaveId = DateTime.now().millisecondsSinceEpoch.toString();

    await FirebaseFirestore.instance
        .collection("leave_requests")
        .doc(leaveId)
        .set({
      "id": leaveId,
      "userId": "EMP004",
      "userName": "Emily Brown",
      "leaveType": selectedLeaveType!,
      "fromDate": fromDate,
      "toDate": toDate,
      "reason": reasonController.text,
      "attachment": null,
      "status": "pending",
      "appliedOn": DateTime.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave Request Submitted")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ---------------- HEADER ----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(22)),
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

                      // ---------------- DYNAMIC LEAVE DROPDOWN ----------------
                      CustomDropdown(
                        items: [
                          "Casual Leave",
                          "Sick Leave",
                          "Earned Leave",
                          "Comp Off"
                        ],
                        value: selectedLeaveType,
                        hint: "Select leave type",
                        itemBuilder: (context, item) {
                          bool disabled = availableDaysFor(item) <= 0;
                          return Opacity(
                            opacity: disabled ? 0.4 : 1,
                            child: IgnorePointer(
                              ignoring: disabled,
                              child: Text(
                                  "$item (${availableDaysFor(item)} left)"),
                            ),
                          );
                        },
                        onChanged: (v) {
                          setState(() {
                            selectedLeaveType = v;
                            dateError = null;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      // ---------------- DATE SELECTION ----------------
                      Row(
                        children: [
                          Expanded(
                            child: DatePickerField(
                              label: "From Date",
                              selectedDate: fromDate,
                              onDateSelected: (date) {
                                setState(() => fromDate = date);
                                validateDateSelection();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DatePickerField(
                              label: "To Date",
                              selectedDate: toDate,
                              onDateSelected: (date) {
                                setState(() => toDate = date);
                                validateDateSelection();
                              },
                            ),
                          ),
                        ],
                      ),

                      if (dateError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            dateError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                          ),
                        ),

                      const SizedBox(height: 18),

                      // ---------------- REASON ----------------
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

                      // ---------------- UPLOAD ----------------
                      const Text("Upload Attachment (Optional)",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 10),
                      uploadBox(),

                      const SizedBox(height: 25),

                      // ---------------- SUBMIT BUTTONS ----------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PrimaryButton(
                            text: "Cancel Leave Request",
                            onPressed: submitLeave,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  // ---------------- FIELD STYLES ----------------
  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
