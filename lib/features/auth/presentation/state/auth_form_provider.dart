import 'package:flutter/material.dart';

class AuthFormProvider with ChangeNotifier {
  // Login Fields
  String _loginEmail = '';
  String _loginPassword = '';
  bool _loginObscureText = true;

  // Signup Fields
  String _signupName = '';
  String _signupEmail = '';
  String _signupPassword = '';
  String _signupConfirmPassword = '';
  bool _signupObscureText = true;
  bool _signupConfirmObscureText = true;

  // Getters
  String get loginEmail => _loginEmail;
  String get loginPassword => _loginPassword;
  bool get loginObscureText => _loginObscureText;

  String get signupName => _signupName;
  String get signupEmail => _signupEmail;
  String get signupPassword => _signupPassword;
  String get signupConfirmPassword => _signupConfirmPassword;
  bool get signupObscureText => _signupObscureText;
  bool get signupConfirmObscureText => _signupConfirmObscureText;

  // Setters
  void setLoginEmail(String val) { _loginEmail = val; notifyListeners(); }
  void setLoginPassword(String val) { _loginPassword = val; notifyListeners(); }
  void toggleLoginObscure() { _loginObscureText = !_loginObscureText; notifyListeners(); }

  void setSignupName(String val) { _signupName = val; notifyListeners(); }
  void setSignupEmail(String val) { _signupEmail = val; notifyListeners(); }
  void setSignupPassword(String val) { _signupPassword = val; notifyListeners(); }
  void setSignupConfirmPassword(String val) { _signupConfirmPassword = val; notifyListeners(); }
  void toggleSignupObscure() { _signupObscureText = !_signupObscureText; notifyListeners(); }
  void toggleSignupConfirmObscure() { _signupConfirmObscureText = !_signupConfirmObscureText; notifyListeners(); }

  // Validation
  bool get isLoginValid {
    final emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_loginEmail);
    final passValid = _loginPassword.length >= 6;
    return emailValid && passValid;
  }

  bool get isSignupValid {
    final nameValid = _signupName.isNotEmpty;
    final emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_signupEmail);
    final passValid = _signupPassword.length >= 6;
    final confirmValid = _signupPassword == _signupConfirmPassword;
    return nameValid && emailValid && passValid && confirmValid;
  }

  void clearLogin() {
    _loginEmail = '';
    _loginPassword = '';
    _loginObscureText = true;
    notifyListeners();
  }

   void clearSignup() {
    _signupName = '';
    _signupEmail = '';
    _signupPassword = '';
    _signupConfirmPassword = '';
    _signupObscureText = true;
    _signupConfirmObscureText = true;
    notifyListeners();
  }
}
