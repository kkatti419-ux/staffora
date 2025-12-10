class UserProfile {
  final String userId;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? address;
  final String? changepassword;
  final String? role; // admin or user

  final DateTime? joinDate;
  final String? profileImageUrl;

  UserProfile({
    required this.userId,
    this.firstname,
    this.lastname,
    this.email,
    this.address,
    this.changepassword,
    this.role,
    this.joinDate,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'address': address,
      'changepassword': changepassword,
      'role': role,
      'joinDate': joinDate?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  // optional: factory to create from Firestore doc
  factory UserProfile.fromJson(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] as String,
      firstname: map['firstname'] as String?,
      lastname: map['lastname'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      role: map['role'] as String?,
      joinDate:
          map['joinDate'] != null ? DateTime.parse(map['joinDate']) : null,
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }
}
