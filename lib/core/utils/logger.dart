import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Application Logger
/// Provides centralized logging with support for debug and error messages
class AppLogger {
  /// Log debug messages
  static void debug(String message) {
    if (kDebugMode) {
      dev.log("DEBUG: $message");
    }
  }

  /// Log error messages with optional error object and stack trace
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final errorMsg = error != null ? '\nError: $error' : '';
      final stackMsg = stackTrace != null ? '\nStack: $stackTrace' : '';
      dev.log("\x1B[31mERROR: $message$errorMsg$stackMsg\x1B[0m");
    }
  }

  /// Log info messages
  static void info(String message) {
    if (kDebugMode) {
      dev.log("INFO: $message");
    }
  }

  /// Log warning messages
  static void warning(String message) {
    if (kDebugMode) {
      dev.log("\x1B[33mWARNING: $message\x1B[0m");
    }
  }
}
