import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staffora/data/firebase_services/google_service_auth.dart';
import 'package:staffora/data/firebase_services/notification_service.dart';
import 'package:staffora/data/models/firebase_model/auth/login_model.dart';
import 'package:staffora/presentation/auth/controllers/auth_controller.dart';
import 'package:staffora/core/utils/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required BuildContext context});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final GoogleSignInService _googleService = GoogleSignInService();
  final NotificationService notificationService = NotificationService();

  final emailCtrl = TextEditingController(text: "a@gmail.com");
  final passCtrl = TextEditingController(text: "123456");
  bool obscure = true;
  bool isLoading = false;

  Future<void> handleLogin() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      LoginModel loginModel = LoginModel(
        email: emailCtrl.text,
        password: passCtrl.text,
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
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> handleGoogleSignIn() async {
    setState(() => isLoading = true);

    try {
      final user = await _googleService.signInWithGoogle();

      if (user != null && mounted) {
        context.go('/profile/user');
      } else if (mounted) {
        // User might have cancelled or redirect is in progress
        AppLogger.debug(
            'Google sign-in returned null - user may have cancelled or redirect in progress');
      }
    } on FirebaseAuthException catch (e) {
      // Don't show error if user intentionally closed the popup
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        AppLogger.debug('User closed Google sign-in popup');
        // Don't show error message to user
      } else {
        AppLogger.error("Google sign-in failed",
            error: e, stackTrace: StackTrace.current);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Google sign-in failed: ${e.message}")),
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error("Google sign-in failed",
          error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google sign-in failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "Welcome Back 👋",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Login to continue",
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
              ),

              const SizedBox(height: 40),

              // Email
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                controller: passCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon:
                        Icon(obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.go("/auth/forgot/");
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 20),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // onPressed: isLoading ? null : handleLogin,
                  onPressed: () async {
                    await notificationService.initializeNotificationSystem();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("Or continue with"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              // OAuth Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _oauthButton("assets/png/google.png",
                      onTap: handleGoogleSignIn),
                  const SizedBox(width: 20),
                  _oauthButton("assets/png/apple.png", onTap: () {}),
                ],
              ),

              const Spacer(),

              Center(
                child: GestureDetector(
                  onTap: () {
                    context.go("/auth/register");
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _oauthButton(String asset, {required Function() onTap}) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Image.asset(
          asset,
          width: 28,
          height: 28,
        ),
      ),
    );
  }
}
