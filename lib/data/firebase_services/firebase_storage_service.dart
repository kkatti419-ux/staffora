import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:staffora/core/utils/logger.dart';

/// Firebase Storage Service
/// Handles file uploads to Firebase Storage
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref("profile_images/$userId.jpg");
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();
      AppLogger.debug('Profile image uploaded successfully for user: $userId');
      return downloadUrl;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Upload any file to Firebase Storage
  /// [path] - Storage path (e.g., 'documents/user123/file.pdf')
  /// [file] - File to upload
  /// Returns the download URL
  Future<String> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref(path);
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      AppLogger.debug('File uploaded successfully to: $path');
      return downloadUrl;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
      AppLogger.debug('File deleted successfully from: $path');
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
