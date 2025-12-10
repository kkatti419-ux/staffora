// import 'package:cloud_firestore/cloud_firestore.dart';

// class EmployeeModelClass {
//   String? id;
//   String? userId; // Link to user account
//   String name;
//   String role;
//   String department;
//   String email;
//   String phone;
//   DateTime joined;
//   String initials;

//   EmployeeModelClass({
//     this.id,
//     this.userId,
//     required this.name,
//     required this.role,
//     required this.department,
//     required this.email,
//     required this.phone,
//     required this.joined,
//     required this.initials,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'userId': userId,
//       'name': name,
//       'role': role,
//       'department': department,
//       'email': email,
//       'phone': phone,
//       'joined': joined,
//       'initials': initials,
//     };
//   }

//   /// map + optional Firestore documentId
//   factory EmployeeModelClass.fromMap(Map<String, dynamic> map,
//       {String? documentId}) {
//     return EmployeeModelClass(
//       id: documentId ?? map['id'],
//       userId: map['userId'] as String?,
//       name: map['name'] ?? '',
//       role: map['role'] ?? '',
//       department: map['department'] ?? '',
//       email: map['email'] ?? '',
//       phone: map['phone'] ?? '',
//       joined: (map['joined'] as Timestamp).toDate(),
//       initials: map['initials'] ?? '',
//     );
//   }
// }
