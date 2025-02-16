import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>(); // Fetches the controller when needed

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            authController.signInWithGoogle();
          },
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}
