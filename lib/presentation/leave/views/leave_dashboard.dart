import 'package:flutter/material.dart';

class DashboardUI extends StatelessWidget {
  const DashboardUI({super.key});

  bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }

  @override
  Widget build(BuildContext context) {
    final bool web = isWeb(context);
    final double width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row - using Wrap for responsiveness
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            spacing: 10,
            children: [
              const Text(
                "Leave Dashboard",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const Text("Apply Leave Form"),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Apply Leave"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const Text("Leave Approvals Page"),
                    ),
                  );
                },
                icon: const Icon(Icons.approval),
                label: const Text("Approvals"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const Text("Leave Calendar Screen"),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text("Calendar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          const Text(
            "Track and manage your leave requests",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Leave Cards (Row or Column)
          if (width > 600)
            Row(
              children: [
                Expanded(
                  child: leaveCard("Casual Leave", Colors.blue, 8, 12),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: leaveCard("Sick Leave", Colors.green, 10, 12),
                ),
              ],
            )
          else
            Column(
              children: [
                leaveCard("Casual Leave", Colors.blue, 8, 12),
                const SizedBox(height: 12),
                leaveCard("Sick Leave", Colors.green, 10, 12),
              ],
            ),

          const SizedBox(height: 15),

          if (width > 600)
            Row(
              children: [
                Expanded(
                  child: leaveCard("Earned Leave", Colors.purple, 15, 18),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: leaveCard("Comp Off", Colors.orange, 3, 5),
                ),
              ],
            )
          else
            Column(
              children: [
                leaveCard("Earned Leave", Colors.purple, 15, 18),
                const SizedBox(height: 12),
                leaveCard("Comp Off", Colors.orange, 3, 5),
              ],
            ),

          const SizedBox(height: 25),

          // Chart + Holidays
          if (web || width > 700)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: barChartWidget()),
                const SizedBox(width: 15),
                Expanded(child: upcomingHolidayWidget()),
              ],
            )
          else
            Column(
              children: [
                barChartWidget(),
                const SizedBox(height: 15),
                upcomingHolidayWidget(),
              ],
            ),

          const SizedBox(height: 25),

          recentLeaveWidget(),
        ],
      ),
    );
  }
}

// ---------------------- RECENT LEAVE ----------------------
Widget recentLeaveWidget() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: boxStyle(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Leave Applications",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        leaveHistoryTile(
          "Casual Leave",
          "Dec 20–22, 2024 • 3 days",
          Colors.green,
          "Approved",
        ),
        leaveHistoryTile(
          "Sick Leave",
          "Nov 15, 2024 • 1 day",
          Colors.green,
          "Approved",
        ),
        leaveHistoryTile(
          "Earned Leave",
          "Oct 10–12, 2024 • 3 days",
          Colors.red,
          "Rejected",
        ),
      ],
    ),
  );
}

// ---------------------- HOLIDAYS ----------------------
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
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
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

// ---------------------- SIMPLE BAR CHART (NO PLUGIN) ----------------------
Widget barChartWidget() {
  List<double> data = [2, 1, 3, 2, 4, 1, 2, 3, 1, 2, 3, 1];
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
        const Text(
          "Monthly Leave Summary",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(data.length, (i) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: data[i] * 30,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade500,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      months[i],
                      style: const TextStyle(fontSize: 10),
                    ),
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

Widget upcomingHolidayWidget() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: boxStyle(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upcoming Holidays",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        holidayTile("25", "Dec", "Christmas Day", "Public Holiday"),
        holidayTile("1", "Jan", "New Year's Day", "Public Holiday"),
        holidayTile("26", "Jan", "Republic Day", "Public Holiday"),
        holidayTile("14", "Mar", "Holi", "Festival"),
      ],
    ),
  );
}

// ---------------------- LEAVE CARD ----------------------

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                month,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              desc,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        )
      ],
    ),
  );
}

// ---------------------- BOX STYLE ----------------------
BoxDecoration boxStyle() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        spreadRadius: 1,
      ),
    ],
  );
}

// ---------------------- LEAVE CARD ----------------------
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
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: used / total,
          color: color,
          backgroundColor: Colors.grey.shade300,
          minHeight: 6,
        ),
        const SizedBox(height: 10),
        Text(
          "$used days available",
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    ),
  );
}
