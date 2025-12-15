import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staffora/data/firebase_services/firestore_service.dart';
import 'package:staffora/data/models/firebase_model/profile/profile_model.dart';
import 'package:staffora/data/models/firebase_model/employee/employee.dart';
import 'package:staffora/data/models/firebase_model/department/department_model.dart';

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

  // ========== NEW METHODS FOR ADMIN DEPARTMENT FUNCTIONALITY ==========

  /// Fetch all admins from employees collection
  Future<List<EmployeeModelClass>> fetchAllAdmins() async {
    try {
      final snapshot = await _db
          .where('role', isEqualTo: 'admin')
          .orderBy('department')
          .get();

      return snapshot.docs.map((doc) {
        return EmployeeModelClass.fromMap(
          doc.data(),
          documentId: doc.id,
        );
      }).toList();
    } catch (e) {
      // If orderBy fails, try without it
      final snapshot = await _db.where('role', isEqualTo: 'admin').get();
      return snapshot.docs.map((doc) {
        return EmployeeModelClass.fromMap(
          doc.data(),
          documentId: doc.id,
        );
      }).toList();
    }
  }

  /// Stream of all admins
  Stream<List<EmployeeModelClass>> adminsStream() {
    return _db
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmployeeModelClass.fromMap(
                  doc.data(),
                  documentId: doc.id,
                ))
            .toList());
  }

  /// Fetch admins by department
  Future<List<EmployeeModelClass>> fetchAdminsByDepartment(
      String department) async {
    final snapshot = await _db
        .where('role', isEqualTo: 'admin')
        .where('department', isEqualTo: department)
        .get();

    return snapshot.docs.map((doc) {
      return EmployeeModelClass.fromMap(
        doc.data(),
        documentId: doc.id,
      );
    }).toList();
  }

  /// Fetch employees by department
  Future<List<EmployeeModelClass>> fetchEmployeesByDepartment(
      String department) async {
    final snapshot = await _db
        .where('department', isEqualTo: department)
        .orderBy('joined', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return EmployeeModelClass.fromMap(
        doc.data(),
        documentId: doc.id,
      );
    }).toList();
  }

  /// Stream of employees by department
  Stream<List<EmployeeModelClass>> employeesByDepartmentStream(
      String department) {
    return _db
        .where('department', isEqualTo: department)
        .orderBy('joined', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmployeeModelClass.fromMap(
                  doc.data(),
                  documentId: doc.id,
                ))
            .toList());
  }

  /// Get employees grouped by department with their admins
  /// Returns a map: department -> {admin: EmployeeModelClass?, employees: List<EmployeeModelClass>}
  Future<Map<String, Map<String, dynamic>>>
      fetchEmployeesGroupedByDepartment() async {
    // Fetch all employees
    final allEmployeesSnapshot = await _db.get();
    final allEmployees = allEmployeesSnapshot.docs
        .map((doc) => EmployeeModelClass.fromMap(
              doc.data(),
              documentId: doc.id,
            ))
        .toList();

    // Group by department
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var employee in allEmployees) {
      final dept =
          employee.department.isNotEmpty ? employee.department : 'Unassigned';

      if (!grouped.containsKey(dept)) {
        grouped[dept] = {
          'admin': null,
          'employees': <EmployeeModelClass>[],
        };
      }

      // If this employee is an admin, set as admin for this department
      if (employee.role.toLowerCase() == 'admin') {
        grouped[dept]!['admin'] = employee;
      } else {
        // Add to employees list
        (grouped[dept]!['employees'] as List<EmployeeModelClass>).add(employee);
      }
    }

    return grouped;
  }

  /// Stream of employees grouped by department
  Stream<Map<String, Map<String, dynamic>>>
      employeesGroupedByDepartmentStream() {
    return _db.snapshots().map((snapshot) {
      final allEmployees = snapshot.docs
          .map((doc) => EmployeeModelClass.fromMap(
                doc.data(),
                documentId: doc.id,
              ))
          .toList();

      final Map<String, Map<String, dynamic>> grouped = {};

      for (var employee in allEmployees) {
        final dept =
            employee.department.isNotEmpty ? employee.department : 'Unassigned';

        if (!grouped.containsKey(dept)) {
          grouped[dept] = {
            'admin': null,
            'employees': <EmployeeModelClass>[],
          };
        }

        if (employee.role.toLowerCase() == 'admin') {
          grouped[dept]!['admin'] = employee;
        } else {
          (grouped[dept]!['employees'] as List<EmployeeModelClass>)
              .add(employee);
        }
      }

      return grouped;
    });
  }

  // ========== DEPARTMENT CRUD OPERATIONS ==========

  final _deptDb = FirebaseFirestore.instance.collection('departments');

  /// Create a new department
  Future<String> createDepartment(DepartmentModel department) async {
    final docRef = _deptDb.doc();
    final data = department.toJson();
    data['id'] = docRef.id;
    await docRef.set(data);
    return docRef.id;
  }

  /// Get all departments
  Future<List<DepartmentModel>> fetchAllDepartments() async {
    final snapshot =
        await _deptDb.where('isActive', isEqualTo: true).orderBy('name').get();

    return snapshot.docs.map((doc) {
      return DepartmentModel.fromJson(
        doc.data(),
        documentId: doc.id,
      );
    }).toList();
  }

  /// Stream of all departments
  Stream<List<DepartmentModel>> departmentsStream() {
    return _deptDb
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DepartmentModel.fromJson(
                  doc.data(),
                  documentId: doc.id,
                ))
            .toList());
  }

  /// Get department by ID
  Future<DepartmentModel?> fetchDepartmentById(String id) async {
    final doc = await _deptDb.doc(id).get();
    if (!doc.exists) return null;
    return DepartmentModel.fromJson(
      doc.data()!,
      documentId: doc.id,
    );
  }

  /// Get department by name
  Future<DepartmentModel?> fetchDepartmentByName(String name) async {
    final snapshot = await _deptDb
        .where('name', isEqualTo: name)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return DepartmentModel.fromJson(
      snapshot.docs.first.data(),
      documentId: snapshot.docs.first.id,
    );
  }

  /// Update department
  Future<void> updateDepartment(String id, DepartmentModel department) async {
    final data = department
        .copyWith(
          id: id,
          updatedAt: DateTime.now(),
        )
        .toJson();
    await _deptDb.doc(id).update(data);
  }

  /// Delete department (soft delete by setting isActive to false)
  Future<void> deleteDepartment(String id) async {
    await _deptDb.doc(id).update({
      'isActive': false,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Hard delete department (permanent deletion)
  Future<void> hardDeleteDepartment(String id) async {
    await _deptDb.doc(id).delete();
  }

  /// Assign admin to department
  Future<void> assignAdminToDepartment(
      String departmentId, String adminId, String adminName) async {
    await _deptDb.doc(departmentId).update({
      'adminId': adminId,
      'adminName': adminName,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Remove admin from department
  Future<void> removeAdminFromDepartment(String departmentId) async {
    await _deptDb.doc(departmentId).update({
      'adminId': null,
      'adminName': null,
      'updatedAt': Timestamp.now(),
    });
  }
}
