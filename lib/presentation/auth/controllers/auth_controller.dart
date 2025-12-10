import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staffora/data/firebase_services/firebase_auth_service.dart';
import 'package:staffora/data/firebase_services/firebase_profile_services.dart';
import 'package:staffora/data/models/firebase_model/auth/login_model.dart';
import 'package:staffora/data/models/firebase_model/auth/signup_model.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/data/repositories/auth_repository.dart';
import 'package:staffora/domain/usecases/auth_usecase.dart';

class AuthController extends GetxController {
  // final FirebaseAuthService _authService = FirebaseAuthService();
  // final AuthUsecase _authService =
  //     AuthUsecase(repository: AuthRepository(service: FirebaseAuthService()));
  final AuthUsecase usecase;

  AuthController({required this.usecase});

  final FirebaseProfileServices _profileService = FirebaseProfileServices();
  final GetStorage storage = GetStorage();

  // Reactive Firebase User
  Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Bind stream to auth state
    // currentUser.bindStream(_authService.authStateChanges);
  }

  // ---------------------------
  // SIGN IN
  // ---------------------------
  Future<bool?> signIn(LoginModel loginModel) async {
    try {
      // Firebase login using service
      bool credential = await usecase.logIn(loginModel);
      // User? user = credential.user;

      if (credential == true) {
        // Assign reactive user
        // currentUser.value = user;

        // Save UID to local storage and store role
        // if (user != null) {
        //   storage.write("uid", user.uid);
        //   AppLogger.debug("User signed in with UID: ${user.uid}");

        //   // Store role in profiles collection on login
        //   await _profileService.storeRoleOnLogin(user.uid);
        // }

        return true;
      } else {
        return false;
      }
      // Assign reactive user
      // currentUser.value = user;

      // Save UID to local storage and store role
      // if (user != null) {
      //   storage.write("uid", user.uid);
      //   AppLogger.debug("User signed in with UID: ${user.uid}");

      //   // Store role in profiles collection on login
      //   await _profileService.storeRoleOnLogin(user.uid);
      // }

      // return user;
    } catch (e, stackTrace) {
      AppLogger.error("Sign-in error", error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // ---------------------------
  // SIGN OUT
  // ---------------------------
  // Future<void> signOut() async {
  //   try {
  //     await _authService.signOut();
  //     storage.remove("uid");
  //     currentUser.value = null;
  //     AppLogger.debug("User signed out successfully");
  //   } catch (e, stackTrace) {
  //     AppLogger.error("Sign-out error", error: e, stackTrace: stackTrace);
  //   }
  // }

  // ---------------------------
  // GET UID ANYWHERE
  // ---------------------------
  // String? get userId => currentUser.value?.uid ?? storage.read("uid");

  // // ---------------------------
  // // SIGN UP
  // // ---------------------------
  Future<bool> signUp(RegisterModel registerModel) async {
    try {
      // Call signup usecase (returns bool)
      final success = await usecase.signUp(registerModel);

      if (!success) {
        return false; // signup failed
      }

      // Fetch the current Firebase user
      // final User? user = _auth.currentUser;

      // if (user == null) {
      //   return false;
      // }

      // // Update reactive user
      // currentUser.value = user;

      // // Save UID
      // storage.write("uid", user.uid);
      // AppLogger.debug("User signed up with UID: ${user.uid}");

      // Store role (default = "user")
      // await _profileService.storeRoleOnLogin(user.uid);

      return true; // SUCCESS
    } catch (e, stackTrace) {
      AppLogger.error("Sign-up error", error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // ---------------------------
  // SEND PASSWORD RESET EMAIL
  // ---------------------------
  // Future<String> sendPasswordResetEmail(String email) async {
  //   return await _authService.sendPasswordResetEmail(email);
  // }
}
