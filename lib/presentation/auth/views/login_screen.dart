// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:staffora/data/firebase_services/google_service_auth.dart';
// import 'package:staffora/data/firebase_services/notification_service.dart';
// import 'package:staffora/data/models/firebase_model/auth/login_model.dart';
// import 'package:staffora/presentation/auth/controllers/auth_controller.dart';
// import 'package:staffora/core/utils/logger.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key, required BuildContext context});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final AuthController _authController = Get.find<AuthController>();
//   final GoogleSignInService _googleService = GoogleSignInService();
//   final NotificationService notificationService = NotificationService();

//   final emailCtrl = TextEditingController(text: "a@gmail.com");
//   final passCtrl = TextEditingController(text: "123456");
//   bool obscure = true;
//   bool isLoading = false;

//   Future<void> handleLogin() async {
//     if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill in all fields")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       LoginModel loginModel = LoginModel(
//         email: emailCtrl.text,
//         password: passCtrl.text,
//       );

//       final user = await _authController.signIn(loginModel);

//       if (user != null && mounted) {
//         context.go('/profile/user');
//       }
//     } catch (e, stackTrace) {
//       AppLogger.error("Login failed", error: e, stackTrace: stackTrace);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Login failed: ${e.toString()}")),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   Future<void> handleGoogleSignIn() async {
//     setState(() => isLoading = true);

//     try {
//       final user = await _googleService.signInWithGoogle();

//       if (user != null && mounted) {
//         context.go('/profile/user');
//       } else if (mounted) {
//         // User might have cancelled or redirect is in progress
//         AppLogger.debug(
//             'Google sign-in returned null - user may have cancelled or redirect in progress');
//       }
//     } on FirebaseAuthException catch (e) {
//       // Don't show error if user intentionally closed the popup
//       if (e.code == 'popup-closed-by-user' ||
//           e.code == 'cancelled-popup-request') {
//         AppLogger.debug('User closed Google sign-in popup');
//         // Don't show error message to user
//       } else {
//         AppLogger.error("Google sign-in failed",
//             error: e, stackTrace: StackTrace.current);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Google sign-in failed: ${e.message}")),
//           );
//         }
//       }
//     } catch (e, stackTrace) {
//       AppLogger.error("Google sign-in failed",
//           error: e, stackTrace: stackTrace);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Google sign-in failed: ${e.toString()}")),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(22),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 40),
//               Text(
//                 "Welcome Back 👋",
//                 style: GoogleFonts.poppins(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 "Login to continue",
//                 style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
//               ),

//               const SizedBox(height: 40),

//               // Email
//               TextField(
//                 controller: emailCtrl,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   labelText: "Email",
//                   prefixIcon: const Icon(Icons.email),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Password
//               TextField(
//                 controller: passCtrl,
//                 obscureText: obscure,
//                 decoration: InputDecoration(
//                   labelText: "Password",
//                   prefixIcon: const Icon(Icons.lock),
//                   suffixIcon: IconButton(
//                     icon:
//                         Icon(obscure ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () => setState(() => obscure = !obscure),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 10),

//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {
//                     context.go("/auth/forgot/");
//                   },
//                   child: const Text("Forgot Password?"),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Login Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   // onPressed: isLoading ? null : handleLogin,
//                   onPressed: () async {
//                     await notificationService.initializeNotificationSystem();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                           "Login",
//                           style: TextStyle(fontSize: 17, color: Colors.white),
//                         ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               const Row(
//                 children: [
//                   Expanded(child: Divider()),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     child: Text("Or continue with"),
//                   ),
//                   Expanded(child: Divider()),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // OAuth Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _oauthButton("assets/png/google.png",
//                       onTap: handleGoogleSignIn),
//                   const SizedBox(width: 20),
//                   _oauthButton("assets/png/apple.png", onTap: () {}),
//                 ],
//               ),

//               const Spacer(),

//               Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     context.go("/auth/register");
//                   },
//                   child: RichText(
//                     text: const TextSpan(
//                       text: "Don't have an account? ",
//                       style: TextStyle(color: Colors.black87),
//                       children: [
//                         TextSpan(
//                           text: "Register",
//                           style: TextStyle(
//                             color: Colors.blue,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _oauthButton(String asset, {required Function() onTap}) {
//     return InkWell(
//       onTap: isLoading ? null : onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade300),
//         ),
//         child: Image.asset(
//           asset,
//           width: 28,
//           height: 28,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
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

  final _emailCtrl = TextEditingController(text: "k@gmail.com");
  final _passwordCtrl = TextEditingController(text: "121212");

  final adminEmail = "admin@company.com";
  final adminPassword = "admin123";

  final userEmail = "john@company.com";
  final userPassword = "user123";

  final AuthController _authController = Get.find<AuthController>();
  // final GoogleSignInService _googleService = GoogleSignInService();
  // final NotificationService notificationService = NotificationService();

  bool _loading = false;
  bool signIn = true;

  String? _error;

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

  // Future<void> register() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() {
  //     _loading = true;
  //     _error = null;
  //   });

  //   try {
  //     final cred = await _authService.register(
  //       _emailCtrl.text,
  //       _passwordCtrl.text,
  //     );

  //     await _firestoreService.saveUserIfNew(cred.user!);

  //     // log("Registration success: ${cred.user!.uid}");

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (_) => const DashboardScreen()),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     // log("Registration failed: ${e.code}");
  //     setState(() => _error = e.message);
  //   } catch (e) {
  //     setState(() => _error = e.toString());
  //   } finally {
  //     if (mounted) setState(() => _loading = false);
  //   }
  // }

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
              child: AuthCard(
                formKey: _formKey,
                emailCtrl: _emailCtrl,
                passwordCtrl: _passwordCtrl,
                onLogin: handleLogin,
                loading: _loading,
                signIn: signIn,
                onRegister: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- LOGIN CARD UI ----------------

// ignore: must_be_immutable
class AuthCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final bool loading;
  bool signIn;

  AuthCard({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.onLogin,
    this.loading = false,
    this.signIn = true,
    required this.onRegister,
  });

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
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
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    const Text(
                      'Employee Management',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to access your account',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: InkWell(
                          onTap: () {
                            // showInstantNotification();
                          },
                          child: Text(
                            'Preview',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Email Address',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827)),
              ),
              const SizedBox(height: 8),
              CustomInputField(
                hintText: 'Enter your email',
                icon: Icons.email_outlined,
                obscureText: false,
                controller: widget.emailCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Enter email" : null,
              ),
              const SizedBox(height: 18),
              const Text(
                'Password',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827)),
              ),
              const SizedBox(height: 8),
              CustomInputField(
                hintText: 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: true,
                controller: widget.passwordCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? "Enter password" : null,
              ),
              const SizedBox(height: 24),
              Text.rich(TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        widget.signIn = !widget.signIn;
                      });
                    },
                  text: widget.signIn
                      ? "have an account? Sign In"
                      : "Already have an account? Sign In",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ))),
              const SizedBox(height: 24),
              widget.loading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            widget.signIn ? widget.onLogin : widget.onRegister,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C4CFF)),
                        child: Text(
                          widget.signIn ? "Sign In" : "Sign Up",
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

class CustomInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  const CustomInputField({
    super.key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          size: 20,
          color: Colors.grey.shade500,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF4C4CFF),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
