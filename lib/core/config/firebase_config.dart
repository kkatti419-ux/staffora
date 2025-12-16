import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import '../utils/logger.dart';

/// Firebase Configuration Service
/// Handles Firebase initialization and app check configuration
class FirebaseConfig {
  static bool _isInitialized = false;

  /// Initialize Firebase with proper error handling
  static Future<bool> initialize() async {
    if (_isInitialized) {
      AppLogger.debug('Firebase already initialized');
      return true;
    }

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Firebase App Check (optional, uncomment when ready)
      // await _initializeAppCheck();

      _isInitialized = true;
      AppLogger.debug('🔥 Firebase initialized successfully');
      return true;
    } catch (e, stackTrace) {
      // AppLogger.error(
      //   '❌ Firebase initialization failed',
      //   error: e,
      //   stackTrace: stackTrace,
      // );
      return false;
    }
  }

  /// Initialize Firebase App Check for security
  static Future<void> _initializeAppCheck() async {
    try {
      await FirebaseAppCheck.instance.activate(
        // For Android
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        // For iOS
        appleProvider:
            kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
        // For Web
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
      AppLogger.debug('✅ Firebase App Check activated');
    } catch (e) {
      // AppLogger.error('⚠️ Firebase App Check activation failed: $e');
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;
}
