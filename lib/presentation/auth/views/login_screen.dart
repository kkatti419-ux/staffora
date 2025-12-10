import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:staffora/common/auth/reusable_auth_card.dart';
import 'package:staffora/common/custom_textinput_field.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/data/models/firebase_model/auth/login_model.dart';
import 'package:staffora/presentation/auth/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController(text: "aa@gmail.com");
  final _passwordCtrl = TextEditingController(text: "121212");

  final AuthController _authController = Get.find<AuthController>();

  bool _loading = false;

  Future<void> handleLogin() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }
    setState(() => _loading = true);

    try {
      LoginModel loginModel = LoginModel(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      final user = await _authController.signIn(loginModel);

      if (user != null && mounted) {
        context.go('/profile/user');
      }
    } catch (e, stackTrace) {
      AppLogger.error("Login failed", error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B5CFF), Color(0xFFFF6AD5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ReusableAuthCard(
                  formKey: _formKey,
                  title: "Employee Management",
                  subtitle: "Sign in to access your account",
                  fields: [
                    const Text("Email Address",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    CustomInputField(
                      hintText: "Enter your email",
                      icon: Icons.email_outlined,
                      controller: _emailCtrl,
                      validator: (v) => v!.isEmpty ? "Enter email" : null,
                    ),
                    const SizedBox(height: 18),
                    const Text("Password",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    CustomInputField(
                      hintText: "Enter your password",
                      icon: Icons.lock_outline,
                      obscureText: true,
                      controller: _passwordCtrl,
                      validator: (v) => v!.isEmpty ? "Enter password" : null,
                    ),
                  ],
                  primaryButtonText: "Sign In",
                  onPrimaryButtonTap: handleLogin,
                  footerText: "Don’t have an account?",
                  footerButtonText: "Sign Up",
                  footerRoute: "/auth/register",
                  loading: _loading,
                )),
          ),
        ),
      ),
    );
  }
}
