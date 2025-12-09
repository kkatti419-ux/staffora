class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return "Email required";
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
      return "Invalid email";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return "Min 6 characters";
    }
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.isEmpty) return "This field is required";
    return null;
  }
}



/*
For validating:
emails
passwords
phone numbers
empty fields
product names
input formats
*/