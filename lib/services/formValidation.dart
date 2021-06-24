class FormValidation {
  final emailRegExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  String validatePassword(String password) {
    if (password.isEmpty) {
      return "Empty Password";
    }
    if (password.length < 6) {
      return "Too Short";
    }
    return "Valid";
  }

  String validateEmail(String email) {
    if (email.isEmpty) {
      return "Empty Email";
    }
    if (!emailRegExp.hasMatch(email)) {
      return "Not Valid";
    }
    return "Valid";
  }
}