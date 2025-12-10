import 'package:staffora/core/utils/result.dart';
import 'package:staffora/data/models/firebase_model/auth/login_model.dart';
import 'package:staffora/data/models/firebase_model/auth/signup_model.dart';
import 'package:staffora/domain/repositories/i_auth_repository.dart';

class AuthUsecase {
  final IAuthRepository repository;
  AuthUsecase({required this.repository});
  @override
  Future<bool> logIn(LoginModel loginModel) async {
    // Validate empty fields
    if (loginModel.email.isEmpty || loginModel.password.isEmpty) {
      throw ArgumentError("Email and password cannot be empty");
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(loginModel.email)) {
      throw ArgumentError("Invalid email format");
    }

    // Call repository
    final success = await repository.logIn(loginModel);

    // success = bool? (true/false/null)
    if (success == true) {
      return true;
    }
    // handle false or null
    throw Exception("Failed to log in");
  }

  @override
  Future<bool> signUp(RegisterModel userData) async {
    try {
      final result = await repository.signUp(userData);
      return result; // true or false
    } catch (e) {
      return false; // any error = false
    }
  }
}
