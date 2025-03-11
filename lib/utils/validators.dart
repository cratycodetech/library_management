class Validators {

  static String? validateName(String name) {
    if (name.isEmpty) return "Name cannot be empty";
    if (name.length < 3) return "Name must be at least 3 characters long";
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(name)) return "Invalid name format";
    return null; // ✅ No error
  }


  static String? validateEmailOrPhone(String input) {
    bool isEmail = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(input);
    bool isPhone = RegExp(r"^\d{11}$").hasMatch(input);


    if (input.isEmpty) return "Email or phone number is required";
    if (!isEmail && !isPhone) return "Enter a valid email or phone number";

    return null;
  }


  static String? validatePassword(String password) {
    if (password.isEmpty) return "Password cannot be empty";
    if (password.length < 6) return "Password must be at least 6 characters long";
    if (!RegExp(r"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{6,}$").hasMatch(password)) {
      return "Password must contain at least one number and one special character";
    }
    return null; // ✅ No error
  }
}
