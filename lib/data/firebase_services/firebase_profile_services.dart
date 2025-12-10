import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:staffora/core/utils/logger.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';

class FirebaseProfileServices {
  /// Get current user profile from profiles collection
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("profiles")
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return doc.data();
    } catch (e, stackTrace) {
      AppLogger.error("Error getting user profile",
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get user role from profiles collection
  Future<String?> getUserRole() async {
    final profile = await getCurrentUserProfile();
    return profile?['role'] as String?;
  }

  /// Store or update user role in profiles collection
  Future<bool> setUserRole(String userId, String role) async {
    try {
      await FirebaseFirestore.instance
          .collection("profiles")
          .doc(userId)
          .set({'role': role}, SetOptions(merge: true));
      AppLogger.debug("User role set successfully: $role for user $userId");
      return true;
    } catch (e, stackTrace) {
      AppLogger.error("Error setting user role",
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("profiles")
          .doc(userId)
          .set(profileData, SetOptions(merge: true));
      AppLogger.debug("Profile updated successfully for user $userId");
      return true;
    } catch (e, stackTrace) {
      AppLogger.error("Error updating profile",
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Get employee details from employee collection (fixed typo)
  Future<Map<String, dynamic>?> getEmployeeDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("employee")
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return doc.data();
    } catch (e, stackTrace) {
      AppLogger.error("Error getting employee details",
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get employee details from employees collection by userId
  Future<Map<String, dynamic>?> getEmployeeDetailsByUserId(
      String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("employees")
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return doc.data()..['id'] = doc.id;
    } catch (e, stackTrace) {
      AppLogger.error("Error getting employee details by userId",
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Get all employees (for admin)
  Stream<List<EmployeeModelClass>> getAllEmployeesStream() {
    return FirebaseFirestore.instance
        .collection("employees")
        .orderBy('joined', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmployeeModelClass.fromMap(
                  doc.data(),
                  documentId: doc.id,
                ))
            .toList());
  }

  /// Get employee stream by userId (for regular users)
  Stream<List<EmployeeModelClass>> getEmployeeStreamByUserId(String userId) {
    return FirebaseFirestore.instance
        .collection("employees")
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmployeeModelClass.fromMap(
                  doc.data(),
                  documentId: doc.id,
                ))
            .toList());
  }

  /// Store role on login - checks employee collection and sets role in profiles
  Future<bool> storeRoleOnLogin(String userId) async {
    try {
      // First check if role exists in profiles
      final profile = await getCurrentUserProfile();
      if (profile != null && profile['role'] != null) {
        AppLogger.debug("Role already exists in profile: ${profile['role']}");
        return true;
      }

      // Try to get role from employee collection
      final employeeData = await getEmployeeDetailsByUserId(userId);
      if (employeeData != null && employeeData['role'] != null) {
        final role = employeeData['role'] as String;
        await setUserRole(userId, role);
        AppLogger.debug("Role stored from employee data: $role");
        return true;
      }

      // If no role found, default to 'user'
      await setUserRole(userId, 'user');
      AppLogger.debug("Default role 'user' set for user $userId");
      return true;
    } catch (e, stackTrace) {
      AppLogger.error("Error storing role on login",
          error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
