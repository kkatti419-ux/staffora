import 'package:flutter/material.dart';

class UploadBox extends StatelessWidget {
  final double height;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;

  const UploadBox({
    super.key,
    this.height = 120,
    this.icon = Icons.upload_file,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? Colors.grey.shade300,
            width: 1.3,
          ),
          color: backgroundColor ?? Colors.grey.shade50,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: iconColor ?? Colors.grey.shade600,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
