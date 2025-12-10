import 'dart:math';

import 'package:staffora/data/firebase_services/firebase_auth_service.dart';
import 'package:staffora/data/models/firebase_model/auth/login_model.dart';
import 'package:staffora/data/models/firebase_model/auth/signup_model.dart';
import 'package:staffora/domain/repositories/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuthService service;
  AuthRepository({required this.service});

  @override
  Future<bool> logIn(LoginModel loginModel) async {
    final result = await service.signin(loginModel);

    // result is already true/false from FirebaseAuthService
    return result;
  }

  @override
  Future<bool> signUp(RegisterModel userData) async {
    return await service.signup(userData);
  }
}
