import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/login_controller.dart';
import '../routes/routes.dart';
import '../services/notification_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>(); // Fetches the controller when needed
    final LoginController loginController = Get.put(LoginController());

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: loginController.emailOrPhoneController,
                decoration: InputDecoration(
                  labelText: "Email or Phone",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: loginController.passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  loginController.login();
                },
                child: Text("Login"),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  authController.signInWithGoogle();
                },
                child: Text("Sign in with Google"),
              ),
              SizedBox(height: 20), // Space between buttons
              ElevatedButton(
                onPressed: () {
                  NotificationService.showNotification(); // Call notification function
                },
                child: Text("Show Notification"),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(AppRoutes.registrationScreen);
                },
                child: Text("Sign up"),
              ),
            ],
          ),
        ),
      );
    }
  }