import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/notification_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>(); // Fetches the controller when needed


      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
        ),
      );
    }
  }