import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:staffora/core/utils/logger.dart';

/// Google Sign-In Service
/// Handles Google authentication for web, Android, and iOS
class GoogleSignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Web client ID for Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? "847688702354-ti5m5fejiuifu85bsnp446qkaivnguf2.apps.googleusercontent.com"
        : null,
  );

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Sign in with Google
  /// Handles both web (using popup) and mobile (using native flow)
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // 🔹 WEB LOGIN using Google Identity Services
        return await _signInWithGoogleWeb();
      } else {
        // 🔹 ANDROID + iOS LOGIN using native Google Sign-In
        return await _signInWithGoogleMobile();
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Google sign-in error',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Web-specific Google Sign-In
  Future<User?> _signInWithGoogleWeb() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider
        ..addScope('email')
        ..addScope('profile');

      // Try popup first, fallback to redirect if popup fails
      try {
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);

        final User? user = userCredential.user;
        
        if (user != null) {
          await _saveUserToFirestore(user);
        }

        AppLogger.debug('Web Google sign-in successful (popup): ${user?.email}');
        return user;
      } on FirebaseAuthException catch (e) {
        // If popup was blocked or closed, use redirect instead
        if (e.code == 'popup-blocked' || 
            e.code == 'popup-closed-by-user' ||
            e.code == 'cancelled-popup-request') {
          AppLogger.debug('Popup failed, using redirect flow');
          await _auth.signInWithRedirect(googleProvider);
          // The page will reload after redirect, so we return null here
          return null;
        }
        rethrow;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Web Google sign-in error',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }


  /// Mobile-specific Google Sign-In (Android & iOS)
  Future<User?> _signInWithGoogleMobile() async {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      // User cancelled the sign-in
      AppLogger.debug('Google sign-in cancelled by user');
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final User? user = userCredential.user;
    
    if (user != null) {
      await _saveUserToFirestore(user);
    }

    AppLogger.debug('Mobile Google sign-in successful: ${user?.email}');
    return user;
  }

  /// Save user data to Firestore (if new user)
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('profiles').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'userId': user.uid,
          'firstname': user.displayName?.split(' ').first,
          'lastname': user.displayName?.split(' ').skip(1).join(' '),
          'email': user.email,
          'profileImageUrl': user.photoURL,
          'provider': 'google',
          'joinDate': FieldValue.serverTimestamp(),
        });
        AppLogger.debug('New Google user profile created in Firestore');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to save Google user to Firestore',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sign out from Google and Firebase
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      AppLogger.debug('Google sign-out successful');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Google sign-out error',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check for redirect result (call this on app startup for web)
  Future<User?> getRedirectResult() async {
    if (!kIsWeb) return null;

    try {
      final UserCredential? userCredential = 
          await _auth.getRedirectResult();
      
      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        await _saveUserToFirestore(user);
        AppLogger.debug('Web Google sign-in successful (redirect): ${user.email}');
        return user;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get redirect result',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return null;
  }
}
