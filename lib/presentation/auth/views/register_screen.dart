import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staffora/common/reusable_auth_card.dart';
import 'package:staffora/common/custom_textinput_field.dart';
import 'package:staffora/data/models/firebase_model/auth/signup_model.dart';
import 'package:staffora/presentation/auth/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _employeeIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();

  bool _loading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = RegisterModel(
      name: _usernameCtrl.text,
      email: _emailCtrl.text,
      employeeId: _employeeIdCtrl.text,
      password: _passwordCtrl.text,
    );
    try {
      final user = await _authController.signUp(data);

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration failed")),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  title: "Create Account",
                  subtitle: "Register a new employee",
                  loading: _loading,
                  fields: [
                    const Text("Username",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    CustomInputField(
                      hintText: "Enter your name",
                      icon: Icons.person_outline,
                      controller: _usernameCtrl,
                      validator: (v) => v!.isEmpty ? "Enter username" : null,
                    ),
                    const SizedBox(height: 18),
                    const Text("Email Address",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    CustomInputField(
                      hintText: "Enter email",
                      icon: Icons.email_outlined,
                      controller: _emailCtrl,
                      validator: (v) => v!.isEmpty ? "Enter email" : null,
                    ),
                    const SizedBox(height: 18),
                    const Text("Employee ID",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    CustomInputField(
                      hintText: "Enter employee ID",
                      icon: Icons.badge_outlined,
                      controller: _employeeIdCtrl,
                      validator: (v) => v!.isEmpty ? "Enter employee ID" : null,
                    ),
                    const SizedBox(height: 18),
                    const Text("Password",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    CustomInputField(
                      hintText: "Enter password",
                      icon: Icons.lock_outline,
                      obscureText: true,
                      controller: _passwordCtrl,
                      validator: (v) => v!.isEmpty ? "Enter password" : null,
                    ),
                  ],
                  primaryButtonText: "Sign Up",
                  onPrimaryButtonTap: register,
                  footerText: "Already have an account?",
                  footerButtonText: "Sign In",
                  footerRoute: "/auth/login",
                )),
          ),
        ),
      ),
    );
  }
}
