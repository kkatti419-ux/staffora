import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseProfileServices {
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection("profiles").doc(uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }

  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> profileData) async {
    try {
      await FirebaseFirestore.instance
          .collection("profiles")
          .doc(userId)
          .set(profileData, SetOptions(merge: true));
      return true;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getEmploeeDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection("employee").doc(uid).get();

    if (!doc.exists) return null;

    return doc.data();
  }
}
