import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staffora/data/firebase_services/firebase_auth_service.dart';
import 'package:staffora/data/models/firebase_model/auth/login_model.dart';
import 'package:staffora/data/models/firebase_model/auth/signup_model.dart';
import 'package:staffora/core/utils/logger.dart';

class AuthController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final GetStorage storage = GetStorage();

  // Reactive Firebase User
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Bind stream to auth state
    currentUser.bindStream(_authService.authStateChanges);
  }

  // ---------------------------
  // SIGN IN
  // ---------------------------
  Future<User?> signIn(LoginModel loginModel) async {
    try {
      // Firebase login using service
      UserCredential credential = await _authService.signin(loginModel);
      User? user = credential.user;

      // Assign reactive user
      currentUser.value = user;

      // Save UID to local storage
      if (user != null) {
        storage.write("uid", user.uid);
        AppLogger.debug("User signed in with UID: ${user.uid}");
      }

      return user;
    } catch (e, stackTrace) {
      AppLogger.error("Sign-in error", error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // ---------------------------
  // SIGN OUT
  // ---------------------------
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      storage.remove("uid");
      currentUser.value = null;
      AppLogger.debug("User signed out successfully");
    } catch (e, stackTrace) {
      AppLogger.error("Sign-out error", error: e, stackTrace: stackTrace);
    }
  }

  // ---------------------------
  // GET UID ANYWHERE
  // ---------------------------
  String? get userId => currentUser.value?.uid ?? storage.read("uid");

  // ---------------------------
  // SIGN UP
  // ---------------------------
  Future<User?> signUp(RegisterModel registerModel) async {
    try {
      // Call signup service
      UserCredential credential = await _authService.signup(registerModel);
      User? user = credential.user;

      // Update reactive user
      currentUser.value = user;

      // Save UID in GetStorage
      if (user != null) {
        storage.write("uid", user.uid);
        AppLogger.debug("User signed up with UID: ${user.uid}");
      }

      return user;
    } catch (e, stackTrace) {
      AppLogger.error("Sign-up error", error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // ---------------------------
  // SEND PASSWORD RESET EMAIL
  // ---------------------------
  Future<String> sendPasswordResetEmail(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }
}
