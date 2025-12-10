import 'package:firebase_auth/firebase_auth.dart';
import 'package:staffora/data/models/firebase_model/auth/login_model.dart';
import 'package:staffora/data/models/firebase_model/auth/signup_model.dart';
import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';
import 'package:staffora/core/utils/logger.dart';
import 'firestore_service.dart';

/// Firebase Authentication Service
/// Handles all authentication operations
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> signup(RegisterModel registerModel) async {
    try {
      // 1️⃣ Create Firebase Auth Account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: registerModel.email,
        password: registerModel.password,
      );

      final user = credential.user;
      if (user == null) {
        return false;
      }

      // 2️⃣ Update display name if provided
      if (registerModel.name.isNotEmpty) {
        await user.updateDisplayName(registerModel.name);
      }

      // 3️⃣ Create user profile in Firestore
      final UserProfile userProfile = UserProfile(
        userId: user.uid,
        firstname: null,
        lastname: null,
        email: registerModel.email,
        address: null,
        changepassword: null,
        joinDate: DateTime.now(),
        profileImageUrl: null,
      );

      await _firestoreService.setDocument(
        'employees',
        user.uid,
        userProfile.toJson(),
        merge: true,
      );

      AppLogger.debug('User signed up successfully: ${user.email}');
      return true; // SUCCESS ✔
    }

    // Firebase errors
    on FirebaseAuthException catch (e) {
      AppLogger.error(
        'Firebase Auth Exception during signup',
        error: e,
        stackTrace: StackTrace.current,
      );
      return false;
    }

    // Other errors
    catch (e, stackTrace) {
      AppLogger.error(
        'Signup error',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signin(LoginModel loginModel) async {
    try {
      // Firebase Login
      final credential = await _auth.signInWithEmailAndPassword(
        email: loginModel.email,
        password: loginModel.password,
      );

      if (credential.user == null) {
        return false; // User not found
      }

      AppLogger.debug('User signed in successfully: ${credential.user?.email}');

      return true; // SUCCESS ✔
    }

    // Firebase Auth Errors (wrong password, no user, etc.)
    on FirebaseAuthException catch (e) {
      AppLogger.error(
        'Firebase Auth Exception during signin',
        error: e,
        stackTrace: StackTrace.current,
      );
      return false; // FAIL ❌
    }

    // Any other error
    catch (e, stackTrace) {
      AppLogger.error('Signin error', error: e, stackTrace: stackTrace);
      return false; // FAIL ❌
    }
  }

  /// Send password reset email
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      AppLogger.debug('Password reset email sent to: $email');
      return "success";
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password reset error', error: e);
      if (e.code == 'user-not-found') {
        return "No user found with this email";
      } else if (e.code == 'invalid-email') {
        return "Invalid email address";
      } else {
        return e.message ?? "An error occurred";
      }
    } catch (e) {
      AppLogger.error('Password reset error', error: e);
      return "Something went wrong, try again";
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'NO_USER',
          message: 'No user is currently signed in',
        );
      }
      await user.updatePassword(newPassword);
      AppLogger.debug('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Update password error', error: e);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      AppLogger.debug('User signed out successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Sign out error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'NO_USER',
          message: 'No user is currently signed in',
        );
      }

      // Delete user profile from Firestore
      await _firestoreService.deleteDocument('profiles', user.uid);

      // Delete auth account
      await user.delete();
      AppLogger.debug('User account deleted successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Delete account error', error: e);
      rethrow;
    }
  }
}
