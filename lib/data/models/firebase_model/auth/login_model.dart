class LoginModel {
  final String email;
  final String password;

  LoginModel({
    required this.email,
    required this.password,
  });

  // Convert model to JSON (useful if you send to API)
  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'password': password,
    };
  }

  // Create model from JSON (optional)
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
