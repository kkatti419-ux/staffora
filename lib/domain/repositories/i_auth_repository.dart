import 'package:staffora/data/models/firebase_model/auth/login_model.dart';
import 'package:staffora/data/models/firebase_model/auth/signup_model.dart';

abstract class IAuthRepository {
  /// Signs up a new user
  /// Returns true if successful, false otherwise
  Future<bool> signUp(RegisterModel userData);

  /// Logs in an existing user
  /// Returns true if successful, false otherwise
  Future<bool?> logIn(LoginModel loginModel);
}
