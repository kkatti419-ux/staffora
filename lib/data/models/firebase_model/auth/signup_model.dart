class RegisterModel {
  final String name;
  final String email;
  final String? employeeId;
  final String password;

  RegisterModel({
    required this.name,
    required this.email,
    required this.employeeId,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name.trim(),
      "email": email.trim(),
      "employeeId": employeeId?.trim(),
      "password": password.trim(),
    };
  }
}
