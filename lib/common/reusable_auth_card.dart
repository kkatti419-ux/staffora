import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ReusableAuthCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final String title;
  final String subtitle;

  final List<Widget> fields;

  final bool loading;
  final String primaryButtonText;
  final VoidCallback onPrimaryButtonTap;

  final String footerText;
  final String footerButtonText;
  final String footerRoute;

  const ReusableAuthCard({
    super.key,
    required this.formKey,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.primaryButtonText,
    required this.onPrimaryButtonTap,
    required this.footerText,
    required this.footerButtonText,
    required this.footerRoute,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 18,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xFF4C4CFF),
                      child: Icon(Icons.groups_rounded,
                          size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // FIELDS (DYNAMIC)
              ...fields,

              const SizedBox(height: 24),

              // FOOTER NAVIGATION (login/signup)
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "$footerText ",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(
                        text: footerButtonText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C4CFF),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.go(footerRoute),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : onPrimaryButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C4CFF),
                  ),
                  child: Text(
                    loading ? 'Please wait...' : primaryButtonText,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
