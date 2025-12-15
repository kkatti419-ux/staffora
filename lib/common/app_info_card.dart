import 'package:flutter/material.dart';
import 'package:staffora/common/info_item.dart';

class AppInfoCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? avatarText;
  final Color avatarColor;

  final List<InfoItem> infoItems;
  final Widget? chip;
  final Widget? footer;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const AppInfoCard({
    super.key,
    this.title,
    this.subtitle,
    this.avatarText,
    this.avatarColor = const Color(0xFF7C3AED),
    this.infoItems = const [],
    this.chip,
    this.footer,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (title != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (avatarText != null)
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: avatarColor,
                      child: Text(
                        avatarText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (avatarText != null) const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],

            if (infoItems.isNotEmpty) const SizedBox(height: 16),

            // Info rows
            ...infoItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InfoRow(
                    icon: item.icon,
                    text: item.text,
                  ),
                )),

            if (chip != null) ...[
              const SizedBox(height: 10),
              chip!,
            ],

            if (footer != null) ...[
              const SizedBox(height: 10),
              footer!,
            ],

            // Actions
            if (showActions) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4C4CFF),
                          backgroundColor: const Color(0xFFF5F3FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 40,
                    width: 44,
                    child: TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF1F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
