import 'package:flutter/material.dart';
import 'package:staffora/presentation/employee/views/employee.dart';
import 'package:staffora/presentation/leave/views/leave_dashboard.dart';
import 'package:staffora/presentation/leave_approval.dart';
import 'package:staffora/presentation/profile/views/profile_view.dart';
import 'package:staffora/presentation/sallary/views/sallary.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardScreen> {
  int selectedTab = 0;

  bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > 900;
  }

  /// ---------------------- SELECTED CONTENT ----------------------
  Widget selectedContent() {
    switch (selectedTab) {
      case 0:
        return const EmployeeScreen(); // Main Dashboard
      case 1:
        return const DashboardUI(); // Leave Dashboard
      case 2:
        return const SalaryPage(); // Salary
      case 3:
        return const DashboardUI(); // Profile
      case 4:
        return const AdminLeaveScreen(); // Prof

      case 5:
        return const AdminLeaveScreen();
      default:
        return const ProfilePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool web = isWeb(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0.5, title: Text("data")
          // DashboardAppBar(),
          ),

      body: web
          ? Row(
              children: [
                // LEFT SIDEBAR (WEB)
                Container(
                  width: 230,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      tabItem("Dashboard", Icons.grid_view, 0),
                      const SizedBox(height: 10),
                      tabItem("Leave Check", Icons.add_card, 1),
                      const SizedBox(height: 10),
                      tabItem("Salary", Icons.verified, 2),
                      const SizedBox(height: 10),
                      tabItem("Profile", Icons.person, 3),
                      const SizedBox(height: 10),
                      tabItem("leave apporaval", Icons.person, 4),
                    ],
                  ),
                ),

                // CONTENT AREA
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: selectedContent(),
                  ),
                ),
              ],
            )
          : selectedContent(), // Mobile content only

      // MOBILE BOTTOM NAVIGATION
      bottomNavigationBar: web
          ? null
          : BottomNavigationBar(
              currentIndex: selectedTab,
              onTap: (i) => setState(() => selectedTab = i),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.grid_view), label: "Dashboard"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.add_card), label: "Leave Check"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.verified), label: "Salary"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Profile"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "leave approval"),
              ],
            ),
    );
  }

  // ---------------------- TAB ITEM (SIDEBAR - WEB) ----------------------
  Widget tabItem(String title, IconData icon, int index) {
    bool active = selectedTab == index;

    return InkWell(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        color: active ? Colors.blue.shade50 : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: active ? Colors.blue : Colors.grey),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
