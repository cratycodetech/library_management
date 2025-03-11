import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/snackbar_service.dart';
import '../controllers/auth_controller.dart';
import '../utils/validators.dart';

class LoginController extends GetxController {
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthController authController = Get.find<AuthController>();

  void login() {
    String emailOrPhone = emailOrPhoneController.text.trim();
    String password = passwordController.text.trim();

    String? emailPhoneError = Validators.validateEmailOrPhone(emailOrPhone);
    String? passwordError = Validators.validatePassword(password);

    if (emailPhoneError != null) {
      SnackbarService.showError(emailPhoneError);
      return;
    }
    if (passwordError != null) {
      SnackbarService.showError(passwordError);
      return;
    }

    // ✅ Call AuthController's login method
    authController.loginWithEmailAndPassword(emailOrPhone, password);
  }
}
