import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staffora/data/firebase_services/firestore_service.dart';
import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';

class FirebaseEmployeeService {
  final FirestoreService _firestoreService = FirestoreService();

  final _db = FirebaseFirestore.instance.collection('employees');

  // Fetch all employees
  Future<List<Employee>> fetchAllEmployees() async {
    final snapshot = await _db.get();
    return snapshot.docs.map((doc) => Employee.fromJson(doc.data())).toList();
  }

  // Fetch employee by current userId
  Future<Employee?> fetchEmployeeByUserId(String userId) async {
    final doc = await _db.doc(userId).get();
    if (!doc.exists) return null;
    return Employee.fromJson(doc.data()!);
  }

  // Fetch employees based on role
  Future<List<Employee>> fetchEmployeesBasedOnRole(String userId) async {
    final current = await fetchEmployeeByUserId(userId);
    if (current == null) return [];

    if (current.role == "admin") {
      return fetchAllEmployees();
    }

    return [current]; // normal user
  }

  // Update employee
  Future<void> updateEmployee(String userId, Map<String, dynamic> data) async {
    await _db.doc(userId).update(data);
  }

  Future<void> addEmployee(Map<String, dynamic> data) async {
    final doc = _firestoreService.collection("employees").doc();
    data["userId"] = doc.id; // auto-generate ID
    await doc.set(data);
  }

  // Delete employee
  Future<void> deleteEmployee(String userId) async {
    await _db.doc(userId).delete();
  }
}
