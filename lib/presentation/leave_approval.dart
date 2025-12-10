import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLeaveScreen extends StatelessWidget {
  const AdminLeaveScreen({super.key});

  Future<void> updateLeaveStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(id)
        .update({"status": status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Leave Management",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "All Leave Requests",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Manage employee leave requests",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // ---------------- LEAVE TABLE ----------------
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('leave_requests')
                          .orderBy('appliedOn', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No leave requests found",
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                                const Color(0xFFF3F4F6)),
                            border: TableBorder.all(
                                color: Colors.grey.shade300, width: 0.5),
                            columns: const [
                              DataColumn(label: Text("Employee")),
                              DataColumn(label: Text("Type")),
                              DataColumn(label: Text("From")),
                              DataColumn(label: Text("To")),
                              DataColumn(label: Text("Reason")),
                              DataColumn(label: Text("Applied On")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Action")),
                            ],
                            rows: docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              final fromDate =
                                  (data["fromDate"] as Timestamp).toDate();
                              final toDate =
                                  (data["toDate"] as Timestamp).toDate();
                              final applied =
                                  (data["appliedOn"] as Timestamp).toDate();

                              return DataRow(
                                cells: [
                                  DataCell(Text(data["userName"])),
                                  DataCell(Text(data["leaveType"])),
                                  DataCell(Text(
                                      "${fromDate.day}/${fromDate.month}/${fromDate.year}")),
                                  DataCell(Text(
                                      "${toDate.day}/${toDate.month}/${toDate.year}")),
                                  DataCell(Text(
                                    data["reason"],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  DataCell(Text(
                                      "${applied.day}/${applied.month}/${applied.year}")),
                                  DataCell(StatusBadge(status: data["status"])),

                                  // ---------------- ACTION BUTTONS ----------------
                                  DataCell(
                                    Row(
                                      children: [
                                        // Approve Button (always enabled)
                                        ElevatedButton(
                                          onPressed: () => updateLeaveStatus(
                                              doc.id, "approved"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.green.shade600,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                          ),
                                          child: const Text("Approve",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),

                                        const SizedBox(width: 8),

                                        // Reject Button (always enabled)
                                        ElevatedButton(
                                          onPressed: () => updateLeaveStatus(
                                              doc.id, "rejected"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                          ),
                                          child: const Text("Reject",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),

                                        const SizedBox(width: 8),

                                        // Undo → Set Back To Pending
                                        // OutlinedButton(
                                        //   onPressed: () => updateLeaveStatus(
                                        //       doc.id, "pending"),
                                        //   style: OutlinedButton.styleFrom(
                                        //     side: BorderSide(
                                        //         color: Colors.orange.shade700),
                                        //   ),
                                        //   child: Text(
                                        //     "Undo",
                                        //     style: TextStyle(
                                        //         color: Colors.orange.shade700),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- STATUS BADGE ----------------
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (status == "approved")
      color = Colors.green.shade600;
    else if (status == "rejected")
      color = Colors.red.shade600;
    else
      color = Colors.orange.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
