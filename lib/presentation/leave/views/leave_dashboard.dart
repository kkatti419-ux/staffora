import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:staffora/presentation/leave/views/apply_leave.dart';

class DashboardUI extends StatelessWidget {
  const DashboardUI({super.key});

  bool isWeb(BuildContext context) => MediaQuery.of(context).size.width > 900;

  // ---------------- FETCH LEAVE NUMBERS ----------------
  Future<Map<String, dynamic>> fetchLeaveDashboard(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("leave_requests")
        .where("userId", isEqualTo: userId)
        .get();

    int casual = 0, sick = 0, earned = 0, comp = 0;

    List<Map<String, dynamic>> recent = [];

    // Monthly leave summary (12 months)
    List<int> monthly = List.generate(12, (i) => 0);

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final from = (data["fromDate"] as Timestamp).toDate();
      final to = (data["toDate"] as Timestamp).toDate();
      final applied = (data["appliedOn"] as Timestamp).toDate();

      int days = to.difference(from).inDays + 1;

      // Count only APPROVED in leave balance + summary chart
      if (data["status"] == "approved") {
        switch (data["leaveType"]) {
          case "Casual Leave":
            casual += days;
            break;
          case "Sick Leave":
            sick += days;
            break;
          case "Earned Leave":
            earned += days;
            break;
          case "Comp Off":
            comp += days;
            break;
        }

        // Monthly leave summary
        int monthIndex = applied.month - 1;
        if (monthIndex >= 0 && monthIndex < 12) {
          monthly[monthIndex] += days;
        }
      }

      // Add to recent list
      recent.add({
        "type": data["leaveType"],
        "period": "${from.day}-${to.day} ${_month(from.month)} ${from.year}",
        "status": data["status"],
      });
    }

    // Sort recent by newest → take last 5
    recent.sort((a, b) => b["period"].compareTo(a["period"]));
    final recent5 = recent.take(5).toList();

    return {
      "casual": casual,
      "sick": sick,
      "earned": earned,
      "comp": comp,
      "recent": recent5,
      "monthly": monthly,
    };
  }

  String _month(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    const userId = "EMP004"; // Replace with logged-in user

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchLeaveDashboard(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return _buildDashboard(context, width, data);
      },
    );
  }

  Widget _buildDashboard(
      BuildContext context, double width, Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- HEADER ----------------
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text("Leave Dashboard",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ApplyLeaveForm()));
                },
                icon: const Icon(Icons.add),
                label: const Text("Apply Leave"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ---------------- LEAVE CARDS ----------------
          _leaveCards(width, data),

          const SizedBox(height: 25),

          // ---------------- MONTHLY SUMMARY + HOLIDAYS ----------------
          if (width > 700)
            Row(
              children: [
                Expanded(child: barChartWidget(data["monthly"])),
                const SizedBox(width: 15),
                Expanded(child: upcomingHolidayWidget()),
              ],
            )
          else
            Column(
              children: [
                barChartWidget(data["monthly"]),
                const SizedBox(height: 15),
                upcomingHolidayWidget(),
              ],
            ),

          const SizedBox(height: 25),

          // ---------------- RECENT 5 LEAVES ----------------
          recentLeaveWidget(data["recent"]),
        ],
      ),
    );
  }

  // ---------------- LEAVE CARDS UI ----------------
  Widget _leaveCards(double width, Map<String, dynamic> d) {
    return Column(
      children: [
        width > 600
            ? Row(
                children: [
                  Expanded(
                      child: leaveCard(
                          "Casual Leave", Colors.blue, d["casual"], 8)),
                  const SizedBox(width: 16),
                  Expanded(
                      child:
                          leaveCard("Sick Leave", Colors.green, d["sick"], 10)),
                ],
              )
            : Column(
                children: [
                  leaveCard("Casual Leave", Colors.blue, d["casual"], 8),
                  const SizedBox(height: 12),
                  leaveCard("Sick Leave", Colors.green, d["sick"], 10),
                ],
              ),
        const SizedBox(height: 15),
        width > 600
            ? Row(
                children: [
                  Expanded(
                      child: leaveCard(
                          "Earned Leave", Colors.purple, d["earned"], 15)),
                  const SizedBox(width: 16),
                  Expanded(
                      child:
                          leaveCard("Comp Off", Colors.orange, d["comp"], 3)),
                ],
              )
            : Column(
                children: [
                  leaveCard("Earned Leave", Colors.purple, d["earned"], 15),
                  const SizedBox(height: 12),
                  leaveCard("Comp Off", Colors.orange, d["comp"], 3),
                ],
              ),
      ],
    );
  }
}

// ---------------------------------------------------------
// ---------------------- UI WIDGETS ------------------------
// ---------------------------------------------------------

Widget leaveCard(String title, Color color, int used, int total) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: boxStyle(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.calendar_month, color: color, size: 28),
        ),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: used / total,
          color: color,
          backgroundColor: Colors.grey.shade300,
          minHeight: 6,
        ),
        const SizedBox(height: 10),
        Text("$used of $total used",
            style: TextStyle(color: Colors.grey.shade700)),
      ],
    ),
  );
}

// ----------------- RECENT LEAVES (LAST 5) -----------------
Widget recentLeaveWidget(List recent) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: boxStyle(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Leave Applications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        for (var r in recent)
          leaveHistoryTile(
            r["type"],
            r["period"],
            r["status"] == "approved"
                ? Colors.green
                : r["status"] == "rejected"
                    ? Colors.red
                    : Colors.orange,
            r["status"].toString().toUpperCase(),
          ),
      ],
    ),
  );
}

Widget leaveHistoryTile(
    String title, String subtitle, Color statusColor, String status) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.calendar_month, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(status,
              style:
                  TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

// ---------------- MONTHLY LEAVE CHART ----------------
Widget barChartWidget(List monthly) {
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: boxStyle(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Monthly Leave Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(12, (i) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: monthly[i] * 10,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(months[i], style: const TextStyle(fontSize: 10)),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    ),
  );
}

// ---------------- HOLIDAYS (STATIC) ----------------
Widget upcomingHolidayWidget() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: boxStyle(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upcoming Holidays",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        holidayTile("25", "Dec", "Christmas Day", "Public Holiday"),
        holidayTile("1", "Jan", "New Year's Day", "Public Holiday"),
        holidayTile("26", "Jan", "Republic Day", "Public Holiday"),
        holidayTile("14", "Mar", "Holi", "Festival"),
      ],
    ),
  );
}

Widget holidayTile(String day, String month, String title, String desc) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              Text(day,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(month, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text(desc, style: const TextStyle(color: Colors.grey)),
          ],
        )
      ],
    ),
  );
}

BoxDecoration boxStyle() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 1),
    ],
  );
}
