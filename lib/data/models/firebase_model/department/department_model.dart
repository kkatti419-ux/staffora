import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String id; // Firestore document ID
  final String name;
  final String? description;
  final String? adminId; // Employee ID of the department admin
  final String? adminName; // Admin name for quick reference
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  DepartmentModel({
    required this.id,
    required this.name,
    this.description,
    this.adminId,
    this.adminName,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'adminId': adminId,
      'adminName': adminName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
    };
  }

  factory DepartmentModel.fromJson(Map<String, dynamic> json,
      {String? documentId}) {
    DateTime createdAt;
    if (json['createdAt'] is Timestamp) {
      createdAt = (json['createdAt'] as Timestamp).toDate();
    } else if (json['createdAt'] is DateTime) {
      createdAt = json['createdAt'] as DateTime;
    } else {
      createdAt = DateTime.now();
    }

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      if (json['updatedAt'] is Timestamp) {
        updatedAt = (json['updatedAt'] as Timestamp).toDate();
      } else if (json['updatedAt'] is DateTime) {
        updatedAt = json['updatedAt'] as DateTime;
      }
    }

    return DepartmentModel(
      id: documentId ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      adminId: json['adminId'],
      adminName: json['adminName'],
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: json['isActive'] ?? true,
    );
  }

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? description,
    String? adminId,
    String? adminName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
