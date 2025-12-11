import 'package:flutter/material.dart';
import 'package:staffora/core/theme/theme_controller.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onLogout;
  final ThemeController themeController;
  final ValueChanged<String>? onSearch;

  const DashboardAppBar({
    super.key,
    required this.title,
    required this.onLogout,
    required this.themeController,
    this.onSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 70,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // 🌟 Title
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),

            const Spacer(),
            Expanded(
              flex: 1,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: TextField(
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: "Search…",
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: Theme.of(context).hintColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 8),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 🌙 Theme Toggle
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: themeController.toggleTheme,
            ),

            // 🚪 Logout
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
