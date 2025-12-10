class Employee {
  final String userId; // Firebase Auth UID
  final String uniqueId; // Your custom unique employee ID
  final String? dept;
  final String? firstname;
  final String? lastname;
  final String? companyEmail; // cemail
  final String? personalEmail; // pemail
  final String? phone;
  final String? bloodGroup;
  final String? address;
  final int? noOfLeaves;
  final DateTime? joinDate;
  final String? role; // admin or user
  final String? profileImageUrl;

  Employee({
    required this.userId,
    required this.uniqueId,
    this.dept,
    this.firstname,
    this.lastname,
    this.companyEmail,
    this.personalEmail,
    this.phone,
    this.bloodGroup,
    this.address,
    this.noOfLeaves,
    this.joinDate,
    this.role,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'uniqueId': uniqueId,
      'dept': dept,
      'firstname': firstname,
      'lastname': lastname,
      'companyEmail': companyEmail,
      'personalEmail': personalEmail,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'address': address,
      'noOfLeaves': noOfLeaves,
      'joinDate': joinDate?.toIso8601String(),
      'role': role,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> map) {
    return Employee(
      userId: map['userId'] ?? '',
      uniqueId: map['uniqueId'] ?? '',
      dept: map['dept'],
      firstname: map['firstname'],
      lastname: map['lastname'],
      companyEmail: map['companyEmail'],
      personalEmail: map['personalEmail'],
      phone: map['phone'],
      bloodGroup: map['bloodGroup'],
      address: map['address'],
      noOfLeaves: map['noOfLeaves'],
      joinDate:
          map['joinDate'] != null ? DateTime.parse(map['joinDate']) : null,
      role: map['role'],
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
