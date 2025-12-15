import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:staffora/common/confirm_dilouge.dart';
import 'package:staffora/common/dashboard_appbar.dart';
import 'package:staffora/core/theme/app_colors.dart';
import 'package:staffora/core/theme/theme_controller.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/presentation/employee/views/employee.dart';
import 'package:staffora/presentation/leave/views/leave_dashboard.dart';
import 'package:staffora/presentation/leave_approval.dart';
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
        return const Text("`No Content`");
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmDialog(
        title: "Logout",
        message: "Are you sure you want to logout?",
        confirmText: "Logout",
        cancelText: "Cancel",
        confirmColor: AppColors.primary,
        onConfirm: () async {
          await FirebaseAuth.instance.signOut();
          if (!mounted) return;
          context.go('/auth/login');
        },
        onCancel: () {
          context.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool web = isWeb(context);
    final ThemeController themeController = Get.find();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //  AppColors.primary,
      //  Colors.grey.shade100,
      appBar: DashboardAppBar(
        title: "Dashboard",
        onLogout: _logout,
        themeController: Get.find<ThemeController>(),
        onSearch: (value) {
          AppLogger.debug("Search: $value");
        },
      ),

      body: web
          ? Row(
              children: [
                // LEFT SIDEBAR (WEB)
                Container(
                  width: 230,
                  color: Theme.of(context).scaffoldBackgroundColor,

                  //  Colors.white,
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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

          // background changes based on active & theme
          color: active
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,

          child: Row(
            children: [
              Icon(
                icon,
                color: active
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ));
  }
}
